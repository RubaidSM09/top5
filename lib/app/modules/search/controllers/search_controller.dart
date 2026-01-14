import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../data/model/top_5_place_list.dart';
import '../../../data/services/api_services.dart';
import '../../home/controllers/home_controller.dart';
import '../../subscription/views/subscription_dialog_view.dart';

class SearchController extends GetxController {
  /// ===================== UI fields (UPDATED) =====================
  /// Start empty, show hint "Search Place"
  final TextEditingController searchBarTextController = TextEditingController();

  final List<Worker> _filterWorkers = [];

  /// hint text for input
  final RxString searchHint = 'Search Place'.obs;

  RxList<RxBool> isRemoved =
      [false.obs, false.obs, false.obs, false.obs, false.obs].obs;

  RxList<RxBool> selectedCategory =
      [true.obs, false.obs, false.obs, false.obs, false.obs, false.obs].obs;

  RxList<RxBool> selectedFilter = [
    true.obs,
    false.obs,
    false.obs,
    false.obs,
    false.obs,
    false.obs
  ].obs;

  /// ========= Activities / Services category hierarchy (for Search) =========
  final List<CategoryNode> activitiesCategories = const [
    CategoryNode(
      id: 'activities_must_see_culture',
      label: 'Must-See & Culture',
      children: [
        CategoryNode(id: 'museum', label: 'Museum'),
        CategoryNode(id: 'park', label: 'Park'),
        CategoryNode(id: 'church', label: 'Church'),
        CategoryNode(id: 'mosque', label: 'Mosque'),
        CategoryNode(id: 'synagogue', label: 'Synagogue'),
      ],
    ),
    CategoryNode(
      id: 'activities_entertainment_nightlife',
      label: 'Entertainment & Nightlife',
      children: [
        CategoryNode(id: 'night_club', label: 'Night Club'),
        CategoryNode(id: 'movie_theater', label: 'Movie Theater'),
        CategoryNode(id: 'casino', label: 'Casino'),
        CategoryNode(id: 'stadium', label: 'Stadium'),
      ],
    ),
    CategoryNode(
      id: 'activities_local_experiences',
      label: 'Local Experiences',
      children: [
        CategoryNode(id: 'park', label: 'Park'),
        CategoryNode(id: 'museum', label: 'Museum'),
        CategoryNode(id: 'travel_agency', label: 'Travel Agency'),
      ],
    ),
    CategoryNode(
      id: 'activities_day_trips_parks',
      label: 'Day Trips & Parks',
      children: [
        CategoryNode(id: 'park', label: 'Park'),
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
        CategoryNode(id: 'doctor', label: 'Doctor'),
        CategoryNode(id: 'hospital', label: 'Hospital'),
        CategoryNode(id: 'pharmacy', label: 'Pharmacy'),
        CategoryNode(id: 'physiotherapist', label: 'Physiotherapist'),
        CategoryNode(id: 'health', label: 'Health Service'),
        CategoryNode(id: 'dentist', label: 'Dentist'),
        CategoryNode(id: 'spa', label: 'Spa'),
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

  // State for selected sub / sub-sub categories (Search)
  final Rx<CategoryNode?> selectedActivitiesParent = Rx<CategoryNode?>(null);
  final Rx<CategoryNode?> selectedActivitiesChild = Rx<CategoryNode?>(null);
  final Rx<CategoryNode?> selectedServicesParent = Rx<CategoryNode?>(null);
  final Rx<CategoryNode?> selectedServicesChild = Rx<CategoryNode?>(null);
  final Rx<CategoryNode?> selectedSuperShopsParent = Rx<CategoryNode?>(null);
  final Rx<CategoryNode?> selectedSuperShopsChild = Rx<CategoryNode?>(null);

  // Whether dropdown is open (Search)
  final RxBool showActivitiesDropdown = false.obs;
  final RxBool showServicesDropdown = false.obs;
  final RxBool showSuperShopsDropdown = false.obs;

  /// State for API + results
  final ApiService _api = ApiService();

  /// WHAT YOU SHOW IN TITLE: "Top 5 ____"
  final RxString searchText = ''.obs;

  /// WHAT YOU SEND TO API
  final RxString searchQuery = ''.obs;

  final RxList<Places> results = <Places>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  final RxBool isMoreDetails = false.obs;

  /// Keep origin to send with API
  final RxDouble originLat = 0.0.obs;
  final RxDouble originLng = 0.0.obs;

  /// Place details and AI summaries
  final RxMap<dynamic, dynamic> placeDetails = {}.obs;
  final RxMap<dynamic, dynamic> placeAiDetails = {}.obs;
  final RxBool detailsLoading = false.obs;
  final RxMap<String, List<String>> aiSummaries = <String, List<String>>{}.obs;

  /// Debounce so we don’t spam API per key stroke
  Timer? _debounce;

  /// ===================== NEW HELPERS =====================
  void setSearchHint(String hint) {
    searchHint.value = hint;
  }

  /// Use this for submit / voice / recent chip tap, etc.
  void setSearchQuery(String query, {bool fetchNow = true}) {
    final q = query.trim();

    // UI Text
    searchText.value = q;

    // API Query
    searchQuery.value = q;

    // Put into input field as actual text (not hint)
    searchBarTextController.text = q;
    searchBarTextController.selection = TextSelection.collapsed(offset: q.length);

    if (!fetchNow) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      fetchTop5();
    });
  }

  /// For typing listener (no cursor override)
  void syncTypingToQuery(String query) {
    final q = query.trimLeft(); // keep natural typing (don’t trimRight here)
    searchText.value = q.trim();
    searchQuery.value = q.trim();
  }

  int _selectedCategoryIndex() {
    for (int i = 0; i < selectedCategory.length; i++) {
      if (selectedCategory[i].value) return i;
    }
    return 0;
  }

  void selectCategory(int index) {
    for (int i = 0; i < selectedCategory.length; i++) {
      selectedCategory[i].value = (i == index);
    }

    showActivitiesDropdown.value = (index == 3);
    showServicesDropdown.value = (index == 4);
    showSuperShopsDropdown.value = (index == 5);

    if (index != 3) {
      selectedActivitiesParent.value = null;
      selectedActivitiesChild.value = null;
    }
    if (index != 4) {
      selectedServicesParent.value = null;
      selectedServicesChild.value = null;
    }
    if (index != 5) {
      selectedSuperShopsParent.value = null;
      selectedSuperShopsChild.value = null;
    }

    // Fetch immediately only for Restaurant/Cafes/Bars
    if (index == 0 || index == 1 || index == 2) {
      fetchTop5();
    }
  }

  void selectActivitiesParent(CategoryNode node) {
    selectedActivitiesParent.value = node;
    selectedActivitiesChild.value = null;
  }

  void selectActivitiesChild(CategoryNode node) {
    selectedActivitiesChild.value = node;
    _closeAllCategoryDropdowns();
    fetchTop5();
  }

  void selectServicesParent(CategoryNode node) {
    selectedServicesParent.value = node;
    selectedServicesChild.value = null;
  }

  void selectServicesChild(CategoryNode node) {
    selectedServicesChild.value = node;
    _closeAllCategoryDropdowns();
    fetchTop5();
  }

  void selectSuperShopsParent(CategoryNode node) {
    selectedSuperShopsParent.value = node;
    selectedSuperShopsChild.value = null;
  }

  void selectSuperShopsChild(CategoryNode node) {
    selectedSuperShopsChild.value = node;
    _closeAllCategoryDropdowns();
    fetchTop5();
  }

  String _placeTypeFromSelection() {
    switch (_selectedCategoryIndex()) {
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
        return 'services';
      case 5:
        if (selectedSuperShopsChild.value != null) {
          return selectedSuperShopsChild.value!.id;
        }
        return 'super_shops';
      default:
        return 'restaurant';
    }
  }

  ({
  bool? openNow,
  double? radius,
  String? maxTime,
  String? mode,
  bool? outdoor,
  bool? vegetarian,
  bool? bookable
  }) _filtersFromChips() {
    final openNow = selectedFilter[0].value ? true : null;
    final tenMin = selectedFilter[1].value;
    final oneKm = selectedFilter[2].value;
    final outdoor = selectedFilter[3].value ? true : null;
    final vegetarian = selectedFilter[4].value ? true : null;
    final bookable = selectedFilter[5].value ? true : null;

    return (
    openNow: openNow,
    radius: oneKm ? 500.0 : null,
    maxTime: tenMin ? '10m' : null,
    mode: null,
    outdoor: outdoor,
    vegetarian: vegetarian,
    bookable: bookable
    );
  }

  Future<bool> _ensureOrigin() async {
    final hc = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

    if (hc != null && hc.manualOverride.value && hc.manualLat.value != null && hc.manualLng.value != null) {
      originLat.value = hc.manualLat.value!;
      originLng.value = hc.manualLng.value!;
      return true;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return false;
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    originLat.value = pos.latitude;
    originLng.value = pos.longitude;
    return true;
  }

  Map<String, dynamic> _parseJsonObject(String body) {
    try {
      final d = json.decode(body);
      return d is Map<String, dynamic> ? d : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> fetchTop5() async {
    loading.value = true;
    error.value = '';

    try {
      final ok = await _ensureOrigin();
      if (!ok) {
        error.value = 'Location permission/service is required.';
        return; // ✅ IMPORTANT: don’t clear results / don’t call API with 0,0
      }

      final placeType = _placeTypeFromSelection();
      final filters = _filtersFromChips();

      final resp = await _api.top5PlaceList(
        originLat.value,
        originLng.value,
        placeType,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        radius: filters.radius,
        maxTime: filters.maxTime,
        mode: filters.mode,
        openNow: filters.openNow,
        outdoor: filters.outdoor,
        vegetarian: filters.vegetarian,
        bookable: filters.bookable,
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = Top5PlaceList.fromJson(_parseJsonObject(resp.body));
        results.assignAll(data.places ?? []);
      } else if (resp.statusCode == 403) {
        final Map<String, dynamic> json = jsonDecode(resp.body);
        if (json['error'] == 'You have reached your plan limit for places.') {
          Get.dialog(SubscriptionDialogView(purpose: 'Place List'));
        }
      } else {
        error.value = 'Failed: ${resp.statusCode}';
        results.clear();
      }
    } catch (e) {
      error.value = 'Error: $e';
      results.clear();
    } finally {
      loading.value = false;
    }
  }

  Future<void> _fetchAiForPlace(String placeId) async {
    try {
      final res = await _api.placeDetailsWithAi(placeId);
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

  Future<void> fetchPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return;
    if (placeDetails['place_id'] == placeId && placeAiDetails['place_id'] == placeId) return;

    detailsLoading.value = true;
    try {
      double lat, lng;
      if (Get.isRegistered<HomeController>() &&
          Get.find<HomeController>().manualOverride.value &&
          Get.find<HomeController>().manualLat.value != null &&
          Get.find<HomeController>().manualLng.value != null) {
        lat = Get.find<HomeController>().manualLat.value!;
        lng = Get.find<HomeController>().manualLng.value!;
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

      final res1 = await _api.placeDetails(
        placeId,
        userLatitude: lat,
        userLongitude: lng,
      );
      if (res1.statusCode == 200) {
        placeDetails.value = jsonDecode(res1.body);
      } else {
        Get.snackbar('Details', _safeMsg(res1.body) ?? 'Failed to fetch place details.');
      }

      final res2 = await _api.placeDetailsWithAi(placeId);
      if (res2.statusCode == 200) {
        placeAiDetails.value = jsonDecode(res2.body);
      } else {
        Get.snackbar('Details', _safeMsg(res2.body) ?? 'Failed to fetch AI details.');
      }
    } catch (_) {
      Get.snackbar('Details', 'Unexpected error occurred');
    } finally {
      detailsLoading.value = false;
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

  void _closeAllCategoryDropdowns() {
    showActivitiesDropdown.value = false;
    showServicesDropdown.value = false;
    showSuperShopsDropdown.value = false;
  }

  @override
  void onInit() {
    super.onInit();

    // Default empty -> hint is visible
    searchText.value = '';
    searchQuery.value = '';

    // typing sync
    searchBarTextController.addListener(() {
      syncTypingToQuery(searchBarTextController.text);

      // Optional: live fetch while typing (debounced)
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 350), () {
        // if user cleared input, do not call API
        if (searchQuery.value.isEmpty) return;
        fetchTop5();
      });
    });

    // ✅ Refresh list when any filter chip changes
    for (int i = 0; i < selectedFilter.length; i++) {
      _filterWorkers.add(
        ever(selectedFilter[i], (_) {
          // Debounced refresh (same debounce timer you already use)
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 350), () {
            fetchTop5(); // refresh list based on selected filters
          });
        }),
      );
    }

    // Don't auto fetch on entry.
    // You call setSearchQuery() from args or user submit/voice.
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchBarTextController.dispose();
    for (final w in _filterWorkers) {
      w.dispose();
    }
    super.onClose();
  }
}
