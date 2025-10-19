import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/home/controllers/home_controller.dart';
import 'package:top5/app/modules/profile/controllers/profile_controller.dart';
import 'package:top5/app/modules/search/views/results_view.dart';
import 'package:top5/common/custom_fonts.dart';

import '../../../../common/app_colors.dart';
import '../../home/views/home_view.dart';
import '../../profile/views/recent_list_view.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(SearchController());
    ProfileController profileController = Get.put(ProfileController());
    HomeController homeController = Get.put(HomeController());

    // Receive arguments if coming from idea click
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['searchText'] != null) {
      controller.setSearchQuery(args['searchText']);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SearchAppBar(),
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
                SearchBar(searchBarText: controller.searchBarTextController,),

                SizedBox(height: 12.h,),

                Text(
                  'Recent searches',
                  style: h2.copyWith(
                    color: AppColors.searchBlack,
                    fontSize: 20.sp,
                  ),
                ),

                SizedBox(height: 12.h,),

                Obx(() {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 4.w,
                      children: [
                        if (!controller.isRemoved[0].value)
                          RecentSearchCard(
                            search: 'New',
                            isRemoved: controller.isRemoved[0],
                          ),

                        if (!controller.isRemoved[1].value)
                          RecentSearchCard(
                            search: 'Famous',
                            isRemoved: controller.isRemoved[1],
                          ),

                        if (!controller.isRemoved[2].value)
                          RecentSearchCard(
                            search: 'Drinks',
                            isRemoved: controller.isRemoved[2],
                          ),

                        if (!controller.isRemoved[3].value)
                          RecentSearchCard(
                            search: 'Lunch',
                            isRemoved: controller.isRemoved[3],
                          ),

                        if (!controller.isRemoved[4].value)
                          RecentSearchCard(
                            search: 'Dinner',
                            isRemoved: controller.isRemoved[4],
                          ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 20.h,),

                Text(
                  'Popular near you',
                  style: h2.copyWith(
                    color: AppColors.searchBlack,
                    fontSize: 20.sp,
                  ),
                ),

                SizedBox(height: 12.h,),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 4.w,
                    children: [
                      PopularNearYouCard(text: 'Pizza'),

                      PopularNearYouCard(text: 'Cocktail bars'),

                      PopularNearYouCard(text: 'Cocktail bars'),

                      PopularNearYouCard(text: 'Gyms'),
                    ],
                  ),
                ),

                SizedBox(height: 20.h,),

                Text(
                  'By category',
                  style: h2.copyWith(
                    color: AppColors.searchBlack,
                    fontSize: 20.sp,
                  ),
                ),

                SizedBox(height: 12.h,),

                Obx(() {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 10.w,
                      children: [
                        CategorySelectionCard(
                          text: 'Restaurant',
                          icon: 'assets/images/home/restaurant.svg',
                          selectedCategory: controller.selectedCategory,
                          index: 0,
                          color: controller.selectedCategory[0].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                          textColor: controller.selectedCategory[0].value ? AppColors.homeWhite : AppColors.homeGray,
                        ),

                        CategorySelectionCard(
                          text: 'Cafes',
                          icon: 'assets/images/home/coffee_x5F_cup.svg',
                          selectedCategory: controller.selectedCategory,
                          index: 1,
                          color: controller.selectedCategory[1].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                          textColor: controller.selectedCategory[1].value ? AppColors.homeWhite : AppColors.homeGray,
                        ),

                        CategorySelectionCard(
                          text: 'Bars',
                          icon: 'assets/images/home/bars.svg',
                          selectedCategory: controller.selectedCategory,
                          index: 2,
                          color: controller.selectedCategory[2].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                          textColor: controller.selectedCategory[2].value ? AppColors.homeWhite : AppColors.homeGray,
                        ),

                        CategorySelectionCard(
                          text: 'Activities',
                          icon: 'assets/images/home/activities.svg',
                          selectedCategory: controller.selectedCategory,
                          index: 3,
                          color: controller.selectedCategory[3].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                          textColor: controller.selectedCategory[3].value ? AppColors.homeWhite : AppColors.homeGray,
                        ),

                        CategorySelectionCard(
                          text: 'Services',
                          icon: 'assets/images/home/services.svg',
                          selectedCategory: controller.selectedCategory,
                          index: 4,
                          color: controller.selectedCategory[4].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                          textColor: controller.selectedCategory[4].value ? AppColors.homeWhite : AppColors.homeGray,
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 28.h,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      return Text(
                        'Top 5 ${controller.searchText.value}',
                        style: h2.copyWith(
                          color: AppColors.searchBlack,
                          fontSize: 24.sp,
                        ),
                      );
                    }),

                    GestureDetector(
                      onTap: () => Get.to(ResultsView(searchText: controller.searchText.value,)),
                      child: Text(
                        'See all',
                        style: h4.copyWith(
                          color: AppColors.searchGreen,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  ],
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


class SearchAppBar extends StatelessWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset(
          'assets/images/home/top_5_green_logo.svg',
        ),

        Text(
          'Search',
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


class SearchBar extends StatelessWidget {
  final TextEditingController searchBarText;

  const SearchBar({
    required this.searchBarText,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final searchController = Get.find<SearchController>();
    final homeController = Get.find<HomeController>();

    return TextFormField(
      controller: searchBarText,
      onFieldSubmitted: (value) {
        searchController.setSearchQuery(value);
        homeController.performSearch(value);
      },

      decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h,),

          filled: true,
          fillColor: AppColors.homeSearchBg,

          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.r),
              borderSide: BorderSide(
                color: AppColors.top5Transparent,
              )
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.r),
              borderSide: BorderSide(
                color: AppColors.top5Transparent,
              )
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.r),
              borderSide: BorderSide(
                color: AppColors.top5Transparent,
              )
          ),

          hintText: searchBarText.text,
          hintStyle: h4.copyWith(
            color: AppColors.homeGray,
            fontSize: 14.sp,
          ),

          prefixIcon: Image.asset(
            'assets/images/home/search.png',
            scale: 4,
          ),

          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            spacing: 8.w,
            children: [
              Image.asset(
                'assets/images/home/voice.png',
                scale: 4,
              ),

              Container(
                width: 1.w,
                height: 20.h,
                color: AppColors.homeSearchBarLineColor,
              ),

              Image.asset(
                'assets/images/home/filter.png',
                scale: 4,
              ),

              Text(
                'Filter',
                style: h4.copyWith(
                  color: AppColors.homeGray,
                  fontSize: 12.sp,
                ),
              ),

              SizedBox(width: 20.w,),
            ],
          )
      ),
    );
  }
}


class RecentSearchCard extends StatelessWidget {
  final String search;
  final RxBool isRemoved;

  const RecentSearchCard({
    required this.search,
    required this.isRemoved,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppColors.searchSearchBg,
      ),
      child: Row(
        spacing: 4.w,
        children: [
          Text(
            search,
            style: h3.copyWith(
              color: AppColors.searchGray,
              fontSize: 12.sp,
            ),
          ),

          GestureDetector(
            onTap: () {
              isRemoved.value = true;
            },
            child: Icon(
              Icons.close,
              size: 11.r,
              color: AppColors.searchGray,
            ),
          )
        ],
      ),
    );
  }
}


class PopularNearYouCard extends StatelessWidget {
  final String text;

  const PopularNearYouCard({
    required this.text,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppColors.searchSearchBg,
      ),
      child: Row(
        spacing: 4.w,
        children: [
          Text(
            text,
            style: h3.copyWith(
              color: AppColors.searchGray,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
