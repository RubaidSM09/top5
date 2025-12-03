import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/home/controllers/home_controller.dart';
import 'package:top5/app/modules/profile/controllers/profile_controller.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';
import 'package:top5/common/widgets/custom_button.dart';

import 'package:geolocator/geolocator.dart';
import '../../../../common/localization/localization_controller.dart';
import '../../../secrets/secrets.dart';
import 'details_view.dart';
import 'google_map_webview.dart';
import 'home_view.dart';

class ServiceView extends GetView<HomeController> {
  final String appBarTitle;

  const ServiceView({required this.appBarTitle, super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.put(ProfileController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = Get.find<HomeController>();
      if (!c.top5Loading.value && c.top5Places.isEmpty) {
        c.fetchTop5Places(search: c.searchText.value);
      }
    });

    return WillPopScope(
      onWillPop: () async {
        final c = Get.find<HomeController>();
        c.resetHeaderSelectionIfFromQuickGlance();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: ServiceAppBar(appBarTitle: appBarTitle),
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Obx(() {
            final c = Get.find<HomeController>();

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            SizedBox(height: 12.62.h),

                            // TOP CATEGORY CHIPS (Same as HomeView)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                spacing: 10.w,
                                children: [
                                  CategorySelectionCard(
                                    text: 'Restaurant'.tr,
                                    icon: 'assets/images/home/restaurant.svg',
                                    selectedCategory: c.selectedCategory,
                                    index: 0,
                                    color: c.selectedCategory[0].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                                    textColor: c.selectedCategory[0].value ? AppColors.homeWhite : AppColors.homeGray,
                                    page: 'Service',
                                  ),
                                  CategorySelectionCard(
                                    text: 'Cafes'.tr,
                                    icon: 'assets/images/home/coffee_x5F_cup.svg',
                                    selectedCategory: c.selectedCategory,
                                    index: 1,
                                    color: c.selectedCategory[1].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                                    textColor: c.selectedCategory[1].value ? AppColors.homeWhite : AppColors.homeGray,
                                    page: 'Service',
                                  ),
                                  CategorySelectionCard(
                                    text: 'Bars'.tr,
                                    icon: 'assets/images/home/bars.svg',
                                    selectedCategory: c.selectedCategory,
                                    index: 2,
                                    color: c.selectedCategory[2].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                                    textColor: c.selectedCategory[2].value ? AppColors.homeWhite : AppColors.homeGray,
                                    page: 'Service',
                                  ),
                                  CategorySelectionCard(
                                    text: 'Activities'.tr,
                                    icon: 'assets/images/home/activities.svg',
                                    selectedCategory: c.selectedCategory,
                                    index: 3,
                                    color: c.selectedCategory[3].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                                    textColor: c.selectedCategory[3].value ? AppColors.homeWhite : AppColors.homeGray,
                                    page: 'Service',
                                  ),
                                  CategorySelectionCard(
                                    text: 'Services'.tr,
                                    icon: 'assets/images/home/services.svg',
                                    selectedCategory: c.selectedCategory,
                                    index: 4,
                                    color: c.selectedCategory[4].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                                    textColor: c.selectedCategory[4].value ? AppColors.homeWhite : AppColors.homeGray,
                                    page: 'Service',
                                  ),
                                ],
                              ),
                            ),

                            // NEW: Dropdown for Activities/Services (Same as HomeView)
                            Obx(() {
                              final c = Get.find<HomeController>();
                              final bool showActivities = c.showActivitiesDropdownService.value && c.selectedCategory[3].value;
                              final bool showServices = c.showServicesDropdownService.value && c.selectedCategory[4].value;

                              if (!showActivities && !showServices) {
                                return const SizedBox.shrink();
                              }

                              final bool isActivities = showActivities;
                              final List<CategoryNode> parents = isActivities ? c.activitiesCategories : c.servicesCategories;
                              final CategoryNode? selectedParent = isActivities ? c.selectedActivitiesParent.value : c.selectedServicesParent.value;
                              final CategoryNode? selectedChild = isActivities ? c.selectedActivitiesChild.value : c.selectedServicesChild.value;

                              final Color bgColor = isActivities
                                  ? (c.selectedCategory[3].value ? AppColors.homeGreen : AppColors.homeInactiveBg)
                                  : (c.selectedCategory[4].value ? AppColors.homeGreen : AppColors.homeInactiveBg);

                              final Color chipBgActive = AppColors.homeWhite;
                              final Color chipBgInactive = bgColor.withOpacity(0.85);
                              final Color chipTextActive = AppColors.homeGreen;
                              final Color chipTextInactive = AppColors.homeWhite;

                              return Container(
                                margin: EdgeInsets.only(top: 12.h),
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8.w,
                                      runSpacing: 8.h,
                                      children: parents.map((node) {
                                        final bool isSelected = selectedParent?.id == node.id;
                                        return GestureDetector(
                                          onTap: () {
                                            if (isActivities) {
                                              c.selectActivitiesParent(node);
                                            } else {
                                              c.selectServicesParent(node);
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                            decoration: BoxDecoration(
                                              color: isSelected ? chipBgActive : chipBgInactive,
                                              borderRadius: BorderRadius.circular(20.r),
                                            ),
                                            child: Text(
                                              node.label.tr,
                                              style: h4.copyWith(
                                                color: isSelected ? chipTextActive : chipTextInactive,
                                                fontSize: 11.sp,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                    if (selectedParent != null && selectedParent.children.isNotEmpty) ...[
                                      SizedBox(height: 6.h),
                                      Divider(color: chipBgActive),
                                      SizedBox(height: 6.h),
                                      Wrap(
                                        spacing: 8.w,
                                        runSpacing: 8.h,
                                        children: selectedParent.children.map((node) {
                                          final bool isSelectedChild = selectedChild?.id == node.id;
                                          return GestureDetector(
                                            onTap: () {
                                              if (isActivities) {
                                                c.selectActivitiesChild(node, refreshIdeasFlag: false);
                                              } else {
                                                c.selectServicesChild(node, refreshIdeasFlag: false);
                                              }
                                              c.fetchTop5Places(search: c.searchText.value);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                              decoration: BoxDecoration(
                                                color: isSelectedChild ? chipBgActive : chipBgInactive,
                                                borderRadius: BorderRadius.circular(20.r),
                                              ),
                                              child: Text(
                                                node.label.tr,
                                                style: h4.copyWith(
                                                  color: isSelectedChild ? chipTextActive : chipTextInactive,
                                                  fontSize: 11.sp,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),

                            SizedBox(height: 24.h),
                            HomeSearchBar(searchBarText: '“Search in $appBarTitle”'),
                            SizedBox(height: 16.38.h),

                            // Filters
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                spacing: 10.w,
                                children: [
                                  FilterSelectionCard(text: 'Open now'.tr, selectedFilter: controller.selectedFilter, index: 0, color: controller.selectedFilter[0].value ? AppColors.homeGreen : AppColors.homeInactiveBg, textColor: controller.selectedFilter[0].value ? AppColors.homeWhite : AppColors.homeGray, page: 'Service'),
                                  FilterSelectionCard(text: '10 min', selectedFilter: controller.selectedFilter, index: 1, color: controller.selectedFilter[1].value ? AppColors.homeGreen : AppColors.homeInactiveBg, textColor: controller.selectedFilter[1].value ? AppColors.homeWhite : AppColors.homeGray, page: 'Service'),
                                  FilterSelectionCard(text: profileController.selectedDistanceUnit[0].value ? '1 km' : "${controller.convertToMiles('1 km').toStringAsFixed(2)} miles", selectedFilter: controller.selectedFilter, index: 2, color: controller.selectedFilter[2].value ? AppColors.homeGreen : AppColors.homeInactiveBg, textColor: controller.selectedFilter[2].value ? AppColors.homeWhite : AppColors.homeGray, page: 'Service'),
                                  FilterSelectionCard(text: 'Outdoor'.tr, selectedFilter: controller.selectedFilter, index: 3, color: controller.selectedFilter[3].value ? AppColors.homeGreen : AppColors.homeInactiveBg, textColor: controller.selectedFilter[3].value ? AppColors.homeWhite : AppColors.homeGray, page: 'Service'),
                                  FilterSelectionCard(text: 'Vegetarian'.tr, selectedFilter: controller.selectedFilter, index: 4, color: controller.selectedFilter[4].value ? AppColors.homeGreen : AppColors.homeInactiveBg, textColor: controller.selectedFilter[4].value ? AppColors.homeWhite : AppColors.homeGray, page: 'Service'),
                                  FilterSelectionCard(text: 'Bookable'.tr, selectedFilter: controller.selectedFilter, index: 5, color: controller.selectedFilter[5].value ? AppColors.homeGreen : AppColors.homeInactiveBg, textColor: controller.selectedFilter[5].value ? AppColors.homeWhite : AppColors.homeGray, page: 'Service'),
                                ],
                              ),
                            ),
                            SizedBox(height: 34.h),
                          ],
                        ),
                      ),
      
                      /*controller.isListView.value
                          ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Top 5 near you'.tr,
                                  style: h2.copyWith(
                                    color: AppColors.serviceBlack,
                                    fontSize: 24.sp,
                                  ),
                                ),
      
                                GestureDetector(
                                  onTap: () {
                                    controller.isListView.value =
                                    !controller.isListView.value;
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.serviceSearchBg,
                                      borderRadius: BorderRadius.circular(
                                        16.r,
                                      ),
                                    ),
                                    child: Row(
                                      spacing: 4.w,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/home/map.svg',
                                        ),
      
                                        Text(
                                          'Map'.tr,
                                          style: h4.copyWith(
                                            color: AppColors.serviceGray,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
      
                            SizedBox(height: 20.h),
      
                            Column(
                              spacing: 16.h,
                              children: [
                                Obx(() {
                                  final c = Get.find<HomeController>();
      
                                  // Touch the aiSummaries map inside Obx to rebuild when AI data arrives
                                  final _ = c.aiSummaries.length;
      
                                  if (c.top5Loading.value) {
                                    return Row(
                                      children: [
                                        const CircularProgressIndicator(strokeWidth: 2),
                                        SizedBox(width: 8.w),
                                        Text('Fetching top picks...', style: h4.copyWith(color: AppColors.serviceGray)),
                                      ],
                                    );
                                  }
                                  if (c.top5Places.isEmpty) {
                                    return Text(
                                      'No ${c.currentCategoryLabel.toLowerCase()} found nearby.',
                                      style: h4.copyWith(color: AppColors.serviceGray),
                                    );
                                  }
      
                                  return Column(
                                    spacing: 16.h,
                                    children: c.top5Places.asMap().entries.map((entry) {
                                      final i = entry.key + 1;
                                      final p = entry.value;
      
                                      // final aiText = c.aiSummaryTextFor(p.placeId);
      
                                      return Top5NearYouListCard(
                                        serialNo: i,
                                        title: p.name ?? 'Unknown',
                                        rating: (p.rating ?? 0).toDouble(),
                                        reviewCount: (p.reviewsCount ?? 0),
                                        image: p.thumbnail ?? 'assets/images/home/restaurant.jpg',
                                        isPromo: false,
                                        status: (p.openNow ?? false) ? 'Open'.tr : 'Closed'.tr,
                                        distance: p.distanceText ?? '—',
                                        time: c.parseMinutes(p.durationText),
                                        type: c.currentCategoryLabel,
                                        primeReason: '${(p.reviewsCount ?? 0)} reviews • ${p.distanceText ?? ''}',
                                        reasons: [
                                          '${p.rating?.toStringAsFixed(1) ?? '—'} rating',
                                          p.durationText ?? '',
                                        ],
                                        isSaved: false.obs,
                                        selectedLocations: controller.selectedLocations,
                                        placeId: p.placeId ?? '',
                                        // aiSummary: aiText,
                                        destLat: p.latitude ?? 0.0,      // NEW
                                        destLng: p.longitude ?? 0.0,     // NEW
                                      );
                                    }).toList(),
                                  );
                                }),
                              ],
                            ),
      
                            SizedBox(height: 20.h),
                          ],
                        ),
                      )
                          : */Obx(() {
                        return SizedBox(
                          height: 360.h,
                          width: double.infinity,
                          child: Get.find<HomeController>()
                              .top5Places
                              .isNotEmpty
                              ? GoogleMapWebView(
                            googleApiKey: googleApiKey,
                            originLat: controller.userLat.value ??
                                (controller.top5Places.isNotEmpty
                                    ? (controller.top5Places.first
                                    .latitude ??
                                    23.7809063)
                                    : 23.7809063),
                            originLng: controller.userLng.value ??
                                (controller.top5Places.isNotEmpty
                                    ? (controller.top5Places.first
                                    .longitude ??
                                    90.4075592)
                                    : 90.4075592),
                            places: controller.top5Places.isNotEmpty
                                ? (controller.top5Places)
                                : [],
                            originalIndices: [1, 2, 3, 4, 5],
                          )
                              : Image.asset(
                            'assets/images/home/blurred_map.jpg',
                            fit: BoxFit.cover,
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                DraggableScrollableSheet(
                  initialChildSize: 0.48,
                  minChildSize: 0.48,
                  maxChildSize: 1.0,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                        color: AppColors.serviceWhite,
                      ),
                      child: Column(
                        children: <Widget>[
                          Grabber(
                            onVerticalDragUpdate:
                            controller.onDragUpdate,
                            isOnDesktopAndWeb:
                            controller.isOnDesktopAndWeb,
                          ),
                          SizedBox(height: 13.h),
                          Container(
                            width: 60.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(100.r),
                              color: AppColors.serviceGrabColor,
                            ),
                          ),
                          SizedBox(height: 11.h),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Top 5 near you'.tr,
                                style: h2.copyWith(
                                  color: AppColors.serviceBlack,
                                  fontSize: 24.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: controller.isOnDesktopAndWeb
                                  ? null
                                  : scrollController,
                              child: Column(
                                spacing: 20.h,
                                children: [
                                  Obx(() {
                                    final c =
                                    Get.find<HomeController>();

                                    if (c.top5Loading.value) {
                                      return Row(
                                        children: [
                                          const CircularProgressIndicator(
                                              strokeWidth: 2),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Fetching top picks...',
                                            style: h4.copyWith(
                                                color: AppColors
                                                    .serviceGray),
                                          ),
                                        ],
                                      );
                                    }
                                    if (c.top5Places.isEmpty) {
                                      return Text(
                                        'No ${c.currentCategoryLabel.toLowerCase()} found nearby.',
                                        style: h4.copyWith(
                                            color: AppColors.serviceGray),
                                      );
                                    }

                                    return Column(
                                      spacing: 20.h,
                                      children: c.top5Places
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final i = entry.key + 1;
                                        final p = entry.value;

                                        return Top5NearYouMapCard(
                                          serialNo: i,
                                          title: p.name ?? 'Unknown',
                                          rating:
                                          (p.rating ?? 0).toDouble(),
                                          image: p.thumbnail ??
                                              'assets/images/home/restaurant.jpg',
                                          isPromo: false,
                                          status: (p.openNow ?? false)
                                              ? 'Open'.tr
                                              : 'Closed'.tr,
                                          distance:
                                          p.distanceText ?? '—',
                                          type: c.currentCategoryLabel,
                                          time: c.parseMinutes(
                                              p.durationText),
                                          reasons: [
                                            '${(p.reviewsCount ?? 0)} reviews',
                                            p.durationText ?? '',
                                          ],
                                          isSaved: false.obs,
                                          selectedLocations:
                                          controller.selectedLocations,
                                          placeId: p.placeId ?? '',
                                          destLat: p.latitude ?? 0.0,
                                          destLng: p.longitude ?? 0.0,
                                          directionUrl:
                                          p.directionUrl ?? '',
                                        );
                                      }).toList(),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class ServiceAppBar extends StatelessWidget {
  final String appBarTitle;

  const ServiceAppBar({required this.appBarTitle, super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController profileController =
    Get.find<ProfileController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            final c = Get.find<HomeController>();
            c.resetHeaderSelectionIfFromQuickGlance();
            Get.back();
          },
          child: Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: AppColors.serviceBlack,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.serviceWhite,
              size: 18.r,
            ),
          ),
        ),
        Text(
          appBarTitle,
          style: h3.copyWith(
            color: AppColors.top5Black,
            fontSize: 24.sp,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.homeProfileBorderColor,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 16.r,
            backgroundImage: profileController.image.value == ''
                ? const AssetImage(
              'assets/images/home/profile_pic.jpg',
            )
                : NetworkImage(
              'http://206.162.244.150:8001${profileController.image.value}',
            ) as ImageProvider,
          ),
        ),
      ],
    );
  }
}

/*class Top5NearYouListCard extends StatelessWidget {
  final int serialNo;
  final String title;
  final double rating;
  final int reviewCount;
  final String image;
  final bool isPromo;
  final String status;
  final String distance;
  final double time;
  final String type;
  final String primeReason;
  final List<String> reasons;
  final RxBool isSaved;
  final RxList<RxBool> selectedLocations;
  final String placeId;  // New
  // final String aiSummary; // NEW
  final double destLat;   // NEW
  final double destLng;   // NEW

  const Top5NearYouListCard({
    required this.serialNo,
    required this.title,
    required this.rating,
    required this.reviewCount,
    required this.image,
    required this.isPromo,
    required this.status,
    required this.distance,
    required this.time,
    required this.type,
    required this.primeReason,
    required this.reasons,
    required this.isSaved,
    required this.selectedLocations,
    required this.placeId,
    // required this.aiSummary,
    required this.destLat,
    required this.destLng,
    super.key,
  });

  Future<void> _openDirections() async {
    final c = Get.find<HomeController>();
    await c.openDirectionsTo(destLat: destLat, destLng: destLng, travelMode: 'walking');

    // (Optional) keep your recents tracking:
    *//*if (placeId.isNotEmpty) {
      await c.submitActionPlaces(placeId, 'recent');
      await c.fetchRecentPlaces();
    }*//*
  }

  Future<void> _searchOnGoogle() async {
    final c = Get.find<HomeController>();
    await c.openGoogleAppSearch(title);
  }

  Future<void> _toggleSave(double destLat, double destLng, String title, double rating, String directionUrl) async {
    final c = Get.find<HomeController>();
    final activityType = c.isPlaceSaved(placeId) ? 'saved-delete' : 'saved';

    await c.submitActionPlaces(placeId, destLat, destLng, title, rating, directionUrl, '', '', '', '€€.', activityType);
    await c.fetchSavedPlaces(); // Refresh saved places list
    await c.fetchSavedCount();
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider imgProvider = image.startsWith('http') ? NetworkImage(image) : AssetImage(image) as ImageProvider;
    final c = Get.find<HomeController>();

    return GestureDetector(
      onTap: () {
        int index = serialNo - 1;
        if (!selectedLocations[index].value) {
          for (int i = 0; i < 5; i++) {
            if (i == index) {
              selectedLocations[i] = true.obs;
            } else {
              selectedLocations[i] = false.obs;
            }
          }
        }
        Get.to(
          DetailsView(
            serialNo: serialNo,
            title: title,
            rating: rating,
            image: image,
            isPromo: isPromo,
            status: status,
            distance: distance,
            time: time,
            type: type,
            reasons: reasons,
            isSaved: c.isPlaceSaved(placeId).obs, // Use reactive save status
            placeId: placeId,
            destLat: destLat,
            destLng: destLng,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.serviceWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.top5Black.withAlpha(38),
              blurRadius: 10.r,
              offset: Offset(2.w, 3.h),
            )
          ],
        ),
        child: Column(
          spacing: 16.h,
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 8.h, bottom: 156.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    image: DecorationImage(
                      image: imgProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isPromo
                              ? AppColors.servicePromoGreen
                              : AppColors.top5Transparent,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          'Promo',
                          style: h4.copyWith(
                            color: isPromo
                                ? AppColors.serviceWhite
                                : AppColors.top5Transparent,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      Obx(() => GestureDetector(
                        onTap: _toggleSave,
                        child: Container(
                          padding: EdgeInsets.all(9.33.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.serviceWhite,
                          ),
                          child: SvgPicture.asset(
                            c.isPlaceSaved(placeId)
                                ? 'assets/images/home/saved.svg' // Icon for saved state
                                : 'assets/images/home/save.svg', // Icon for unsaved state
                          ),
                        ),
                      )),
                    ],
                  ),
                ),

                if (status == 'Closed')
                  Positioned.fill(
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      color: AppColors.top5Black.withAlpha(127),
                      child: Center(
                        child: Text(
                          '$title is closed now.',
                          style: h3.copyWith(
                            color: AppColors.homeWhite,
                            fontSize: 20.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(left: 9.w, right: 9.w, bottom: 25.h),
              child: Column(
                spacing: 7.h,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: AppColors.serviceGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$serialNo',
                          style: h4.copyWith(
                            color: AppColors.serviceWhite,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),

                      SizedBox(width: 16.w),

                      SizedBox(
                        width: 190.w,
                        child: Text(
                          title,
                          style: h2.copyWith(
                            color: AppColors.serviceBlack,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),

                      SizedBox(width: 16.w),

                      Icon(
                        Icons.star,
                        size: 14.r,
                        color: AppColors.serviceGreen,
                      ),

                      SizedBox(width: 4.w),

                      Text(
                        '$rating ',
                        style: h2.copyWith(
                          color: AppColors.top5Black,
                          fontSize: 14.sp,
                        ),
                      ),

                      Text(
                        '($reviewCount)',
                        style: h4.copyWith(
                          color: AppColors.serviceGray,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    spacing: 15.w,
                    children: [
                      Text(
                        '€€',
                        style: h2.copyWith(
                          color: AppColors.top5Black,
                          fontSize: 14.sp,
                        ),
                      ),

                      Text(
                        '•',
                        style: h4.copyWith(
                          color: AppColors.serviceText2,
                          fontSize: 11.9.sp,
                        ),
                      ),

                      Row(
                        spacing: 4.w,
                        children: [
                          SvgPicture.asset(
                              'assets/images/home/clock.svg'
                          ),

                          Text(
                            '${time.toStringAsFixed(0)} min walk',
                            style: h4.copyWith(
                              color: AppColors.serviceGray,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        '•',
                        style: h4.copyWith(
                          color: AppColors.serviceText2,
                          fontSize: 11.9.sp,
                        ),
                      ),

                      Row(
                        spacing: 4.w,
                        children: [
                          SvgPicture.asset(
                              'assets/images/home/location.svg'
                          ),

                          Text(
                            distance,
                            style: h4.copyWith(
                              color: AppColors.serviceGray,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        '•',
                        style: h4.copyWith(
                          color: AppColors.serviceText2,
                          fontSize: 11.9.sp,
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'Open' ? AppColors.serviceSearchBg : AppColors.profileDeleteButtonColor,
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        child: Text(
                          status,
                          style: h3.copyWith(
                            color: status == 'Open' ? AppColors.servicePromoGreen : AppColors.profileDeleteButtonTextColor,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Why this pick — show AI summary if available (max 2, comma-separated)
                  *//*Row(
                    children: [
                      Text(
                        'Why this pick: '.tr,
                        style: h2.copyWith(
                          color: AppColors.serviceGray,
                          fontSize: 11.9.sp,
                        ),
                      ),

                      Flexible(
                        child: Text(
                          (aiSummary.isNotEmpty ? aiSummary : primeReason),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: h4.copyWith(
                            color: AppColors.serviceGray,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),*//*

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        text: 'Directions'.tr,
                        prefixIcon: 'assets/images/home/directions.svg',
                        paddingLeft: 12,
                        paddingRight: 12,
                        paddingTop: 8,
                        paddingBottom: 8,
                        borderRadius: 6,
                        textSize: 12,
                        onTap: _openDirections, // NEW
                      ),

                      CustomButton(
                        text: 'Book'.tr,
                        paddingLeft: 35,
                        paddingRight: 35,
                        paddingTop: 8,
                        paddingBottom: 8,
                        borderRadius: 6,
                        color: AppColors.top5Transparent,
                        borderColor: AppColors.serviceGray,
                        textColor: AppColors.serviceGray,
                        textSize: 12,
                        onTap: _searchOnGoogle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/

class Top5NearYouMapCard extends StatelessWidget {
  final int serialNo;
  final String title;
  final double rating;
  final String image;
  final bool isPromo;
  final String status;
  final String distance;
  final double time;
  final String type;
  final List<String> reasons;
  final RxBool isSaved;
  final RxList<RxBool> selectedLocations;
  final String placeId;
  final double destLat;
  final double destLng;
  final String directionUrl;

  const Top5NearYouMapCard({
    required this.serialNo,
    required this.title,
    required this.rating,
    required this.image,
    required this.isPromo,
    required this.status,
    required this.distance,
    required this.time,
    required this.type,
    required this.reasons,
    required this.isSaved,
    required this.selectedLocations,
    required this.placeId,
    required this.destLat,
    required this.destLng,
    required this.directionUrl,
    super.key,
  });

  Future<void> _openDirections() async {
    final c = Get.find<HomeController>();
    await c.openDirectionsTo(
      destLat: destLat,
      destLng: destLng,
      travelMode: 'walking',
    );
  }

  Future<void> _searchOnGoogle() async {
    final c = Get.find<HomeController>();
    await c.openGoogleAppSearch(title);
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider imgProvider = image.startsWith('http')
        ? NetworkImage(image)
        : AssetImage(image) as ImageProvider;

    return GestureDetector(
      onTap: () {
        int index = serialNo - 1;
        if (!selectedLocations[index].value) {
          for (int i = 0; i < 5; i++) {
            if (i == index) {
              selectedLocations[i] = true.obs;
            } else {
              selectedLocations[i] = false.obs;
            }
          }
        }

        if (status == 'Open') {
          Get.to(
            DetailsView(
              serialNo: serialNo,
              title: title,
              rating: rating,
              image: image,
              isPromo: isPromo,
              status: status,
              distance: distance,
              time: time,
              type: type,
              reasons: reasons,
              isSaved: isSaved,
              placeId: placeId,
              destLat: destLat,
              destLng: destLng,
              directionUrl: directionUrl,
            ),
          );
        }
      },
      child: Container(
        padding:
        EdgeInsets.symmetric(horizontal: 15.w, vertical: 17.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.serviceGray,
            width: 0.5.r,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: AppColors.serviceGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$serialNo',
                    style: h4.copyWith(
                      color: AppColors.serviceWhite,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isPromo
                        ? AppColors.servicePromoGreen
                        : AppColors.top5Transparent,
                    borderRadius:
                    BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'Promo',
                    style: h4.copyWith(
                      color: isPromo
                          ? AppColors.serviceWhite
                          : AppColors.top5Transparent,
                      fontSize: 10.sp,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        left: 8.w,
                        right: 7.w,
                        top: 5.h,
                        bottom: 42.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(6.r),
                        image: DecorationImage(
                          image: imgProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.top5Transparent,
                          borderRadius:
                          BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          'Promo',
                          style: h4.copyWith(
                            color: AppColors.top5Transparent,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                    if (status == 'Closed')
                      Positioned.fill(
                        child: Container(
                          padding: EdgeInsets.all(20.r),
                          color: AppColors.top5Black
                              .withAlpha(127),
                        ),
                      ),
                  ],
                ),
                Column(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  spacing: 8.h,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 175.w,
                          child: Text(
                            title,
                            style: h2.copyWith(
                              color: AppColors.serviceBlack,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.star,
                          size: 14.r,
                          color: AppColors.serviceGreen,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$rating',
                          style: h2.copyWith(
                            color: AppColors.top5Black,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '€€.',
                          style: h2.copyWith(
                            color: AppColors.top5Black,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 255.w,
                      child: Wrap(
                        spacing: 10.w,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'Open'
                                  ? AppColors.serviceSearchBg
                                  : AppColors
                                  .profileDeleteButtonColor,
                              borderRadius:
                              BorderRadius.circular(50.r),
                            ),
                            child: Text(
                              status,
                              style: h3.copyWith(
                                color: status == 'Open'
                                    ? AppColors.servicePromoGreen
                                    : AppColors
                                    .profileDeleteButtonTextColor,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          Text(
                            '$distance / ${time.toStringAsFixed(0)} min walk',
                            style: h4.copyWith(
                              color: AppColors.serviceGray,
                              fontSize: 12.sp,
                            ),
                          ),
                          Row(
                            spacing: 4.w,
                            children: [
                              Text(
                                'Cuisine'.tr,
                                style: h4.copyWith(
                                  color: AppColors.serviceGray,
                                  fontSize: 12.sp,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.serviceSearchBg,
                                  borderRadius:
                                  BorderRadius.circular(50.r),
                                ),
                                child: Text(
                                  type,
                                  style: h4.copyWith(
                                    color: AppColors.serviceText2,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(height: 16.h),
            Row(
              spacing: 18.w,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Directions'.tr,
                    prefixIcon:
                    'assets/images/home/directions.svg',
                    paddingLeft: 12,
                    paddingRight: 12,
                    paddingTop: 8,
                    paddingBottom: 8,
                    borderRadius: 6,
                    textSize: 12,
                    onTap: _openDirections,
                  ),
                ),
                Expanded(
                  child: CustomButton(
                    text: 'Book'.tr,
                    paddingLeft:
                    Get.find<LocalizationController>()
                        .selectedLanguage
                        .value ==
                        'English'
                        ? 35
                        : 25,
                    paddingRight:
                    Get.find<LocalizationController>()
                        .selectedLanguage
                        .value ==
                        'English'
                        ? 35
                        : 25,
                    paddingTop: 8,
                    paddingBottom: 8,
                    borderRadius: 6,
                    color: AppColors.top5Transparent,
                    borderColor: AppColors.serviceGray,
                    textColor: AppColors.serviceGray,
                    textSize: 12,
                    onTap: _searchOnGoogle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LocationPointer extends StatelessWidget {
  final int serialNo;
  final double latitude;
  final double longitude;
  final String name;
  final String image;
  final RxList<RxBool> selectedLocations;

  const LocationPointer({
    required this.serialNo,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.image,
    required this.selectedLocations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: longitude.h,
      left: latitude.w,
      child: Obx(() {
        return Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.topCenter,
          children: [
            GestureDetector(
              onTap: () {
                int index = serialNo - 1;
                if (!selectedLocations[index].value) {
                  for (int i = 0; i < 5; i++) {
                    if (i == index) {
                      selectedLocations[i] = true.obs;
                    } else {
                      selectedLocations[i] = false.obs;
                    }
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.67.w,
                  vertical: 5.33.h,
                ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/home/location_pointer.png',
                    ),
                  ),
                ),
                child: Text(
                  '$serialNo',
                  style: h3.copyWith(
                    color: AppColors.serviceWhite,
                    fontSize: 6.sp,
                  ),
                ),
              ),
            ),
            selectedLocations[serialNo - 1].value
                ? Positioned(
              bottom: 11.33.h,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(6.r),
                  color: AppColors.serviceGreen,
                ),
                child: Column(
                  spacing: 6.h,
                  children: [
                    Text(
                      name,
                      style: h2.copyWith(
                        color: AppColors.serviceWhite,
                        fontSize: 10.sp,
                      ),
                    ),
                    Container(
                      width: 52.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(6.r),
                        image: DecorationImage(
                          image: AssetImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : const SizedBox.shrink(),
          ],
        );
      }),
    );
  }
}

class Grabber extends StatelessWidget {
  const Grabber({
    super.key,
    required this.onVerticalDragUpdate,
    required this.isOnDesktopAndWeb,
  });

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: Container(
        width: double.infinity,
        color: colorScheme.onSurface,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            width: 32.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
