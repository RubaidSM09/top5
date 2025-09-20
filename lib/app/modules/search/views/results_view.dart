import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/home_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/search_controller.dart';
import '../../profile/views/recent_list_view.dart';

class ResultsView extends GetView<SearchController> {
  final String searchText;

  const ResultsView({
    required this.searchText,
    super.key
  });
  @override
  Widget build(BuildContext context) {
    Get.put(SearchController());
    ProfileController profileController = Get.put(ProfileController());
    HomeController homeController = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ResultsAppBar(),
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
                Text(
                  'Top 5 $searchText',
                  style: h2.copyWith(
                    color: AppColors.searchBlack,
                    fontSize: 24.sp,
                  ),
                ),

                SizedBox(height: 12.h,),

                Obx(() {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 10.w,
                      children: [
                        FilterSelectionCard(
                          text: 'Open now',
                          selectedFilter: controller.selectedFilter,
                          index: 0,
                          color: controller.selectedFilter[0].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[0].value ? AppColors.homeWhite : AppColors.homeGray,
                        ),

                        FilterSelectionCard(
                          text: '10 min',
                          selectedFilter: controller.selectedFilter,
                          index: 1,
                          color: controller.selectedFilter[1].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[1].value ? AppColors.homeWhite : AppColors.homeGray,
                        ),

                        FilterSelectionCard(
                          text: profileController.selectedDistanceUnit[0].value ? '1 km' : "${homeController.convertToMiles('1 km').toStringAsFixed(2)} miles",
                          selectedFilter: controller.selectedFilter,
                          index: 2,
                          color: controller.selectedFilter[2].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[2].value ? AppColors.homeWhite : AppColors.homeGray,
                        ),

                        FilterSelectionCard(
                          text: 'Outdoor',
                          selectedFilter: controller.selectedFilter,
                          index: 3,
                          color: controller.selectedFilter[3].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[3].value ? AppColors.homeWhite : AppColors.homeGray,
                        ),

                        FilterSelectionCard(
                          text: 'Vegetarian',
                          selectedFilter: controller.selectedFilter,
                          index: 4,
                          color: controller.selectedFilter[4].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[4].value ? AppColors.homeWhite : AppColors.homeGray,
                        ),

                        FilterSelectionCard(
                          text: 'Bookable',
                          selectedFilter: controller.selectedFilter,
                          index: 5,
                          color: controller.selectedFilter[5].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                          textColor: controller.selectedFilter[5].value ? AppColors.homeWhite : AppColors.homeGray,
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 20.h,),

                Column(
                  spacing: 16.h,
                  children: [
                    RecentListCard(
                      serialNo: 1,
                      title: 'Bella Italia',
                      rating: 4.7,
                      image:
                      'assets/images/home/bella_italia.jpg',
                      isPromo: true,
                      status: 'Open',
                      distance: profileController.selectedDistanceUnit[0].value ? '450 m' : "${homeController.convertToMiles('450 m').toStringAsFixed(2)} miles",
                      time: 6,
                      type: 'Italian',
                      reasons: [
                        'Wood-fired pizza, 1k+ reviews',
                        '6-min walk, sunny terrace',
                      ],
                      isSaved: false.obs,
                      selectedLocations: homeController.selectedLocations,
                    ),

                    RecentListCard(
                      serialNo: 1,
                      title: 'La Tavola d’Oro',
                      rating: 4.5,
                      image:
                      'assets/images/profile/la_tavola_doro.jpg',
                      isPromo: false,
                      status: 'Open',
                      distance: profileController.selectedDistanceUnit[0].value ? '700 m' : "${homeController.convertToMiles('700 m').toStringAsFixed(2)} miles",
                      time: 10,
                      type: 'Italian',
                      reasons: [
                        'Wood-fired pizza, 1k+ reviews',
                        '6-min walk, sunny terrace',
                      ],
                      isSaved: true.obs,
                      selectedLocations: homeController.selectedLocations,
                    ),

                    RecentListCard(
                      serialNo: 1,
                      title: 'Trattoria Bella Vita',
                      rating: 4.5,
                      image:
                      'assets/images/profile/trattoria_bella_vita.jpg',
                      isPromo: false,
                      status: 'Open',
                      distance: profileController.selectedDistanceUnit[0].value ? '900 m' : "${homeController.convertToMiles('900 m').toStringAsFixed(2)} miles",
                      time: 20,
                      type: 'Italian',
                      reasons: [
                        'Wood-fired pizza, 1k+ reviews',
                        '6-min walk, sunny terrace',
                      ],
                      isSaved: true.obs,
                      selectedLocations: homeController.selectedLocations,
                    ),

                    RecentListCard(
                      serialNo: 1,
                      title: 'Sapori di Roma',
                      rating: 4.4,
                      image:
                      'assets/images/profile/sapori_di_roma.jpg',
                      isPromo: false,
                      status: 'Open',
                      distance: profileController.selectedDistanceUnit[0].value ? '1 km' : "${homeController.convertToMiles('1 km').toStringAsFixed(2)} miles",
                      time: 25,
                      type: 'Italian',
                      reasons: [
                        'Wood-fired pizza, 1k+ reviews',
                        '6-min walk, sunny terrace',
                      ],
                      isSaved: true.obs,
                      selectedLocations: homeController.selectedLocations,
                    ),

                    RecentListCard(
                      serialNo: 1,
                      title: 'Casa Toscana',
                      rating: 4.3,
                      image:
                      'assets/images/profile/casa_toscana.jpg',
                      isPromo: false,
                      status: 'Open',
                      distance: profileController.selectedDistanceUnit[0].value ? '1.1 km' : "${homeController.convertToMiles('1.1 km').toStringAsFixed(2)} miles",
                      time: 30,
                      type: 'Italian',
                      reasons: [
                        'Wood-fired pizza, 1k+ reviews',
                        '6-min walk, sunny terrace',
                      ],
                      isSaved: true.obs,
                      selectedLocations: homeController.selectedLocations,
                    ),

                    SizedBox(height: 16.h,),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class ResultsAppBar extends StatelessWidget {
  const ResultsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: AppColors.serviceBlack,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.serviceWhite,
              size: 15.r,
            ),
          ),
        ),

        Text(
          'Results',
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
              )
          ),
          child: CircleAvatar(
            radius: 16.r,
            backgroundImage: AssetImage(
              'assets/images/home/profile_pic.jpg',
            ),
          ),
        )
      ],
    );
  }
}
