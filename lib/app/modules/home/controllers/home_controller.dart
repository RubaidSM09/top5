import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:top5/app/modules/subscription/views/subscription_dialog_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/model/action_places_details.dart';
import '../../../data/model/time_date.dart';
import '../../../data/model/top_5_place_list.dart';
import '../../../data/services/api_services.dart';

class HomeController extends GetxController {
  final now = DateTime.now().obs;
  Timer? _minuteTicker;
  Timer? _weatherTicker;

  // UI state
  RxList<RxBool> selectedCategory = [true.obs, false.obs, false.obs, false.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedFilter   = [false.obs, false.obs, false.obs, false.obs, false.obs, false.obs].obs;
  RxBool isListView = true.obs;
  RxList<RxBool> selectedLocations = [false.obs, false.obs, false.obs, false.obs, false.obs].obs;
  final double dragSensitivity = 600;
  final RxDouble sheetPosition = 0.48.obs;
  final RxBool isMoreDetails = false.obs;
  final RxBool isMapClicked = false.obs;

  final RxBool navigatedFromQuickGlance = false.obs;

  // ========= Activities / Services category hierarchy =========
  final List<CategoryNode> activitiesCategories = const [
    CategoryNode(
      id: 'activities_must_see_culture',
      label: 'Must-See & Culture',
      children: [
        CategoryNode(id: 'museum',   label: 'Museum'),
        CategoryNode(id: 'park',     label: 'Park'),
        CategoryNode(id: 'church',   label: 'Church'),
        CategoryNode(id: 'mosque',   label: 'Mosque'),
        CategoryNode(id: 'synagogue',label: 'Synagogue'),
      ],
    ),
    CategoryNode(
      id: 'activities_entertainment_nightlife',
      label: 'Entertainment & Nightlife',
      children: [
        CategoryNode(id: 'night_club',    label: 'Night Club'),
        CategoryNode(id: 'movie_theater', label: 'Movie Theater'),
        CategoryNode(id: 'casino',        label: 'Casino'),
        CategoryNode(id: 'stadium',       label: 'Stadium'),
      ],
    ),
    CategoryNode(
      id: 'activities_local_experiences',
      label: 'Local Experiences',
      children: [
        CategoryNode(id: 'park',          label: 'Park'),
        CategoryNode(id: 'museum',        label: 'Museum'),
        CategoryNode(id: 'travel_agency', label: 'Travel Agency'),
      ],
    ),
    CategoryNode(
      id: 'activities_day_trips_parks',
      label: 'Day Trips & Parks',
      children: [
        CategoryNode(id: 'park',   label: 'Park'),
        CategoryNode(id: 'museum', label: 'Museum'),
      ],
    ),
  ];

  final List<CategoryNode> servicesCategories = const [
    CategoryNode(
      id: 'services_hotels',
      label: 'Hotels',
      children: [
        CategoryNode(id: 'lodging', label: 'Lodging'),
      ],
    ),
    CategoryNode(
      id: 'services_hairdressers',
      label: 'Hairdressers',
      children: [
        CategoryNode(id: 'hair_care', label: 'Hair Care'),
      ],
    ),
    CategoryNode(
      id: 'services_beauty_salon',
      label: 'Beauty Salons',
      children: [
        CategoryNode(id: 'beauty_salon', label: 'Beauty Salon'),
      ],
    ),
    CategoryNode(
      id: 'services_spa_massage',
      label: 'Spa & Massage',
      children: [
        CategoryNode(id: 'spa', label: 'Spa'),
      ],
    ),
    CategoryNode(
      id: 'services_gyms',
      label: 'Gyms',
      children: [
        CategoryNode(id: 'gym', label: 'Gym'),
      ],
    ),
    CategoryNode(
      id: 'services_coworking_spaces',
      label: 'Coworking Spaces',
      children: [
        CategoryNode(id: 'library', label: 'Library'),
        CategoryNode(id: 'local_government_office', label: 'Office Building'),
      ],
    ),
    CategoryNode(
      id: 'services_health_wellness',
      label: 'Health & Wellness',
      children: [
        CategoryNode(id: 'doctor',         label: 'Doctor'),
        CategoryNode(id: 'hospital',       label: 'Hospital'),
        CategoryNode(id: 'pharmacy',       label: 'Pharmacy'),
        CategoryNode(id: 'physiotherapist',label: 'Physiotherapist'),
        CategoryNode(id: 'health',         label: 'Health Service'),
        CategoryNode(id: 'dentist',        label: 'Dentist'),
        CategoryNode(id: 'spa',            label: 'Spa'),
      ],
    ),
  ];

  final List<CategoryNode> superShopsCategories = const [
    CategoryNode(
      id: 'super_shops_big_retails',
      label: 'Big Retails',
      children: [
        CategoryNode(id: 'shopping_mall', label: 'Shopping Mall'),
        CategoryNode(id: 'department_store', label: 'Department Store'),
        CategoryNode(id: 'store', label: 'Store'),
        CategoryNode(id: 'supermarket', label: 'Super Market'),
      ],
    ),
    CategoryNode(
      id: 'super_shops_everyday_convenience',
      label: 'Everyday / Convenience',
      children: [
        CategoryNode(id: 'convenience_store', label: 'Convenience Store'),
        CategoryNode(id: 'home_goods_store', label: 'Home Goods Store'),
        CategoryNode(id: 'furniture_store', label: 'Furniture Store'),
        CategoryNode(id: 'hardware_store', label: 'Hardware Store'),
        CategoryNode(id: 'electronics_store', label: 'Electronics Store'),
        CategoryNode(id: 'gas_station', label: 'Gas Station'),
      ],
    ),
    CategoryNode(
      id: 'super_shops_specialty_retail',
      label: 'Specialty Retail',
      children: [
        CategoryNode(id: 'clothing_store', label: 'Clothing Store'),
        CategoryNode(id: 'shoe_store', label: 'Shoe Store'),
        CategoryNode(id: 'jewelry_store', label: 'Jewelry Store'),
        CategoryNode(id: 'book_store', label: 'Book Store'),
        CategoryNode(id: 'florist', label: 'Florist'),
        CategoryNode(id: 'pet_store', label: 'Pet Store'),
      ],
    ),
  ];

  // state for selected sub / sub-sub categories
  final Rx<CategoryNode?> selectedActivitiesParent = Rx<CategoryNode?>(null);
  final Rx<CategoryNode?> selectedActivitiesChild  = Rx<CategoryNode?>(null);
  final Rx<CategoryNode?> selectedServicesParent   = Rx<CategoryNode?>(null);
  final Rx<CategoryNode?> selectedServicesChild    = Rx<CategoryNode?>(null);
  final Rx<CategoryNode?> selectedSuperShopsParent   = Rx<CategoryNode?>(null);
  final Rx<CategoryNode?> selectedSuperShopsChild    = Rx<CategoryNode?>(null);

  // === FOR HOME VIEW (existing) ===
  final RxBool showActivitiesDropdown = false.obs;
  final RxBool showServicesDropdown   = false.obs;
  final RxBool showSuperShopsDropdown   = false.obs;

  // === NEW: FOR SERVICE VIEW ONLY (independent) ===
  final RxBool showActivitiesDropdownService = false.obs;
  final RxBool showServicesDropdownService   = false.obs;
  final RxBool showSuperShopsDropdownService   = false.obs;

  // whether quick-glance subcategories are visible (below Quick Glance cards)
  final RxBool showActivitiesQuickGlance = false.obs;
  final RxBool showServicesQuickGlance   = false.obs;
  final RxBool showSuperShopsQuickGlance   = false.obs;

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

  final RxnDouble userLat = RxnDouble(null);
  final RxnDouble userLng = RxnDouble(null);

  // Search state
  final RxString searchText = ''.obs;

  // cache AI summaries by placeId
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

  /// Category used by ideas & Top 5 API. For Activities/Services we use
  /// the selected sub-sub-category ID when available.
  String get _currentCategory {
    final i = selectedCategory.indexWhere((e) => e.value);
    switch (i) {
      case 0:
        return 'restaurant';
      case 1:
        return 'cafe';
      case 2:
        return 'bar';
      case 3:
        if (selectedActivitiesChild.value != null) {
          return selectedActivitiesChild.value!.id;
        }
        return 'activities';
      case 4:
        if (selectedServicesChild.value != null) {
          return selectedServicesChild.value!.id;
        }
        return 'super_shops';
      case 5:
        if (selectedSuperShopsChild.value != null) {
          return selectedSuperShopsChild.value!.id;
        }
        return 'super_shops';
      default:
        return 'services';
    }
  }

  // kept for compatibility (not used by API anymore)
  String get _apiPlaceType {
    final i = selectedCategory.indexWhere((e) => e.value);
    switch (i) {
      case 0:
        return 'restaurant';
      case 1:
        return 'cafe';
      case 2:
        return 'bar';
      case 3:
        return 'activities';
      case 4:
        return 'services';
      case 5:
        return 'super_shops';
      default:
        return 'services';
    }
  }

  void selectActivitiesParent(CategoryNode node) {
    selectedActivitiesParent.value = node;
    selectedActivitiesChild.value = null;
  }

  // *** CHANGED: added flag to avoid idea generation from Quick Glance
  void selectActivitiesChild(CategoryNode node, {bool refreshIdeasFlag = true}) {
    selectedActivitiesChild.value = node;
    _closeAllCategoryDropdowns();
    if (refreshIdeasFlag) {
      refreshIdeas();
    }
  }

  void selectServicesParent(CategoryNode node) {
    selectedServicesParent.value = node;
    selectedServicesChild.value = null;
  }

  // *** CHANGED: added flag to avoid idea generation from Quick Glance
  void selectServicesChild(CategoryNode node, {bool refreshIdeasFlag = true}) {
    selectedServicesChild.value = node;
    _closeAllCategoryDropdowns();
    if (refreshIdeasFlag) {
      refreshIdeas();
    }
  }

  void selectSuperShopsParent(CategoryNode node) {
    selectedSuperShopsParent.value = node;
    selectedSuperShopsChild.value = null;
  }

  // *** CHANGED: added flag to avoid idea generation from Quick Glance
  void selectSuperShopsChild(CategoryNode node, {bool refreshIdeasFlag = true}) {
    selectedSuperShopsChild.value = node;
    _closeAllCategoryDropdowns();
    if (refreshIdeasFlag) {
      refreshIdeas();
    }
  }

  String get _fallbackDayName => DateFormat('EEEE').format(DateTime.now());
  String get _fallbackTimeStr => DateFormat('hh:mm a').format(DateTime.now());

  Future<void> refreshIdeas() async {
    // If we are on Activities or Services but no sub-sub-category selected,
    // do NOT refresh ideas (keep the current ones).
    final currentIndex = selectedCategory.indexWhere((e) => e.value);
    if ((currentIndex == 3 && selectedActivitiesChild.value == null) ||
        (currentIndex == 4 && selectedServicesChild.value == null) ||
        (currentIndex == 5 && selectedSuperShopsChild.value == null)) {
      return;
    }

    final wd = (weatherDesc.value.isNotEmpty ? weatherDesc.value : weather.value).toLowerCase();
    final day = (serverDay.value.isNotEmpty ? serverDay.value : _fallbackDayName);
    final tStr = (serverTimeStr.value.isNotEmpty ? serverTimeStr.value : _fallbackTimeStr);
    final temp = tempC.value;
    final category = _currentCategory;

    ideasLoading.value = true;
    try {
      final res = await _service.generateIdeas(wd, day, tStr, temp, category);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final List<dynamic> raw = (json['ideas_list'] ?? []) as List<dynamic>;
        ideas.assignAll(raw.map((e) => e.toString()));
      } else if (res.statusCode == 403) {
        final Map<String, dynamic> json = jsonDecode(res.body);
        if (json['error'] == 'You have reached your plan limit for places.') {
          Get.dialog(SubscriptionDialogView(purpose: 'Ideas'));
        }
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

  void onCategoryChangedHome(int index) {
    showActivitiesQuickGlance.value = false;
    showServicesQuickGlance.value   = false;
    showSuperShopsQuickGlance.value   = false;

    for (int i = 0; i < selectedCategory.length; i++) {
      selectedCategory[i].value = (i == index);
    }

    // Use Home-specific dropdown flags
    showActivitiesDropdown.value = (index == 3);
    showServicesDropdown.value   = (index == 4);
    showSuperShopsDropdown.value   = (index == 5);

    if (index != 3) {
      selectedActivitiesParent.value = null;
      selectedActivitiesChild.value  = null;
    }
    if (index != 4) {
      selectedServicesParent.value = null;
      selectedServicesChild.value  = null;
    }
    if (index != 5) {
      selectedSuperShopsParent.value = null;
      selectedSuperShopsChild.value  = null;
    }

    refreshIdeas();
  }

  void onCategoryChangedService(int index) {
    showActivitiesQuickGlance.value = false;
    showServicesQuickGlance.value   = false;
    showSuperShopsQuickGlance.value   = false;

    for (int i = 0; i < selectedCategory.length; i++) {
      selectedCategory[i].value = (i == index);
    }

    // Use Service-specific dropdown flags
    showActivitiesDropdownService.value = (index == 3);
    showServicesDropdownService.value   = (index == 4);
    showSuperShopsDropdownService.value   = (index == 5);

    if (index != 3) {
      selectedActivitiesParent.value = null;
      selectedActivitiesChild.value  = null;
    }
    if (index != 4) {
      selectedServicesParent.value = null;
      selectedServicesChild.value  = null;
    }
    if (index != 5) {
      selectedSuperShopsParent.value = null;
      selectedSuperShopsChild.value  = null;
    }

    if (index <= 2) {
      fetchTop5Places(search: searchText.value);
    } else if (index == 3 && selectedActivitiesChild.value != null) {
      fetchTop5Places(search: searchText.value);
    } else if (index == 4 && selectedServicesChild.value != null) {
      fetchTop5Places(search: searchText.value);
    } else if (index == 5 && selectedSuperShopsChild.value != null) {
      fetchTop5Places(search: searchText.value);
    }
  }

  void resetHeaderSelectionIfFromQuickGlance() {
    if (!navigatedFromQuickGlance.value) return;

    for (int i = 0; i < selectedCategory.length; i++) {
      selectedCategory[i].value = (i == 0);
    }

    // Reset BOTH Home and Service dropdowns
    showActivitiesDropdown.value = false;
    showServicesDropdown.value   = false;
    showSuperShopsDropdown.value   = false;
    showActivitiesDropdownService.value = false;
    showServicesDropdownService.value   = false;
    showSuperShopsDropdownService.value   = false;

    selectedActivitiesParent.value = null;
    selectedActivitiesChild.value  = null;
    selectedServicesParent.value   = null;
    selectedServicesChild.value    = null;
    selectedSuperShopsParent.value   = null;
    selectedSuperShopsChild.value    = null;

    navigatedFromQuickGlance.value = false;
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
      case 5: return 'Super-shops';
      default: return 'Services';
    }
  }

  double parseMinutes(String? s) {
    if (s == null) return 0;
    final m = RegExp(r'(\d+)').firstMatch(s);
    if (m == null) return 0;
    return double.tryParse(m.group(1)!) ?? 0.0;
  }

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

      userLat.value = lat;
      userLng.value = lng;

      // Apply filters
      final bool openNow = selectedFilter[0].value;
      final String? maxTime = selectedFilter[1].value ? '10m' : null;
      final double? radius = selectedFilter[2].value ? 1000 : null; // 1 km in meters
      final bool outdoor = selectedFilter[3].value;
      final bool vegetarian = selectedFilter[4].value;
      final bool bookable = selectedFilter[5].value;

      final category = _currentCategory;

      final res = await _service.top5PlaceList(
        lat,
        lng,
        category,
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
      } else if (res.statusCode == 403) {
        final Map<String, dynamic> json = jsonDecode(res.body);
        if (json['error'] == 'You have reached your plan limit for places.') {
          Get.dialog(SubscriptionDialogView(purpose: 'Place list'));
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
    } catch (_) {}
  }

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
      } else if (res.statusCode == 403) {
        final Map<String, dynamic> json = jsonDecode(res.body);
        if (json['error'] == 'You have reached your plan limit for places.') {
          Get.dialog(SubscriptionDialogView(purpose: 'Weather Info'));
        }
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

    userLat.value = lat;
    userLng.value = lng;

    await _fetchWeatherFor(lat, lng);
    await refreshIdeas();
    await fetchTop5Places(search: searchText.value);
  }

  void performSearch(String query) {
    searchText.value = query;
    fetchTop5Places(search: query);
  }

  void onIdeaClicked(String idea) {
    Get.toNamed('/search', arguments: {'searchText': idea});
  }

  final RxMap<dynamic, dynamic> placeDetails = {}.obs;
  final RxMap<dynamic, dynamic> placeAiDetails = {}.obs;
  final RxBool detailsLoading = false.obs;

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

  Future<void> submitActionPlaces(
      String placeId,
      double latitude,
      double longitude,
      String placeName,
      double rating,
      String directionUrl,
      String phone,
      String email,
      String website,
      String priceCurrency,
      String activityType,
      String image,
      ) async {
    if (activityType == 'saved' || activityType == 'saved-delete') {
      savedLoading.value = true;
      savedError.value = '';
    }

    try {
      double lat, lng;
      if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
        lat = manualLat.value!;
        lng = manualLng.value!;
      } else {
        final hasLoc = await _ensureLocationPermission();
        if (!hasLoc) {
          if (activityType == 'saved' || activityType == 'saved-delete') {
            savedError.value = 'Location permission denied.';
            savedPlaces.clear();
          }
          return;
        }
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
      }

      final res = await _service.actionPlaces(
        placeId,
        latitude,
        longitude,
        placeName,
        rating,
        directionUrl,
        phone,
        email,
        website,
        priceCurrency,
        activityType,
        image,
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        Get.snackbar('Success', 'Action completed successfully');
      } else {
        final errorMsg = _safeMsg(res.body) ?? 'Failed to perform action.';
        if (activityType == 'saved' || activityType == 'saved-delete') {
          savedError.value = errorMsg;
          savedPlaces.clear();
        }
      }
    } catch (e) {
      final errorMsg = 'Unexpected error.';
      if (activityType == 'saved' || activityType == 'saved-delete') {
        savedError.value = errorMsg;
        savedPlaces.clear();
      }
    } finally {
      if (activityType == 'saved' || activityType == 'saved-delete') {
        savedLoading.value = false;
      }
    }
  }

  bool isPlaceSaved(String? placeId) {
    if (placeId == null || placeId.isEmpty) return false;
    return savedPlaces.any((place) => place.placeId == placeId);
  }

  Future<void> fetchSavedPlaces() async {
    savedLoading.value = true;
    savedError.value = '';
    try {
      final res = await _service.actionPlacesDetails();

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final parsed = ActionPlacesDetails.fromJson(map);
        savedPlaces.assignAll(parsed.actionPlace ?? <ActionPlace>[]);
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

  void _closeAllCategoryDropdowns() {
    // Home header dropdowns
    showActivitiesDropdown.value = false;
    showServicesDropdown.value = false;
    showSuperShopsDropdown.value = false;

    // Service header dropdowns
    showActivitiesDropdownService.value = false;
    showServicesDropdownService.value = false;
    showSuperShopsDropdownService.value = false;
  }

  Future<void> openGoogleMapsAppDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String travelMode = 'walking',
  }) async {
    if (!kIsWeb && Platform.isAndroid) {
      final modeChar = switch (travelMode) {
        'walking' => 'w',
        'bicycling' => 'b',
        'transit' => 'r',
        _ => 'd',
      };
      final androidUri = Uri.parse('google.navigation:q=$destLat,$destLng&mode=$modeChar');
      if (await canLaunchUrl(androidUri)) {
        await launchUrl(androidUri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (!kIsWeb && Platform.isIOS) {
      final iosUri = Uri.parse(
        'comgooglemaps://?saddr=$originLat,$originLng&daddr=$destLat,$destLng&directionsmode=$travelMode',
      );
      if (await canLaunchUrl(iosUri)) {
        await launchUrl(iosUri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&origin=$originLat,$originLng'
          '&destination=$destLat,$destLng'
          '&travelmode=$travelMode',
    );
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  Future<void> openDirectionsTo({
    required double destLat,
    required double destLng,
    String travelMode = 'walking',
  }) async {
    double oLat, oLng;
    if (manualOverride.value && manualLat.value != null && manualLng.value != null) {
      oLat = manualLat.value!;
      oLng = manualLng.value!;
    } else {
      final hasLoc = await _ensureLocationPermission();
      if (!hasLoc) {
        Get.snackbar('Location', 'Permission denied for location.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      oLat = pos.latitude;
      oLng = pos.longitude;
    }

    await openGoogleMapsAppDirections(
      originLat: oLat,
      originLng: oLng,
      destLat: destLat,
      destLng: destLng,
      travelMode: travelMode,
    );
  }

  Future<void> openGoogleAppSearch(String query) async {
    final encoded = Uri.encodeComponent(query.trim());

    if (!kIsWeb && Platform.isIOS) {
      final fallback = Uri.parse("https://www.google.com/search?q=$encoded");
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
      return;
    }

    final googleAppIntent = Uri.parse(
        "intent://www.google.com/search?q=$encoded#Intent;"
            "package=com.google.android.googlequicksearchbox;"
            "scheme=https;"
            "end"
    );

    try {
      final canOpenGoogleApp = await launchUrl(
        googleAppIntent,
        mode: LaunchMode.externalApplication,
      );

      if (!canOpenGoogleApp) {
        throw "Google App not available";
      }
    } catch (_) {
      final fallback = Uri.parse("https://www.google.com/search?q=$encoded");
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }
}

class CategoryNode {
  final String id;
  final String label;
  final List<CategoryNode> children;

  const CategoryNode({
    required this.id,
    required this.label,
    this.children = const [],
  });
}
