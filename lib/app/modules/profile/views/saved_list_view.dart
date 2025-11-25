import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/home/controllers/home_controller.dart';
import 'package:top5/app/modules/profile/controllers/profile_controller.dart';
import 'package:top5/app/modules/profile/views/personal_info_view.dart';
import 'package:top5/app/modules/profile/views/recent_saved_reservation_details_view.dart';
import 'package:top5/app/modules/profile/views/remove_saved_list_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/localization/localization_controller.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../secrets/secrets.dart';
import '../../home/views/details_view.dart';
import '../../home/views/google_map_webview.dart';

class SavedListView extends GetView<HomeController> {
  const SavedListView({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ProfileAppBar(appBarTitle: 'Saved List'.tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: Obx(() {
            if (controller.savedLoading.value) {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(width: 8.w),
                    Text('Loading saved places...', style: h4.copyWith(color: AppColors.serviceGray)),
                  ],
                ),
              );
            }
            if (controller.savedError.value.isNotEmpty) {
              return Center(
                child: Text(
                  controller.savedError.value,
                  style: h4.copyWith(color: AppColors.serviceGray),
                ),
              );
            }
            if (controller.savedPlaces.isEmpty) {
              return Center(
                child: Text(
                  'No saved places found.',
                  style: h4.copyWith(color: AppColors.serviceGray),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                spacing: 16.h,
                children: controller.savedPlaces.asMap().entries.map((entry) {
                  final index = entry.key;
                  final place = entry.value;

                  return SavedListCard(
                    serialNo: index + 1,
                    title: place.name ?? 'Unknown',
                    rating: place.rating?.toDouble() ?? 0.0,
                    image: place.photo ?? 'assets/images/home/restaurant.jpg',
                    isPromo: false, // Adjust based on API response if available
                    status: place.openNow == true ? 'Open'.tr : 'Closed'.tr,
                    distance: profileController.selectedDistanceUnit[0].value
                        ? place.distanceText ?? '—'
                        : "${controller.convertToMiles(place.distanceText ?? '0 m').toStringAsFixed(2)} miles",
                    time: controller.parseMinutes(place.durationText),
                    type: controller.currentCategoryLabel,
                    reasons: <String>[
                      '⭐ ${place.rating!.toStringAsFixed(1)}',
                      if (place.distanceText!.isNotEmpty) profileController.selectedDistanceUnit[0].value
                          ? place.distanceText ?? '—'
                          : "${controller.convertToMiles(place.distanceText ?? '0 m').toStringAsFixed(2)} miles",
                      if ((place.phone ?? '').isNotEmpty) (place.phone ?? ''),
                    ],
                    isSaved: controller.isPlaceSaved(place.placeId).obs,
                    selectedLocations: controller.selectedLocations,
                    placeId: place.placeId ?? '',
                    destLat: place.latitude?.toDouble() ?? 0.0,
                    destLng: place.longitude?.toDouble() ?? 0.0,
                  );
                }).toList(),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class SavedListCard extends StatelessWidget {
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

  const SavedListCard({
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
    super.key,
  });

  Future<void> _openDirections() async {
    final c = Get.find<HomeController>();
    await c.openDirectionsTo(destLat: destLat, destLng: destLng, travelMode: 'walking');

    // (Optional) keep your recents tracking:
    if (placeId.isNotEmpty) {
      await c.submitActionPlaces(placeId, 'recent');
      await c.fetchRecentPlaces();
    }
  }

  Future<void> _searchOnGoogle() async {
    final c = Get.find<HomeController>();
    await c.openGoogleAppSearch(title);
  }

  Future<void> _toggleSave() async {
    final c = Get.find<HomeController>();
    final activityType = c.isPlaceSaved(placeId) ? 'saved-delete' : 'saved';

    await c.submitActionPlaces(placeId, activityType);
    await c.fetchSavedPlaces(); // Refresh saved places list
    await c.fetchSavedCount();
    isSaved.value = c.isPlaceSaved(placeId); // Update reactive isSaved
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    final ImageProvider imgProvider = image.startsWith('http') ? NetworkImage(image) : AssetImage(image) as ImageProvider;

    return GestureDetector(
      onTap: () {
        Get.to(
          RecentSavedReservationDetailsView(
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
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 17.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.serviceGray, width: 0.5.r),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: _toggleSave,
                  child: SvgPicture.asset(
                      'assets/images/profile/remove_cross.svg'
                  ),
                ),
              ],
            ),

            Row(
              spacing: 16.w,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: 8.w,
                    right: 7.w,
                    top: 5.h,
                    bottom: 42.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    image: DecorationImage(
                      image: imgProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isPromo ? AppColors.servicePromoGreen : AppColors.top5Transparent,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      'Promo',
                      style: h4.copyWith(
                        color: isPromo ? AppColors.serviceWhite : AppColors.top5Transparent,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6.h,
                    children: [
                      // TITLE + RATING ROW
                      Row(
                        children: [
                          /// Let title take remaining space instead of fixed 135.w
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: h2.copyWith(
                                color: AppColors.serviceBlack,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
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
                          SizedBox(width: 6.w),
                          Text(
                            '€€.',
                            style: h2.copyWith(
                              color: AppColors.top5Black,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),

                      // BUTTON ROW
                      Row(
                        spacing: 12.w, // a bit smaller spacing
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Directions'.tr,
                              prefixIcon: 'assets/images/home/directions.svg',
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
      ),
    );
  }
}
