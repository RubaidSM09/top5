import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../data/model/time_date.dart';
import '../../../data/services/api_services.dart';

class HomeController extends GetxController {
  final now = DateTime.now().obs;
  Timer? _minuteTicker;
  Timer? _weatherTicker;

  // UI state (you already had these)
  RxList<RxBool> selectedCategory = [true.obs, false.obs, false.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedFilter   = [true.obs, false.obs, false.obs, false.obs, false.obs, false.obs].obs;
  RxBool isListView = true.obs;
  RxList<RxBool> selectedLocations = [false.obs, false.obs, false.obs, false.obs, false.obs].obs;
  final double dragSensitivity = 600;
  final RxDouble sheetPosition = 0.48.obs;
  final RxBool isMoreDetails = false.obs;
  final RxBool isMapClicked = false.obs;

  final ApiService _service = ApiService();

  // NEW: Weather/time data
  final RxBool weatherLoading = false.obs;
  final RxString weather = ''.obs;
  final RxString weatherDesc = ''.obs;
  final RxDouble tempC = 0.0.obs;

  // If you want to show API’s formatted day/time too:
  final RxString serverDay = ''.obs;
  final RxString serverTimeStr = ''.obs;

  IconData get weatherIcon {
    final w = weather.value.toLowerCase();

    if (w.contains('clear') || w.contains('sun')) {
      return Icons.wb_sunny;
    } else if (w.contains('cloud')) {
      return Icons.cloud;
    } else if (w.contains('rain') || w.contains('drizzle')) {
      return Icons.grain; // raindrop
    } else if (w.contains('storm') || w.contains('thunder')) {
      return Icons.flash_on;
    } else if (w.contains('snow')) {
      return Icons.ac_unit;
    } else if (w.contains('fog') ||
        w.contains('mist') ||
        w.contains('haze') ||
        w.contains('smoke')) {
      return Icons.blur_on;
    } else {
      return Icons.wb_cloudy; // default
    }
  }

  Color get weatherIconColor {
    final w = weather.value.toLowerCase();
    if (w.contains('clear') || w.contains('sun')) {
      return const Color(0xFFFFD700); // golden sun
    } else if (w.contains('rain') || w.contains('storm')) {
      return Colors.blueGrey;
    } else if (w.contains('snow')) {
      return Colors.lightBlueAccent;
    } else if (w.contains('fog') || w.contains('haze')) {
      return Colors.grey;
    } else {
      return Colors.lightBlue; // default sky tone
    }
  }

  final RxBool ideasLoading = false.obs;
  final RxList<String> ideas = <String>[].obs;

// Helper: map selected pill → backend category string
  String get _currentCategory {
    // index order in your UI: 0-restaurant,1-cafes,2-bars,3-activities,4-services
    final i = selectedCategory.indexWhere((e) => e.value);
    switch (i) {
      case 0: return 'restaurant';
      case 1: return 'cafes';
      case 2: return 'bars';
      case 3: return 'activities';
      case 4:
      default: return 'service'; // API sample uses "service"
    }
  }

// Format fallback when serverDay/serverTimeStr are empty
  String get _fallbackDayName => DateFormat('EEEE').format(DateTime.now());
  String get _fallbackTimeStr => DateFormat('hh:mm a').format(DateTime.now());

// Call backend to generate ideas
  Future<void> refreshIdeas() async {
    // Need weather + time in place
    final wd = (weatherDesc.value.isNotEmpty ? weatherDesc.value : weather.value).toLowerCase();
    final day = (serverDay.value.isNotEmpty ? serverDay.value : _fallbackDayName);
    final tStr = (serverTimeStr.value.isNotEmpty ? serverTimeStr.value : _fallbackTimeStr);
    final temp = tempC.value; // double

    ideasLoading.value = true;
    try {
      final res = await _service.generateIdeas(wd, day, tStr, temp, _currentCategory);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final List<dynamic> raw = (json['ideas_list'] ?? []) as List<dynamic>;
        ideas.assignAll(raw.map((e) => e.toString()));
      } else {
        final msg = _safeMsg(res.body) ?? 'Failed to generate ideas.';
        Get.snackbar('Ideas', msg);
        ideas.clear();
      }
    } catch (e) {
      Get.snackbar('Ideas', 'Unexpected error occurred');
      ideas.clear();
    } finally {
      ideasLoading.value = false;
    }
  }

// Call this when a category pill is tapped
  void onCategoryChanged(int index) {
    for (int i = 0; i < selectedCategory.length; i++) {
      selectedCategory[i].value = (i == index);
    }
    // Re-generate ideas for the new category
    refreshIdeas();
  }

  @override
  void onInit() {
    super.onInit();

    // Device time ticker (updates every minute)
    _tick();
    final firstDelay = Duration(seconds: 60 - DateTime.now().second);
    _minuteTicker = Timer(firstDelay, () {
      now.value = DateTime.now();
      _minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
        now.value = DateTime.now();
      });
    });

    // Immediately fetch weather, then refresh every 10 minutes
    _fetchAndSetWeather();
    _weatherTicker = Timer.periodic(const Duration(minutes: 10), (_) {
      _fetchAndSetWeather();
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _minuteTicker?.cancel();
    _weatherTicker?.cancel();
    super.onClose();
  }

  // --------- PUBLIC READ-ONLY BINDINGS FOR UI ---------
  RxString get formatted {
    final d = DateFormat('EEE', 'en_US').format(now.value);
    final t = DateFormat('h:mma', 'en_US').format(now.value).replaceAll(' ', '').toLowerCase();
    return '$d, $t'.obs;
  }

  String get tempText => tempC.value == 0.0 && weather.isEmpty
      ? '—'
      : '${tempC.value.toStringAsFixed(0)}°C';

  // --------- INTERNAL HELPERS ---------
  void _tick() => now.value = DateTime.now();

  Future<void> _fetchAndSetWeather() async {
    weatherLoading.value = true;
    try {
      // 1) Check permissions / get current position
      final hasLocation = await _ensureLocationPermission();
      if (!hasLocation) {
        Get.snackbar('Location', 'Permission denied. Weather requires location.');
        weatherLoading.value = false;
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(pos.latitude);
      print(pos.longitude);

      // 2) Call API
      final http.Response res = await _service.getTimeAndTemperature(
        pos.latitude.toStringAsFixed(6),
        pos.longitude.toStringAsFixed(6),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(res.body);
        final TimeDate td = TimeDate.fromJson(json);

        print(td);

        // 3) Push into observables
        weather.value = td.data?.weather ?? '';
        weatherDesc.value = td.data?.weatherDescription ?? '';
        final double? t = td.data?.tempCelsius;
        tempC.value = (t ?? 0).toDouble();

        serverDay.value = td.data?.dayName ?? '';
        serverTimeStr.value = td.data?.timeStr ?? '';

        await refreshIdeas();
      } else {
        final msg = _safeMsg(res.body);
        Get.snackbar('Weather', msg ?? 'Failed to fetch weather.');
      }
    } catch (e) {
      Get.snackbar('Weather', 'Unexpected error occurred');
      if (kDebugMode) print('Weather error: $e');
    } finally {
      weatherLoading.value = false;
    }
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  String? _safeMsg(String body) {
    try {
      final m = jsonDecode(body);
      return m['message']?.toString();
    } catch (_) {
      return null;
    }
  }

  bool get isOnDesktopAndWeb =>
      kIsWeb ||
          switch (defaultTargetPlatform) {
            TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows => true,
            TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => false,
          };

  void onDragUpdate(DragUpdateDetails details) {
    double next = sheetPosition.value - details.delta.dy / dragSensitivity;
    if (next < 0.25) next = 0.25;
    if (next > 1.0) next = 1.0;
    sheetPosition.value = next;
  }

  double convertToMiles(String input) {
    // Conversion factors
    const double metersInKm = 1000;
    const double metersInMile = 1609.34;

    // Split the string into value and unit
    final parts = input.trim().split(' ');
    if (parts.length != 2) {
      throw FormatException("Invalid input format. Example: '1 km' or '20 m'");
    }

    final double value = double.tryParse(parts[0]) ??
        (throw FormatException("Invalid number"));
    final String unit = parts[1].toLowerCase();

    // Convert input to meters
    double meters;
    switch (unit) {
      case 'km':
        meters = value * metersInKm;
        break;
      case 'm':
        meters = value;
        break;
      default:
        throw FormatException("Unsupported unit. Use 'm' or 'km'");
    }

    // Convert meters to miles
    return meters / metersInMile;
  }
}
