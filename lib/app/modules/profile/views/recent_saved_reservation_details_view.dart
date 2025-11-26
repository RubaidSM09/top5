import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../secrets/secrets.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/contact_us_view.dart';
import '../../home/views/details_view.dart' show DetailsAppBar, WhyTop5Point, DetailsTagCard, WebViewPage; // reuse widgets
import '../../home/views/google_map_webview.dart';

class RecentSavedReservationDetailsView extends GetView<HomeController> {
  final int serialNo;
  final String title;
  final double rating;
  final String image;
  final bool isPromo;
  final String status;
  final String distance;
  final double time;
  final String type;
  final List<dynamic> reasons;
  final RxBool isSaved;
  final String placeId;
  final double destLat;
  final double destLng;

  const RecentSavedReservationDetailsView({
    super.key,
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
    required this.placeId,
    required this.destLat,
    required this.destLng,
  });

  Future<void> _openDirections() async {
    final c = Get.find<HomeController>();
    await c.openDirectionsTo(destLat: destLat, destLng: destLng, travelMode: 'walking');

    // (Optional) keep your recents tracking:
    /*if (placeId.isNotEmpty) {
      await c.submitActionPlaces(placeId, 'recent');
      await c.fetchRecentPlaces();
    }*/
  }

  Future<void> _searchOnGoogle() async {
    final c = Get.find<HomeController>();
    await c.openGoogleAppSearch(title);
  }

  Future<void> _toggleSave() async {
    final c = Get.find<HomeController>();
    final activityType = c.isPlaceSaved(placeId) ? 'saved-delete' : 'saved';

    // await c.submitActionPlaces(placeId, activityType);
    await c.fetchSavedPlaces(); // Refresh saved places list
    await c.fetchSavedCount();
    isSaved.value = c.isPlaceSaved(placeId); // Update reactive isSaved
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPlaceDetails(placeId);
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const DetailsAppBar(),
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Obx(() {
            final detailsReady = controller.placeDetails.isNotEmpty &&
                controller.placeAiDetails.isNotEmpty &&
                !controller.detailsLoading.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero image + Save / Status
                      Container(
                        padding: EdgeInsets.only(
                          left: 14.w,
                          right: 14.w,
                          top: 9.38.h,
                          bottom: 170.62.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                          image: DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 6.h,),
                              decoration: BoxDecoration(
                                color: AppColors.serviceSearchBg,
                                borderRadius: BorderRadius.circular(50.r),
                              ),
                              child: Text(
                                status,
                                style: h3.copyWith(
                                  color: AppColors.servicePromoGreen,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: _toggleSave,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 6.h,),
                                decoration: BoxDecoration(
                                  color: AppColors.serviceSearchBg,
                                  borderRadius: BorderRadius.circular(50.r),
                                ),
                                child: Row(
                                  spacing: 6.w,
                                  children: [
                                    Text(
                                      c.isPlaceSaved(placeId) ? 'Saved'.tr : 'Save'.tr,
                                      style: h3.copyWith(
                                        color: c.isPlaceSaved(placeId)
                                            ? AppColors.serviceGreen
                                            : AppColors.serviceGray,
                                        fontSize: 14.sp,
                                      ),
                                    ),

                                    SvgPicture.asset(
                                        c.isPlaceSaved(placeId) ? 'assets/images/home/saved.svg' : 'assets/images/home/save.svg'
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 10.h,),

                      // Title, rating, cost
                      Row(
                        spacing: 12.w,
                        children: [
                          Text(
                            title,
                            style: h1.copyWith(
                              color: AppColors.serviceBlack,
                              fontSize: 22.sp,
                            ),
                          ),

                          Row(
                            children: [
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
                            ],
                          ),

                          Text(
                            '€€',
                            style: h2.copyWith(
                              color: AppColors.top5Black,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h,),

                      // Distance & Type chip
                      Row(
                        spacing: 12.w,
                        children: [
                          Text(
                            '$distance / ${time.toStringAsFixed(0)} min walk',
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
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                            child: Text(
                              type,
                              style: h4.copyWith(
                                color: AppColors.serviceText2,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h,),

                      // Why it's in Top 5
                      Text(
                        'Why it’s in the Top 5'.tr,
                        style: h2.copyWith(
                          color: AppColors.serviceBlack,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 14.h,),

                      if (controller.detailsLoading.value)
                        const Center(child: CircularProgressIndicator())
                      else if (detailsReady)
                        Column(
                          spacing: 12.h,
                          children: (controller.placeAiDetails['ai_summary'] as List? ?? [])
                              .map((s) => WhyTop5Point(text: s.toString()))
                              .toList(),
                        )
                      else
                        Column(
                          spacing: 12.h,
                          children: [
                            for (int i = 0; i < reasons.length; i++)
                              WhyTop5Point(text: reasons[i]),
                          ],
                        ),

                      SizedBox(height: 24.h,),

                      // Buttons: Book / Directions / Call
                      Row(
                        spacing: 25.w,
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Book'.tr,
                              paddingLeft: 35,
                              paddingRight: 35,
                              paddingTop: 8,
                              paddingBottom: 8,
                              borderRadius: 6,
                              textSize: 12,
                              onTap: _searchOnGoogle,
                            ),
                          ),

                          Expanded(
                            child: CustomButton(
                              text: 'Directions'.tr,
                              prefixIcon: 'assets/images/home/directions2.svg',
                              paddingLeft: 12,
                              paddingRight: 12,
                              paddingTop: 8,
                              paddingBottom: 8,
                              borderRadius: 6,
                              color: AppColors.top5Transparent,
                              borderColor: AppColors.serviceGray,
                              textColor: AppColors.serviceGray,
                              textSize: 12,
                              onTap: _openDirections,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ---- NO MAP SECTION BELOW ----

                // Optional: “More Details” section (same as normal details)
                SizedBox(height: 20.h,),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 151.w),
                  child: GestureDetector(
                    onTap: () => controller.isMoreDetails.value = !controller.isMoreDetails.value,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.serviceGreen,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        controller.isMoreDetails.value ? 'See Less'.tr : 'More Details'.tr,
                        style: h3.copyWith(
                          color: AppColors.serviceWhite,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),

                controller.isMoreDetails.value
                    ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h,),

                      Text(
                        'Review highlights'.tr,
                        style: h2.copyWith(
                          color: AppColors.serviceBlack,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 12.h,),

                      Obx(() {
                        final detailsReadyLocal = controller.placeAiDetails.isNotEmpty && !controller.detailsLoading.value;
                        if (!detailsReadyLocal) return const SizedBox.shrink();
                        final ratings = controller.placeAiDetails['ai_ratings'] as Map<String, dynamic>? ?? {};
                        return Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: ratings.entries
                              .map((e) => DetailsTagCard(text: '${e.key.capitalizeFirst} ${e.value}'))
                              .toList(),
                        );
                      }),

                      SizedBox(height: 24.h,),

                      Text(
                        'Best time / Busy now'.tr,
                        style: h2.copyWith(
                          color: AppColors.serviceBlack,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 12.h,),

                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: [
                          DetailsTagCard(text: 'Best time'.tr, isActive: true),
                          DetailsTagCard(text: 'Busy now'.tr),
                          DetailsTagCard(text: 'Quiet now'.tr),
                          DetailsTagCard(text: 'Busier after 8 pm'.tr),
                        ],
                      ),

                      SizedBox(height: 24.h,),

                      Text(
                        'Top dishes / Amenities'.tr,
                        style: h2.copyWith(
                          color: AppColors.serviceBlack,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 12.h,),

                      Obx(() {
                        final detailsReadyLocal = controller.placeAiDetails.isNotEmpty && !controller.detailsLoading.value;
                        if (!detailsReadyLocal) return const SizedBox.shrink();
                        final types = controller.placeAiDetails['types'] as List? ?? [];
                        return Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: types
                              .map((t) => DetailsTagCard(text: t.toString().capitalizeFirst ?? t.toString()))
                              .toList(),
                        );
                      }),

                      SizedBox(height: 24.h,),

                      Text(
                        'Hours & contact'.tr,
                        style: h2.copyWith(
                          color: AppColors.serviceBlack,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 12.h,),

                      Obx(() {
                        final detailsReadyLocal = controller.placeDetails.isNotEmpty && !controller.detailsLoading.value;
                        if (!detailsReadyLocal) return const SizedBox.shrink();
                        var website = controller.placeDetails['website'] as String? ?? '';
                        var contactTime = controller.placeDetails['contact_time'] as String? ?? '';
                        return Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: [
                            DetailsTagCard(text: contactTime),
                            website.isNotEmpty
                                ? DetailsTagCard(
                              text: 'Website'.tr,
                              icon: 'assets/images/home/website.svg',
                              onTap: () {
                                website = website.startsWith('http://')
                                    ? website.replaceFirst('http://', 'https://')
                                    : website;
                                Get.to(() => WebViewPage(url: website));
                              },
                            )
                                : const SizedBox.shrink(),
                          ],
                        );
                      }),
                    ],
                  ),
                )
                    : const SizedBox.shrink(),

                SizedBox(height: 24.h),
              ],
            );
          }),
        ),
      ),
    );
  }
}
