import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../data/model/action_places_details.dart';
import '../../../data/model/time_date.dart';
import '../../../data/model/top_5_place_list.dart';
import '../../../data/services/api_services.dart';

class HomeController extends GetxController {
  final now = DateTime.now().obs;
  Timer? _minuteTicker;
  Timer? _weatherTicker;

  // UI state
  RxList<RxBool> selectedCategory = [true.obs, false.obs, false.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedFilter   = [false.obs, false.obs, false.obs, false.obs, false.obs, false.obs].obs;
  RxBool isListView = true.obs;
  RxList<RxBool> selectedLocations = [false.obs, false.obs, false.obs, false.obs, false.obs].obs;
  final double dragSensitivity = 600;
  final RxDouble sheetPosition = 0.48.obs;
  final RxBool isMoreDetails = false.obs;
  final RxBool isMapClicked = false.obs;

  final ApiService _service = ApiService();

  // Weather/time data
  final RxBool weatherLoading = false.obs;
  final RxString weather = ''.obs;
  final RxString weatherDesc = ''.obs;
  final RxDouble tempC = 0.0.obs;
  final RxString serverDay = ''.obs;
  final RxString serverTimeStr = ''.obs;

  // Top 5 Lists variables
  final RxBool top5Loading = false.obs;
  final RxList<Places> top5Places = <Places>[].obs;

  // Manual location override
  final RxnDouble manualLat = RxnDouble(null);
  final RxnDouble manualLng = RxnDouble(null);
  final RxBool manualOverride = false.obs;

  // Search state
  final RxString searchText = ''.obs;

  // NEW: cache AI summaries by placeId
  final RxMap<String, List<String>> aiSummaries = <String, List<String>>{}.obs;

  final RxBool recentLoading = false.obs;
  final RxString recentError = ''.obs;
  final RxList<ActionPlace> recentPlaces = <ActionPlace>[].obs;
  final RxInt recentCount = 0.obs;
  final RxBool recentCountLoading = false.obs;

  final RxBool savedLoading = false.obs;
  final RxString savedError = ''.obs;
  final RxList<ActionPlace> savedPlaces = <ActionPlace>[].obs;
  final RxInt savedCount = 0.obs;
  final RxBool savedCountLoading = false.obs;

  final RxBool reservationLoading = false.obs;
  final RxString reservationError = ''.obs;
  final RxList<ActionPlace> reservationPlaces = <ActionPlace>[].obs;
  final RxInt reservationCount = 0.obs;
  final RxBool reservationCountLoading = false.obs;

  IconData get weatherIcon {
    final w = weather.value.toLowerCase();
    if (w.contains('clear') || w.contains('sun')) {
      return Icons.wb_sunny;
    } else if (w.contains('cloud')) {
      return Icons.cloud;
    } else if (w.contains('rain') || w.contains('drizzle')) {
      return Icons.grain;
    } else if (w.contains('storm') || w.contains('thunder')) {
      return Icons.flash_on;
    } else if (w.contains('snow')) {
      return Icons.ac_unit;
    } else if (w.contains('fog') || w.contains('mist') || w.contains('haze') || w.contains('smoke')) {
      return Icons.blur_on;
    } else {
      return Icons.wb_cloudy;
    }
  }

  Color get weatherIconColor {
    final w = weather.value.toLowerCase();
    if (w.contains('clear') || w.contains('sun')) {
      return const Color(0xFFFFD700);
    } else if (w.contains('rain') || w.contains('storm')) {
      return Colors.blueGrey;
    } else if (w.contains('snow')) {
      return Colors.lightBlueAccent;
    } else if (w.contains('fog') || w.contains('haze')) {
      return Colors.grey;
    } else {
      return Colors.lightBlue;
    }
  }

  final RxBool ideasLoading = false.obs;
  final RxList<String> ideas = <String>[].obs;

  String get _currentCategory {
    final i = selectedCategory.indexWhere((e) => e.value);
    switch (i) {
      case 0: return 'restaurant';
      case 1: return 'cafe';
      case 2: return 'bar';
      case 3: return 'activities';
      case 4:
      default: return 'services';
    }
  }

  String get _fallbackDayName => DateFormat('EEEE').format(DateTime.now());
  String get _fallbackTimeStr => DateFormat('hh:mm a').format(DateTime.now());

  Future<void> refreshIdeas() async {
    final wd = (weatherDesc.value.isNotEmpty ? weatherDesc.value : weather.value).toLowerCase();
    final day = (serverDay.value.isNotEmpty ? serverDay.value : _fallbackDayName);
    final tStr = (serverTimeStr.value.isNotEmpty ? serverTimeStr.value : _fallbackTimeStr);
    final temp = tempC.value;

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

  void onCategoryChanged(int index) {
    for (int i = 0; i < selectedCategory.length; i++) {
      selectedCategory[i].value = (i == index);
    }
    refreshIdeas();
    fetchTop5Places(search: searchText.value); // Refresh with current search
  }

  @override
  void onInit() {
    super.onInit();
    _tick();
    final firstDelay = Duration(seconds: 60 - DateTime.now().second);
    _minuteTicker = Timer(firstDelay, () {
      now.value = DateTime.now();
      _minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
        now.value = DateTime.now();
      });
    });
    _fetchAndSetWeather();
    _weatherTicker = Timer.periodic(const Duration(minutes: 10), (_) {
      _fetchAndSetWeather();
    });
    fetchSavedPlaces();
    fetchSavedCount();
    fetchReservationPlaces();
    fetchReservationCount();
  }

  @override
  void onClose() {
    _minuteTicker?.cancel();
    _weatherTicker?.cancel();
    super.onClose();
  }

  RxString get formatted {
    final d = DateFormat('EEE', 'en_US').format(now.value);
    final t = DateFormat('h:mma', 'en_US').format(now.value).replaceAll(' ', '').toLowerCase();
    return '$d, $t'.obs;
  }

  String get tempText => tempC.value == 0.0 && weather.isEmpty ? '—' : '${tempC.value.toStringAsFixed(0)}°C';

  void _tick() => now.value = DateTime.now();

  Future<void> _fetchAndSetWeather() async {
    if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
      await _fetchWeatherFor(manualLat.value!, manualLng.value!);
      await refreshIdeas();
      await fetchTop5Places(search: searchText.value);
      return;
    }
    final hasLocation = await _ensureLocationPermission();
    if (!hasLocation) {
      Get.snackbar('Location', 'Permission denied. Weather requires location.');
      return;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await _fetchWeatherFor(pos.latitude, pos.longitude);
    await refreshIdeas();
    await fetchTop5Places(search: searchText.value);
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
    const double metersInKm = 1000;
    const double metersInMile = 1609.34;
    final parts = input.trim().split(' ');
    if (parts.length != 2) {
      throw FormatException("Invalid input format. Example: '1 km' or '20 m'");
    }
    final double value = double.tryParse(parts[0]) ?? (throw FormatException("Invalid number"));
    final String unit = parts[1].toLowerCase();
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
    return meters / metersInMile;
  }

  String get currentCategoryLabel {
    final i = selectedCategory.indexWhere((e) => e.value);
    switch (i) {
      case 0: return 'Restaurant';
      case 1: return 'Cafes';
      case 2: return 'Bars';
      case 3: return 'Activities';
      case 4: return 'Services';
      default: return 'Services';
    }
  }

  String get _apiPlaceType {
    final i = selectedCategory.indexWhere((e) => e.value);
    switch (i) {
      case 0: return 'restaurant';
      case 1: return 'cafe';
      case 2: return 'bar';
      case 3: return 'activities';
      case 4: return 'services';
      default: return 'services';
    }
  }

  double parseMinutes(String? s) {
    if (s == null) return 0;
    final m = RegExp(r'(\d+)').firstMatch(s);
    if (m == null) return 0;
    return double.tryParse(m.group(1)!) ?? 0.0;
  }

  // Updated fetchTop5Places to include search and filters
  Future<void> fetchTop5Places({String? search}) async {
    top5Loading.value = true;
    try {
      double lat, lng;
      if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
        lat = manualLat.value!;
        lng = manualLng.value!;
      } else {
        final hasLoc = await _ensureLocationPermission();
        if (!hasLoc) {
          Get.snackbar('Location', 'Permission denied. Unable to fetch nearby places.');
          top5Loading.value = false;
          return;
        }
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      }

      // Apply filters
      final bool openNow = selectedFilter[0].value;
      final String? maxTime = selectedFilter[1].value ? '10m' : null;
      final double? radius = selectedFilter[2].value ? 1000 : null; // 1 km in meters
      final bool outdoor = selectedFilter[3].value;
      final bool vegetarian = selectedFilter[4].value;
      final bool bookable = selectedFilter[5].value;

      final res = await _service.top5PlaceList(
        lat,
        lng,
        _apiPlaceType,
        search: search,
        radius: radius,
        maxTime: maxTime,
        openNow: openNow,
        outdoor: outdoor,
        vegetarian: vegetarian,
        bookable: bookable,
      );

      if (res.statusCode == 200) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final list = Top5PlaceList.fromJson(map);
        top5Places.assignAll(list.places ?? <Places>[]);

        // NEW: lazily fetch AI summaries for visible places (cache)
        for (final p in top5Places) {
          final id = p.placeId ?? '';
          if (id.isNotEmpty && !aiSummaries.containsKey(id)) {
            _fetchAiForPlace(id);
          }
        }
      } else {
        final msg = _safeMsg(res.body) ?? 'Failed to fetch places.';
        Get.snackbar('Top 5', msg);
        top5Places.clear();
      }
    } catch (e) {
      Get.snackbar('Top 5', 'Unexpected error occurred');
      top5Places.clear();
    } finally {
      top5Loading.value = false;
    }
  }

  // NEW: per-place AI summary fetch + cache
  Future<void> _fetchAiForPlace(String placeId) async {
    try {
      final res = await _service.placeDetailsWithAi(placeId);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final List<String> summary = (data['ai_summary'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        aiSummaries[placeId] = summary;
      }
    } catch (_) {
      // silent fail; UI will simply show fallback text
    }
  }

  // NEW: helper to format up to 2 summary items as comma-separated text
  String aiSummaryTextFor(String? placeId) {
    if (placeId == null || placeId.isEmpty) return '';
    final list = aiSummaries[placeId] ?? const <String>[];
    if (list.isEmpty) return '';
    return list.take(2).join(', ');
  }

  Future<void> _fetchWeatherFor(double lat, double lng) async {
    weatherLoading.value = true;
    try {
      final http.Response res = await _service.getTimeAndTemperature(
        lat.toStringAsFixed(6),
        lng.toStringAsFixed(6),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(res.body);
        final TimeDate td = TimeDate.fromJson(json);

        weather.value      = td.data?.weather ?? '';
        weatherDesc.value  = td.data?.weatherDescription ?? '';
        tempC.value        = (td.data?.tempCelsius ?? 0).toDouble();
        serverDay.value    = td.data?.dayName ?? '';
        serverTimeStr.value= td.data?.timeStr ?? '';
      } else {
        Get.snackbar('Weather', _safeMsg(res.body) ?? 'Failed to fetch weather.');
      }
    } catch (e) {
      Get.snackbar('Weather', 'Unexpected error occurred');
    } finally {
      weatherLoading.value = false;
    }
  }

  Future<void> overrideLocationAndRefresh(double lat, double lng) async {
    manualLat.value = lat;
    manualLng.value = lng;
    manualOverride.value = true;

    await _fetchWeatherFor(lat, lng);
    await refreshIdeas();
    await fetchTop5Places(search: searchText.value);
  }

  // New: Handle search submission
  void performSearch(String query) {
    searchText.value = query;
    fetchTop5Places(search: query);
  }

  // New: Handle idea click
  void onIdeaClicked(String idea) {
    Get.toNamed('/search', arguments: {'searchText': idea});
  }

  // New: Place details
  final RxMap<dynamic, dynamic> placeDetails = {}.obs;
  final RxMap<dynamic, dynamic> placeAiDetails = {}.obs;
  final RxBool detailsLoading = false.obs;

  /// UPDATED: pass user's coordinates to place-details API
  Future<void> fetchPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return;
    if (placeDetails['place_id'] == placeId && placeAiDetails['place_id'] == placeId) return;

    detailsLoading.value = true;
    try {
      double lat, lng;
      if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
        lat = manualLat.value!;
        lng = manualLng.value!;
      } else {
        final hasLoc = await _ensureLocationPermission();
        if (!hasLoc) {
          Get.snackbar('Location', 'Permission denied. Unable to fetch place details.');
          detailsLoading.value = false;
          return;
        }
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      }

      final res1 = await _service.placeDetails(
        placeId,
        userLatitude: lat,
        userLongitude: lng,
      );
      if (res1.statusCode == 200) {
        placeDetails.value = jsonDecode(res1.body);
      } else {
        Get.snackbar('Details', _safeMsg(res1.body) ?? 'Failed to fetch place details.');
      }

      final res2 = await _service.placeDetailsWithAi(placeId);
      if (res2.statusCode == 200) {
        placeAiDetails.value = jsonDecode(res2.body);
      } else {
        Get.snackbar('Details', _safeMsg(res2.body) ?? 'Failed to fetch AI details.');
      }
    } catch (e) {
      Get.snackbar('Details', 'Unexpected error occurred');
    } finally {
      detailsLoading.value = false;
    }
  }


  /// Recents
  Future<void> submitActionPlaces(String placeId, String type) async {
    // Use specific loading state based on type
    if (type == 'recent') {
      recentLoading.value = true;
      recentError.value = '';
    } else if (type == 'saved' || type == 'saved-delete') {
      savedLoading.value = true;
      savedError.value = '';
    } else if (type == 'reservation' || type == 'reservation-delete') {
      reservationLoading.value = true;
      reservationError.value = '';
    }

    try {
      double lat, lng;
      if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
        lat = manualLat.value!;
        lng = manualLng.value!;
      } else {
        final hasLoc = await _ensureLocationPermission();
        if (!hasLoc) {
          if (type == 'recent') {
            recentError.value = 'Location permission denied.';
            recentPlaces.clear();
          } else if (type == 'saved' || type == 'saved-delete') {
            savedError.value = 'Location permission denied.';
            savedPlaces.clear();
          } else if (type == 'reservation' || type == 'reservation-delete') {
            reservationError.value = 'Location permission denied.';
            reservationPlaces.clear();
          }
          return;
        }
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      }

      final res = await _service.actionPlaces(placeId, lat.toString(), lng.toString(), type);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        Get.snackbar('Success', 'Action completed successfully');
      } else {
        final errorMsg = _safeMsg(res.body) ?? 'Failed to perform action.';
        if (type == 'recent') {
          recentError.value = errorMsg;
          recentPlaces.clear();
        } else if (type == 'saved' || type == 'saved-delete') {
          savedError.value = errorMsg;
          savedPlaces.clear();
        } else if (type == 'reservation' || type == 'reservation-delete') {
          reservationError.value = errorMsg;
          reservationPlaces.clear();
        }
      }
    } catch (e) {
      final errorMsg = 'Unexpected error.';
      if (type == 'recent') {
        recentError.value = errorMsg;
        recentPlaces.clear();
      } else if (type == 'saved' || type == 'saved-delete') {
        savedError.value = errorMsg;
        savedPlaces.clear();
      } else if (type == 'reservation' || type == 'reservation-delete') {
        reservationError.value = errorMsg;
        reservationPlaces.clear();
      }
    } finally {
      if (type == 'recent') {
        recentLoading.value = false;
      } else if (type == 'saved' || type == 'saved-delete') {
        savedLoading.value = false;
      } else if (type == 'reservation' || type == 'reservation-delete') {
        reservationLoading.value = false;
      }
    }
  }

  Future<void> fetchRecentPlaces() async {
    recentLoading.value = true;
    recentError.value = '';
    try {
      double lat, lng;
      if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
        lat = manualLat.value!;
        lng = manualLng.value!;
      } else {
        final hasLoc = await _ensureLocationPermission();
        if (!hasLoc) {
          recentError.value = 'Location permission denied.';
          recentPlaces.clear();
          recentLoading.value = false;
          return;
        }
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      }

      // API expects strings for lat/lng in this endpoint
      final res = await _service.actionPlacesDetails('recent', lat.toString(), lng.toString());

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final parsed = ActionPlacesDetails.fromJson(map);
        recentPlaces.assignAll(parsed.places ?? <ActionPlace>[]);
      } else {
        recentError.value = _safeMsg(res.body) ?? 'Failed to fetch recent places.';
        recentPlaces.clear();
      }
    } catch (e) {
      recentError.value = 'Unexpected error.';
      recentPlaces.clear();
    } finally {
      recentLoading.value = false;
    }
  }

  Future<void> fetchRecentCount() async {
    try {
      recentCountLoading.value = true;

      double lat, lng;
      if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
        lat = manualLat.value!;
        lng = manualLng.value!;
      } else {
        final hasLoc = await _ensureLocationPermission();
        if (!hasLoc) {
          recentCount.value = 0;
          recentCountLoading.value = false;
          return;
        }
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      }

      final res = await _service.actionPlacesDetails('recent', lat.toString(), lng.toString());
      if (res.statusCode == 200) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (map['places'] as List?) ?? const [];
        recentCount.value = list.length;
      } else {
        recentCount.value = 0;
      }
    } catch (_) {
      recentCount.value = 0;
    } finally {
      recentCountLoading.value = false;
    }
  }

  // Check if a place is saved
  bool isPlaceSaved(String? placeId) {
    if (placeId == null || placeId.isEmpty) return false;
    return savedPlaces.any((place) => place.placeId == placeId);
  }

  // Fetch saved places
  Future<void> fetchSavedPlaces() async {
    savedLoading.value = true;
    savedError.value = '';
    try {
      double lat, lng;
      if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
        lat = manualLat.value!;
        lng = manualLng.value!;
      } else {
        final hasLoc = await _ensureLocationPermission();
        if (!hasLoc) {
          savedError.value = 'Location permission denied.';
          savedPlaces.clear();
          savedLoading.value = false;
          return;
        }
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      }

      final res = await _service.actionPlacesDetails('saved', lat.toString(), lng.toString());

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final parsed = ActionPlacesDetails.fromJson(map);
        savedPlaces.assignAll(parsed.places ?? <ActionPlace>[]);
      } else {
        savedError.value = _safeMsg(res.body) ?? 'Failed to fetch saved places.';
        savedPlaces.clear();
      }
    } catch (e) {
      savedError.value = 'Unexpected error.';
      savedPlaces.clear();
    } finally {
      savedLoading.value = false;
    }
  }

  // Fetch saved places count
  Future<void> fetchSavedCount() async {
    try {
      savedCountLoading.value = true;

      double lat, lng;
      if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
        lat = manualLat.value!;
        lng = manualLng.value!;
      } else {
        final hasLoc = await _ensureLocationPermission();
        if (!hasLoc) {
          savedCount.value = 0;
          savedCountLoading.value = false;
          return;
        }
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      }

      final res = await _service.actionPlacesDetails('saved', lat.toString(), lng.toString());
      if (res.statusCode == 200) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (map['places'] as List?) ?? const [];
        savedCount.value = list.length;
      } else {
        savedCount.value = 0;
      }
    } catch (_) {
      savedCount.value = 0;
    } finally {
      savedCountLoading.value = false;
    }
  }

  // Check if a place is reserved
  bool isPlaceReserved(String? placeId) {
    if (placeId == null || placeId.isEmpty) return false;
    return reservationPlaces.any((place) => place.placeId == placeId);
  }

  // Fetch reservation places
  Future<void> fetchReservationPlaces() async {
    reservationLoading.value = true;
    reservationError.value = '';
    try {
      double lat, lng;
      if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
        lat = manualLat.value!;
        lng = manualLng.value!;
      } else {
        final hasLoc = await _ensureLocationPermission();
        if (!hasLoc) {
          reservationError.value = 'Location permission denied.';
          reservationPlaces.clear();
          reservationLoading.value = false;
          return;
        }
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      }

      final res = await _service.actionPlacesDetails('reservation', lat.toString(), lng.toString());

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final parsed = ActionPlacesDetails.fromJson(map);
        reservationPlaces.assignAll(parsed.places ?? <ActionPlace>[]);
      } else {
        reservationError.value = _safeMsg(res.body) ?? 'Failed to fetch reservation places.';
        reservationPlaces.clear();
      }
    } catch (e) {
      reservationError.value = 'Unexpected error.';
      reservationPlaces.clear();
    } finally {
      reservationLoading.value = false;
    }
  }

  // Fetch reservation places count
  Future<void> fetchReservationCount() async {
    try {
      reservationCountLoading.value = true;

      double lat, lng;
      if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
        lat = manualLat.value!;
        lng = manualLng.value!;
      } else {
        final hasLoc = await _ensureLocationPermission();
        if (!hasLoc) {
          reservationCount.value = 0;
          reservationCountLoading.value = false;
          return;
        }
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      }

      final res = await _service.actionPlacesDetails('reservation', lat.toString(), lng.toString());
      if (res.statusCode == 200) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final list = (map['places'] as List?) ?? const [];
        reservationCount.value = list.length;
      } else {
        reservationCount.value = 0;
      }
    } catch (_) {
      reservationCount.value = 0;
    } finally {
      reservationCountLoading.value = false;
    }
  }
}
