import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:top5/app/modules/search/views/search_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/home_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/search_controller.dart';
import '../../profile/views/recent_list_view.dart';

class ResultsView extends GetView<SearchController> {
  final String searchText;
  const ResultsView({required this.searchText, super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller exists and we trigger a search for this screen
    if (!Get.isRegistered<SearchController>()) {
      Get.put(SearchController());
    }
    final profileController = Get.find<ProfileController>();
    final homeController = Get.put(HomeController());

    // run the query for results screen
    controller.setSearchQuery(searchText);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ResultsAppBar(profileController: profileController),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top 5 $searchText',
                    style: h2.copyWith(color: AppColors.searchBlack, fontSize: 24.sp)),
                SizedBox(height: 12.h),

                /// Filter chips – already wired to refetch
                Obx(() {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 10.w,
                      children: [
                        FilterSelectionCard(
                          text: 'Open now'.tr,
                          selectedFilter: controller.selectedFilter,
                          index: 0,
                          color: controller.selectedFilter[0].value
                              ? AppColors.homeGreen
                              : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[0].value
                              ? AppColors.homeWhite
                              : AppColors.homeGray,
                          page: 'Results',
                        ),
                        FilterSelectionCard(
                          text: '10 min',
                          selectedFilter: controller.selectedFilter,
                          index: 1,
                          color: controller.selectedFilter[1].value
                              ? AppColors.homeGreen
                              : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[1].value
                              ? AppColors.homeWhite
                              : AppColors.homeGray,
                          page: 'Results',
                        ),
                        FilterSelectionCard(
                          text: Get.find<ProfileController>().selectedDistanceUnit[0].value
                              ? '1 km'
                              : "${homeController.convertToMiles('1 km').toStringAsFixed(2)} miles",
                          selectedFilter: controller.selectedFilter,
                          index: 2,
                          color: controller.selectedFilter[2].value
                              ? AppColors.homeGreen
                              : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[2].value
                              ? AppColors.homeWhite
                              : AppColors.homeGray,
                          page: 'Results',
                        ),
                        FilterSelectionCard(
                          text: 'Outdoor'.tr,
                          selectedFilter: controller.selectedFilter,
                          index: 3,
                          color: controller.selectedFilter[3].value
                              ? AppColors.homeGreen
                              : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[3].value
                              ? AppColors.homeWhite
                              : AppColors.homeGray,
                          page: 'Results',
                        ),
                        FilterSelectionCard(
                          text: 'Vegetarian'.tr,
                          selectedFilter: controller.selectedFilter,
                          index: 4,
                          color: controller.selectedFilter[4].value
                              ? AppColors.homeGreen
                              : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[4].value
                              ? AppColors.homeWhite
                              : AppColors.homeGray,
                          page: 'Results',
                        ),
                        FilterSelectionCard(
                          text: 'Bookable'.tr,
                          selectedFilter: controller.selectedFilter,
                          index: 5,
                          color: controller.selectedFilter[5].value
                              ? AppColors.homeGreen
                              : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[5].value
                              ? AppColors.homeWhite
                              : AppColors.homeGray,
                          page: 'Results',
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 20.h),

                /// DYNAMIC RESULTS
                Obx(() {
                  if (controller.loading.value) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (controller.error.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Text(
                        controller.error.value,
                        style: h3.copyWith(color: Colors.red, fontSize: 12.sp),
                      ),
                    );
                  }
                  if (controller.results.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Text(
                        'No results found.',
                        style: h4.copyWith(color: AppColors.homeGray, fontSize: 14.sp),
                      ),
                    );
                  }

                  final selected = homeController.selectedLocations;
                  return Column(
                    spacing: 16.h,
                    children: List.generate(controller.results.length, (i) {
                      final p = controller.results[i];
                      final status = (p.openNow == true) ? 'Open'.tr : 'Closed'.tr;
                      final timeMins = _parseMinutes(p.durationText ?? '');
                      final type = _typeFromPlace(p);
                      final reasons = [
                        '⭐ ${p.rating?.toStringAsFixed(1) ?? '-'} • ${p.reviewsCount ?? 0} reviews',
                        p.distanceText ?? '',
                      ];
                      return SearchListCard(
                        serialNo: i + 1,
                        title: p.name ?? 'Unknown',
                        rating: p.rating ?? 0.0,
                        image: p.thumbnail ?? '',
                        isPromo: false,
                        status: status,
                        distance: p.distanceText ?? '',
                        time: timeMins.toDouble(),
                        type: type,
                        reasons: reasons,
                        isSaved: false.obs,
                        selectedLocations: selected,
                        placeId: p.placeId ?? '', // NEW
                        destLat: p.latitude ?? 0.0, // NEW
                        destLng: p.longitude ?? 0.0, // NEW
                        directionUrl: p.directionUrl ?? '',
                      );
                    }),
                  );
                }),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultsAppBar extends StatelessWidget {
  final ProfileController profileController;

  const ResultsAppBar({
    required this.profileController,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: EdgeInsets.all(6.r),
            decoration: const BoxDecoration(
              color: AppColors.serviceBlack,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: AppColors.serviceWhite, size: 18.r),
          ),
        ),
        Text('Results'.tr,
            style: h3.copyWith(color: AppColors.top5Black, fontSize: 24.sp)),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.homeProfileBorderColor, width: 2),
          ),
          child:CircleAvatar(
            radius: 16.r,
            backgroundImage: profileController.image.value == '' ?
            const AssetImage(
              'assets/images/home/profile_pic.jpg',
            )
                :
            NetworkImage(
              'http://10.10.13.99:8005${profileController.image.value}',
            ) as ImageProvider,
          ),
        )
      ],
    );
  }
}

int _parseMinutes(String s) {
  final m = RegExp(r'(\d+)').firstMatch(s);
  if (m == null) return 0;
  return int.tryParse(m.group(1)!) ?? 0;
}

String _typeFromPlace(dynamic p) {
  if (p.types != null && p.types is List && (p.types as List).isNotEmpty) {
    final first = (p.types as List).first.toString();
    return first[0].toUpperCase() + first.substring(1);
  }
  return 'Restaurant';
}
