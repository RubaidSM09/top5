import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../data/model/top_5_place_list.dart';
import '../../../data/services/api_services.dart';
import '../../home/controllers/home_controller.dart';

class SearchController extends GetxController {
  /// UI fields
  TextEditingController searchBarTextController =
  TextEditingController(text: 'Italian restaurants');
  RxList<RxBool> isRemoved =
      [false.obs, false.obs, false.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedCategory =
      [true.obs, false.obs, false.obs, false.obs, false.obs].obs; // Restaurant, Cafes, Bars, Activities, Services
  RxList<RxBool> selectedFilter =
      [true.obs, false.obs, false.obs, false.obs, false.obs, false.obs].obs; // open now, 10m, 1km, outdoor, vegetarian, bookable

  /// State for API + results
  final ApiService _api = ApiService();
  final RxString searchText = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<Places> results = <Places>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  final RxBool isMoreDetails = false.obs;

  /// Keep origin to send with API
  final RxDouble originLat = 0.0.obs;
  final RxDouble originLng = 0.0.obs;

  /// NEW: Place details and AI summaries
  final RxMap<dynamic, dynamic> placeDetails = {}.obs;
  final RxMap<dynamic, dynamic> placeAiDetails = {}.obs;
  final RxBool detailsLoading = false.obs;
  final RxMap<String, List<String>> aiSummaries = <String, List<String>>{}.obs;

  /// Debounce so we don’t spam API per key stroke
  Timer? _debounce;

  void setSearchQuery(String query) {
    searchQuery.value = query;
    searchText.value = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      fetchTop5();
    });
  }

  /// Helpers
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
    fetchTop5();
  }

  /// Map category index -> API place_type
  String _placeTypeFromSelection() {
    switch (_selectedCategoryIndex()) {
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
      default:
        return 'restaurant';
    }
  }

  /// Build optional filters for API
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
    radius: oneKm ? 1000.0 : null,
    maxTime: tenMin ? '10m' : null,
    mode: null,
    outdoor: outdoor,
    vegetarian: vegetarian,
    bookable: bookable
    );
  }

  Future<void> _ensureOrigin() async {
    final hc = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

    if (hc != null && hc.manualOverride.value && hc.manualLat.value != null && hc.manualLng.value != null) {
      originLat.value = hc.manualLat.value!;
      originLng.value = hc.manualLng.value!;
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    originLat.value = pos.latitude;
    originLng.value = pos.longitude;
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
      await _ensureOrigin();

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

        // NEW: Lazily fetch AI summaries for visible places (cache)
        for (final p in results) {
          final id = p.placeId ?? '';
          if (id.isNotEmpty && !aiSummaries.containsKey(id)) {
            _fetchAiForPlace(id);
          }
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

  /// NEW: Per-place AI summary fetch + cache
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
    } catch (_) {
      // Silent fail; UI will show fallback text
    }
  }

  /// NEW: Helper to format up to 2 summary items as comma-separated text
  String aiSummaryTextFor(String? placeId) {
    if (placeId == null || placeId.isEmpty) return '';
    final list = aiSummaries[placeId] ?? const <String>[];
    if (list.isEmpty) return '';
    return list.take(2).join(', ');
  }

  /// NEW: Fetch place details
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
    } catch (e) {
      Get.snackbar('Details', 'Unexpected error occurred');
    } finally {
      detailsLoading.value = false;
    }
  }

  /// NEW: Helper for permission check
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

  /// NEW: Safe message parsing
  String? _safeMsg(String body) {
    try {
      final m = jsonDecode(body);
      return m['message']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// React to chip changes
  void _wireChipListeners() {
    for (final rx in selectedCategory) {
      ever(rx, (_) => fetchTop5());
    }
    for (final rx in selectedFilter) {
      ever(rx, (_) => fetchTop5());
    }
  }

  @override
  void onInit() {
    super.onInit();
    searchText.value = searchBarTextController.text;
    searchQuery.value = searchBarTextController.text;

    searchBarTextController.addListener(() {
      searchText.value = searchBarTextController.text;
    });

    // _wireChipListeners();
    // fetchTop5();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchBarTextController.dispose();
    super.onClose();
  }
}