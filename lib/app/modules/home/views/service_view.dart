import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/home/controllers/home_controller.dart';
import 'package:top5/app/modules/home/views/details_view.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';
import 'package:top5/common/widgets/custom_button.dart';

import 'home_view.dart';

class ServiceView extends GetView<HomeController> {
  final String appBarTitle;

  const ServiceView({required this.appBarTitle, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ServiceAppBar(appBarTitle: appBarTitle),
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
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

                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                spacing: 10.w,
                                children: [
                                  CategorySelectionCard(
                                    text: 'Restaurant',
                                    icon: 'assets/images/home/restaurant.svg',
                                    selectedCategory: controller
                                        .selectedCategory,
                                    index: 0,
                                    color: controller.selectedCategory[0].value
                                        ? AppColors.homeGreen
                                        : AppColors.homeInactiveBg,
                                    textColor:
                                    controller.selectedCategory[0].value
                                        ? AppColors.homeWhite
                                        : AppColors.homeGray,
                                  ),

                                  CategorySelectionCard(
                                    text: 'Cafes',
                                    icon: 'assets/images/home/coffee_x5F_cup.svg',
                                    selectedCategory: controller
                                        .selectedCategory,
                                    index: 1,
                                    color: controller.selectedCategory[1].value
                                        ? AppColors.homeGreen
                                        : AppColors.homeInactiveBg,
                                    textColor:
                                    controller.selectedCategory[1].value
                                        ? AppColors.homeWhite
                                        : AppColors.homeGray,
                                  ),

                                  CategorySelectionCard(
                                    text: 'Bars',
                                    icon: 'assets/images/home/bars.svg',
                                    selectedCategory: controller
                                        .selectedCategory,
                                    index: 2,
                                    color: controller.selectedCategory[2].value
                                        ? AppColors.homeGreen
                                        : AppColors.homeInactiveBg,
                                    textColor:
                                    controller.selectedCategory[2].value
                                        ? AppColors.homeWhite
                                        : AppColors.homeGray,
                                  ),

                                  CategorySelectionCard(
                                    text: 'Activities',
                                    icon: 'assets/images/home/activities.svg',
                                    selectedCategory: controller
                                        .selectedCategory,
                                    index: 3,
                                    color: controller.selectedCategory[3].value
                                        ? AppColors.homeGreen
                                        : AppColors.homeInactiveBg,
                                    textColor:
                                    controller.selectedCategory[3].value
                                        ? AppColors.homeWhite
                                        : AppColors.homeGray,
                                  ),

                                  CategorySelectionCard(
                                    text: 'Services',
                                    icon: 'assets/images/home/services.svg',
                                    selectedCategory: controller
                                        .selectedCategory,
                                    index: 4,
                                    color: controller.selectedCategory[4].value
                                        ? AppColors.homeGreen
                                        : AppColors.homeInactiveBg,
                                    textColor:
                                    controller.selectedCategory[4].value
                                        ? AppColors.homeWhite
                                        : AppColors.homeGray,
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 24.h),

                          HomeSearchBar(
                            searchBarText: '“Search in $appBarTitle”',
                          ),

                          SizedBox(height: 16.38.h),

                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                spacing: 10.w,
                                children: [
                                  FilterSelectionCard(
                                    text: 'Open now',
                                    selectedFilter: controller.selectedFilter,
                                    index: 0,
                                    color: controller.selectedFilter[0].value
                                        ? AppColors.homeGreen
                                        : AppColors.homeInactiveBg,
                                    textColor: controller.selectedFilter[0]
                                        .value
                                        ? AppColors.homeWhite
                                        : AppColors.homeGray,
                                  ),

                                  FilterSelectionCard(
                                    text: '10 min',
                                    selectedFilter: controller.selectedFilter,
                                    index: 1,
                                    color: controller.selectedFilter[1].value
                                        ? AppColors.homeGreen
                                        : AppColors.homeInactiveBg,
                                    textColor: controller.selectedFilter[1]
                                        .value
                                        ? AppColors.homeWhite
                                        : AppColors.homeGray,
                                  ),

                                  FilterSelectionCard(
                                    text: '1 km',
                                    selectedFilter: controller.selectedFilter,
                                    index: 2,
                                    color: controller.selectedFilter[2].value
                                        ? AppColors.homeGreen
                                        : AppColors.homeInactiveBg,
                                    textColor: controller.selectedFilter[2]
                                        .value
                                        ? AppColors.homeWhite
                                        : AppColors.homeGray,
                                  ),

                                  FilterSelectionCard(
                                    text: 'Outdoor',
                                    selectedFilter: controller.selectedFilter,
                                    index: 3,
                                    color: controller.selectedFilter[3].value
                                        ? AppColors.homeGreen
                                        : AppColors.homeInactiveBg,
                                    textColor: controller.selectedFilter[3]
                                        .value
                                        ? AppColors.homeWhite
                                        : AppColors.homeGray,
                                  ),

                                  FilterSelectionCard(
                                    text: 'Vegetarian',
                                    selectedFilter: controller.selectedFilter,
                                    index: 4,
                                    color: controller.selectedFilter[4].value
                                        ? AppColors.homeGreen
                                        : AppColors.homeInactiveBg,
                                    textColor: controller.selectedFilter[4]
                                        .value
                                        ? AppColors.homeWhite
                                        : AppColors.homeGray,
                                  ),

                                  FilterSelectionCard(
                                    text: 'Bookable',
                                    selectedFilter: controller.selectedFilter,
                                    index: 5,
                                    color: controller.selectedFilter[5].value
                                        ? AppColors.homeGreen
                                        : AppColors.homeInactiveBg,
                                    textColor: controller.selectedFilter[5]
                                        .value
                                        ? AppColors.homeWhite
                                        : AppColors.homeGray,
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: 34.h),
                        ],
                      ),
                    ),

                    controller.isListView.value
                          ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Top 5 near you',
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
                                          'Map',
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
                                Top5NearYouListCard(
                                  serialNo: 1,
                                  title: 'Bella Italia',
                                  rating: 4.7,
                                  image:
                                  'assets/images/home/bella_italia.jpg',
                                  isPromo: true,
                                  status: 'Open',
                                  distance: '450m',
                                  time: 6,
                                  type: 'Italian',
                                  primeReason: 'Best value within 1 km, sunny terrace',
                                  reasons: [
                                    'Wood-fired pizza, 1k+ reviews',
                                    '6-min walk, sunny terrace',
                                  ],
                                  isSaved: false.obs,
                                  selectedLocations: controller.selectedLocations,
                                ),

                                Top5NearYouListCard(
                                  serialNo: 2,
                                  title: 'Sushi Zen',
                                  rating: 4.6,
                                  image: 'assets/images/home/sushi_zen.jpg',
                                  isPromo: false,
                                  status: 'Open',
                                  distance: '700m',
                                  time: 10,
                                  type: 'Korean',
                                  primeReason: 'Best value within 1 km, sunny terrace',
                                  reasons: [
                                    'Wood-fired pizza, 1k+ reviews',
                                    '6-min walk, sunny terrace',
                                  ],
                                  isSaved: false.obs,
                                  selectedLocations: controller.selectedLocations,
                                ),

                                Top5NearYouListCard(
                                  serialNo: 3,
                                  title: 'The Green Bistro',
                                  rating: 4.5,
                                  image:
                                  'assets/images/home/the_green_bistro.jpg',
                                  isPromo: false,
                                  status: 'Open',
                                  distance: '900m',
                                  time: 20,
                                  type: 'Korean',
                                  primeReason: 'Best value within 1 km, sunny terrace',
                                  reasons: [
                                    'Wood-fired pizza, 1k+ reviews',
                                    '6-min walk, sunny terrace',
                                  ],
                                  isSaved: false.obs,
                                  selectedLocations: controller.selectedLocations,
                                ),

                                Top5NearYouListCard(
                                  serialNo: 4,
                                  title: 'Spice Route',
                                  rating: 4.4,
                                  image:
                                  'assets/images/home/spice_route.jpg',
                                  isPromo: false,
                                  status: 'Open',
                                  distance: '1.km',
                                  time: 25,
                                  type: 'Indian',
                                  primeReason: 'Best value within 1 km, sunny terrace',
                                  reasons: [
                                    'Wood-fired pizza, 1k+ reviews',
                                    '6-min walk, sunny terrace',
                                  ],
                                  isSaved: false.obs,
                                  selectedLocations: controller.selectedLocations,
                                ),

                                Top5NearYouListCard(
                                  serialNo: 5,
                                  title: 'Le Petit Cafe',
                                  rating: 4.3,
                                  image:
                                  'assets/images/home/le_petit_cafe.jpg',
                                  isPromo: false,
                                  status: 'Open',
                                  distance: '1.1km',
                                  time: 30,
                                  type: 'France',
                                  primeReason: 'Best value within 1 km, sunny terrace',
                                  reasons: [
                                    'Wood-fired pizza, 1k+ reviews',
                                    '6-min walk, sunny terrace',
                                  ],
                                  isSaved: false.obs,
                                  selectedLocations: controller.selectedLocations,
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),
                          ],
                        ),
                      )
                          : Stack(
                        children: [
                          Image.asset(
                            'assets/images/home/map_bg.jpg',
                            fit: BoxFit.cover,
                            scale: 4,
                          ),

                          LocationPointer(
                            serialNo: 1,
                            latitude: 218.33,
                            longitude: 45.67,
                            name: 'Bella Italia',
                            image: 'assets/images/home/bella_italia.jpg',
                            selectedLocations: controller.selectedLocations,
                          ),

                          LocationPointer(
                            serialNo: 2,
                            latitude: 293.33,
                            longitude: 73.67,
                            name: 'Sushi Zen',
                            image: 'assets/images/home/sushi_zen.jpg',
                            selectedLocations: controller.selectedLocations,
                          ),

                          LocationPointer(
                            serialNo: 3,
                            latitude: 338.33,
                            longitude: 133.67,
                            name: 'The Green Bistro',
                            image:
                            'assets/images/home/the_green_bistro.jpg',
                            selectedLocations: controller.selectedLocations,
                          ),

                          LocationPointer(
                            serialNo: 4,
                            latitude: 184.33,
                            longitude: 155.67,
                            name: 'Spice Route',
                            image: 'assets/images/home/spice_route.jpg',
                            selectedLocations: controller.selectedLocations,
                          ),

                          LocationPointer(
                            serialNo: 5,
                            latitude: 65.33,
                            longitude: 153.67,
                            name: 'Le Petit Cafe',
                            image: 'assets/images/home/le_petit_cafe.jpg',
                            selectedLocations: controller.selectedLocations,
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              controller.isListView.value == false ? DraggableScrollableSheet(
                initialChildSize: 0.48,
                minChildSize: 0.48,
                maxChildSize: 1.0,
                builder:
                    (BuildContext context, ScrollController scrollController) {
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
                          onVerticalDragUpdate: controller.onDragUpdate,
                          isOnDesktopAndWeb: controller.isOnDesktopAndWeb,
                        ),

                        SizedBox(height: 13.h,),

                        Container(
                          width: 60.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.r),
                            color: AppColors.serviceGrabColor,
                          ),
                        ),

                        SizedBox(height: 11.h,),

                        Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Top 5 near you',
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
                                  child: Text(
                                    'List View',
                                    style: h4.copyWith(
                                      color: AppColors.serviceGray,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        SizedBox(height: 16.h,),

                        Expanded(
                          child: SingleChildScrollView(
                            controller: controller.isOnDesktopAndWeb ? null : scrollController,
                            child: Column(
                              spacing: 20.h,
                              children: [
                                Top5NearYouMapCard(
                                  serialNo: 1,
                                  title: 'Bella Italia',
                                  rating: 4.7,
                                  image:
                                  'assets/images/home/bella_italia.jpg',
                                  isPromo: true,
                                  status: 'Open',
                                  distance: '450m',
                                  time: 6,
                                  type: 'Italian',
                                  selectedLocations: controller.selectedLocations,
                                ),

                                Top5NearYouMapCard(
                                  serialNo: 2,
                                  title: 'Sushi Zen',
                                  rating: 4.6,
                                  image: 'assets/images/home/sushi_zen.jpg',
                                  isPromo: false,
                                  status: 'Open',
                                  distance: '700m',
                                  time: 10,
                                  type: 'Korean',
                                  selectedLocations: controller.selectedLocations,
                                ),

                                Top5NearYouMapCard(
                                  serialNo: 3,
                                  title: 'The Green Bistro',
                                  rating: 4.5,
                                  image:
                                  'assets/images/home/the_green_bistro.jpg',
                                  isPromo: false,
                                  status: 'Open',
                                  distance: '900m',
                                  time: 20,
                                  type: 'Korean',
                                  selectedLocations: controller.selectedLocations,
                                ),

                                Top5NearYouMapCard(
                                  serialNo: 4,
                                  title: 'Spice Route',
                                  rating: 4.4,
                                  image:
                                  'assets/images/home/spice_route.jpg',
                                  isPromo: false,
                                  status: 'Open',
                                  distance: '1.km',
                                  time: 25,
                                  type: 'Indian',
                                  selectedLocations: controller.selectedLocations,
                                ),

                                Top5NearYouMapCard(
                                  serialNo: 5,
                                  title: 'Le Petit Cafe',
                                  rating: 4.3,
                                  image:
                                  'assets/images/home/le_petit_cafe.jpg',
                                  isPromo: false,
                                  status: 'Open',
                                  distance: '1.1km',
                                  time: 30,
                                  type: 'France',
                                  selectedLocations: controller.selectedLocations,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  );
                },
              ) : SizedBox.shrink(),
            ],
          );
        }),
      ),
    );
  }
}

class ServiceAppBar extends StatelessWidget {
  final String appBarTitle;

  const ServiceAppBar({required this.appBarTitle, super.key});

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
              size: 18.r,
            ),
          ),
        ),

        Text(
          appBarTitle,
          style: h3.copyWith(color: AppColors.top5Black, fontSize: 24.sp),
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
            backgroundImage: AssetImage('assets/images/home/profile_pic.jpg'),
          ),
        ),
      ],
    );
  }
}

class Top5NearYouListCard extends StatelessWidget {
  final int serialNo;
  final String title;
  final double rating;
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

  const Top5NearYouListCard({
    required this.serialNo,
    required this.title,
    required this.rating,
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            isSaved: isSaved,
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
            Container(
              padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 8.h, bottom: 156.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                image: DecorationImage(
                  image: AssetImage(
                    image,
                  ),
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

                  Container(
                    padding: EdgeInsets.all(9.33.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.serviceWhite,
                    ),
                    child: SvgPicture.asset(
                      'assets/images/home/save.svg'
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 9.w, right: 9.w, bottom: 25.h),
              child: Column(
                spacing: 7.h,
                children: [
                  Row(
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

                      Text(
                        title,
                        style: h2.copyWith(
                          color: AppColors.serviceBlack,
                          fontSize: 16.sp,
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
                        '($rating)',
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
                    ],
                  ),

                  Row(
                    children: [
                      Text(
                        'Why this pick: ',
                        style: h2.copyWith(
                          color: AppColors.serviceGray,
                          fontSize: 11.9.sp,
                        ),
                      ),

                      Text(
                        primeReason,
                        style: h4.copyWith(
                          color: AppColors.serviceGray,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        text: 'Directions',
                        prefixIcon: 'assets/images/home/directions.svg',
                        paddingLeft: 12,
                        paddingRight: 12,
                        paddingTop: 8,
                        paddingBottom: 8,
                        borderRadius: 6,
                        textSize: 12,
                        onTap: () {},
                      ),

                      CustomButton(
                        text: 'Book',
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

                      CustomButton(
                        text: '',
                        icon: 'assets/images/home/call.svg',
                        paddingLeft: 40,
                        paddingRight: 20,
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
          ],
        ),
      ),
    );
  }
}

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
  final RxList<RxBool> selectedLocations;
  
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
    required this.selectedLocations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                )
              ],
            ),

            SizedBox(height: 12.h,),

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
                      image: AssetImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.top5Transparent,
                      borderRadius: BorderRadius.circular(16.r),
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

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.h,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: h2.copyWith(
                            color: AppColors.serviceBlack,
                            fontSize: 16.sp,
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

                    Row(
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

                        Row(
                          spacing: 4.w,
                          children: [
                            Text(
                              'Cuisine',
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
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                  text: 'Directions',
                  prefixIcon: 'assets/images/home/directions.svg',
                  paddingLeft: 12,
                  paddingRight: 12,
                  paddingTop: 8,
                  paddingBottom: 8,
                  borderRadius: 6,
                  textSize: 12,
                  onTap: () {},
                ),

                CustomButton(
                  text: 'Book',
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

                CustomButton(
                  text: '',
                  icon: 'assets/images/home/call.svg',
                  paddingLeft: 40,
                  paddingRight: 20,
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
                decoration: BoxDecoration(
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
                        borderRadius: BorderRadius.circular(6.r),
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
                              borderRadius: BorderRadius.circular(6.r),
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
                : SizedBox.shrink(),
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
