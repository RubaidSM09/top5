/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/profile/views/personal_info_view.dart';
import 'package:top5/app/modules/profile/views/recent_saved_reservation_details_view.dart';
import 'package:top5/common/localization/localization_controller.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../secrets/secrets.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/google_map_webview.dart';
import '../controllers/profile_controller.dart';

class RecentListView extends GetView {
  const RecentListView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());
    final homeController = Get.put(HomeController());

    // Trigger fetch once when first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (homeController.recentPlaces.isEmpty && !homeController.recentLoading.value) {
        homeController.fetchRecentPlaces();
      }
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ProfileAppBar(appBarTitle: 'Recent List'.tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: Obx(() {
            if (homeController.recentLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (homeController.recentError.isNotEmpty) {
              return Center(
                child: Text(
                  homeController.recentError.value,
                  style: h3.copyWith(color: Colors.red, fontSize: 12.sp),
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (homeController.recentPlaces.isEmpty) {
              return Center(
                child: Text(
                  'No recent places yet.',
                  style: h4.copyWith(color: AppColors.homeGray, fontSize: 14.sp),
                ),
              );
            }

            final places = homeController.recentPlaces;

            return SingleChildScrollView(
              child: Column(
                spacing: 16.h,
                children: List.generate(places.length, (i) {
                  final p = places[i];

                  final title = p.name ?? 'Unknown';
                  final rating = p.rating ?? 0.0;
                  final image = p.photo ?? '';
                  final status = p.openNow == null ? 'Closed'.tr : (p.openNow! ? 'Open'.tr : 'Closed'.tr);
                  final distance = p.distanceText ?? '';
                  final timeMins = homeController.parseMinutes(p.durationText);
                  final reasons = <String>[
                    '⭐ ${rating.toStringAsFixed(1)}',
                    if (distance.isNotEmpty) distance,
                    if ((p.phone ?? '').isNotEmpty) (p.phone ?? ''),
                  ];

                  // New fields from API
                  final placeId = p.placeId ?? '';
                  final destLat = p.latitude ?? 0.0;
                  final destLng = p.longitude ?? 0.0;

                  return RecentListCard(
                    serialNo: i + 1,
                    title: title,
                    rating: rating,
                    image: image,
                    isPromo: false,
                    status: status,
                    distance: distance,
                    time: timeMins,
                    type: 'Restaurant'.tr,
                    reasons: reasons,
                    isSaved: false.obs,
                    selectedLocations: homeController.selectedLocations,

                    placeId: placeId,
                    destLat: destLat,
                    destLng: destLng,
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class RecentListCard extends StatelessWidget {
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

  // NEW optional fields
  final String? placeId;
  final double? destLat;
  final double? destLng;

  const RecentListCard({
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
    this.placeId,
    this.destLat,
    this.destLng,
    super.key,
  });

  Future<void> _openDirections() async {
    final c = Get.find<HomeController>();

    double oLat, oLng;
    if (c.manualOverride.value && c.manualLat.value != null && c.manualLng.value != null) {
      oLat = c.manualLat.value!;
      oLng = c.manualLng.value!;
    } else {
      // fall back to current device location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location', 'Location services disabled.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        Get.snackbar('Location', 'Permission denied for location.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      oLat = pos.latitude;
      oLng = pos.longitude;
    }

    Get.to(() => DirectionsMapWebView(
      googleApiKey: googleApiKey,
      originLat: oLat,
      originLng: oLng,
      destLat: destLat ?? 0,
      destLng: destLng ?? 0,
      travelMode: 'WALKING',
      destName: title,
      destImgUrl: image,
    ));

    await c.submitActionPlaces(placeId ?? '', 'recent');
    await c.fetchRecentPlaces();
  }

  @override
  Widget build(BuildContext context) {
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
            placeId: placeId ?? '',
            destLat: destLat ?? 0.0,
            destLng: destLng ?? 0.0,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      image: NetworkImage(image),
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

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.h,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 135.w,
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
                      child: Row(
                        spacing: 10.w,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.serviceSearchBg,
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                            child: Text(
                              status,
                              style: h3.copyWith(
                                color: AppColors.servicePromoGreen,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16.h,),

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
                  onTap: _openDirections,
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
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/
