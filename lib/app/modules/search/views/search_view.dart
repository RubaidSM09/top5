import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:top5/app/modules/search/views/search_details_view.dart';

import 'package:top5/common/custom_fonts.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/localization/localization_controller.dart';
import '../../../../common/voice/voice_service.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../secrets/secrets.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/details_view.dart';
import '../../home/views/google_map_webview.dart';
import '../../home/views/home_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/search_controller.dart';
import '../../profile/views/recent_list_view.dart';
import 'results_view.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SearchController());
    final profileController = Get.put(ProfileController());
    final homeController = Get.find<HomeController>();

    // If navigated with pre-filled search text (from ideas, etc.)
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['searchText'] != null) {
      controller.setSearchQuery(args['searchText']);
      controller.searchBarTextController.text = args['searchText'];
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SearchAppBar(),
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
                SearchBar(searchBarText: controller.searchBarTextController),

                SizedBox(height: 12.h),

                Text(
                  'Recent searches'.tr,
                  style: h2.copyWith(color: AppColors.searchBlack, fontSize: 20.sp),
                ),
                SizedBox(height: 12.h),

                Obx(() {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 4.w,
                      children: [
                        if (!controller.isRemoved[0].value)
                          RecentSearchCard(search: 'New', isRemoved: controller.isRemoved[0]),
                        if (!controller.isRemoved[1].value)
                          RecentSearchCard(search: 'Famous', isRemoved: controller.isRemoved[1]),
                        if (!controller.isRemoved[2].value)
                          RecentSearchCard(search: 'Drinks', isRemoved: controller.isRemoved[2]),
                        if (!controller.isRemoved[3].value)
                          RecentSearchCard(search: 'Lunch', isRemoved: controller.isRemoved[3]),
                        if (!controller.isRemoved[4].value)
                          RecentSearchCard(search: 'Dinner', isRemoved: controller.isRemoved[4]),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 20.h),

                Text(
                  'Popular near you'.tr,
                  style: h2.copyWith(color: AppColors.searchBlack, fontSize: 20.sp),
                ),
                SizedBox(height: 12.h),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 4.w,
                    children: const [
                      PopularNearYouCard(text: 'Pizza'),
                      PopularNearYouCard(text: 'Cocktail bars'),
                      PopularNearYouCard(text: 'Cocktail bars'),
                      PopularNearYouCard(text: 'Gyms'),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                Text(
                  'By category'.tr,
                  style: h2.copyWith(color: AppColors.searchBlack, fontSize: 20.sp),
                ),
                SizedBox(height: 12.h),

                /// Category chips (unchanged) – listening is wired in controller
                Obx(() {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 10.w,
                      children: [
                        CategorySelectionCardSearch(
                          text: 'Restaurant'.tr,
                          icon: 'assets/images/home/restaurant.svg',
                          selectedCategory: controller.selectedCategory,
                          index: 0,
                          color: controller.selectedCategory[0].value
                              ? AppColors.homeGreen
                              : AppColors.homeInactiveBg,
                          textColor: controller.selectedCategory[0].value
                              ? AppColors.homeWhite
                              : AppColors.homeGray,
                        ),
                        CategorySelectionCardSearch(
                          text: 'Cafes'.tr,
                          icon: 'assets/images/home/coffee_x5F_cup.svg',
                          selectedCategory: controller.selectedCategory,
                          index: 1,
                          color: controller.selectedCategory[1].value
                              ? AppColors.homeGreen
                              : AppColors.homeInactiveBg,
                          textColor: controller.selectedCategory[1].value
                              ? AppColors.homeWhite
                              : AppColors.homeGray,
                        ),
                        CategorySelectionCardSearch(
                          text: 'Bars'.tr,
                          icon: 'assets/images/home/bars.svg',
                          selectedCategory: controller.selectedCategory,
                          index: 2,
                          color: controller.selectedCategory[2].value
                              ? AppColors.homeGreen
                              : AppColors.homeInactiveBg,
                          textColor: controller.selectedCategory[2].value
                              ? AppColors.homeWhite
                              : AppColors.homeGray,
                        ),
                        CategorySelectionCardSearch(
                          text: 'Activities'.tr,
                          icon: 'assets/images/home/activities.svg',
                          selectedCategory: controller.selectedCategory,
                          index: 3,
                          color: controller.selectedCategory[3].value
                              ? AppColors.homeGreen
                              : AppColors.homeInactiveBg,
                          textColor: controller.selectedCategory[3].value
                              ? AppColors.homeWhite
                              : AppColors.homeGray,
                        ),
                        CategorySelectionCardSearch(
                          text: 'Services'.tr,
                          icon: 'assets/images/home/services.svg',
                          selectedCategory: controller.selectedCategory,
                          index: 4,
                          color: controller.selectedCategory[4].value
                              ? AppColors.homeGreen
                              : AppColors.homeInactiveBg,
                          textColor: controller.selectedCategory[4].value
                              ? AppColors.homeWhite
                              : AppColors.homeGray,
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 28.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      return SizedBox(
                        width: 261.w,
                        child: Text(
                          'Top 5 ${controller.searchText.value}',
                          style: h2.copyWith(color: AppColors.searchBlack, fontSize: 24.sp),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () =>
                          Get.to(ResultsView(searchText: controller.searchText.value)),
                      child: Text(
                        'See all'.tr,
                        style: h4.copyWith(color: AppColors.searchGreen, fontSize: 14.sp),
                      ),
                    )
                  ],
                ),

                SizedBox(height: 12.h),

                /// Filter chips – controller listens & re-fetches
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
                          page: 'Search',
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
                          page: 'Search',
                        ),
                        FilterSelectionCard(
                          text: profileController.selectedDistanceUnit[0].value
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
                          page: 'Search',
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
                          page: 'Search',
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
                          page: 'Search',
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
                          page: 'Search',
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 20.h),

                /// DYNAMIC RESULTS (Top 5)
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

int _parseMinutes(String s) {
  // e.g., "10 mins" -> 10, "4 min" -> 4
  final m = RegExp(r'(\d+)').firstMatch(s);
  if (m == null) return 0;
  return int.tryParse(m.group(1)!) ?? 0;
}

String _typeFromPlace(dynamic p) {
  // Try types array; fallback to 'Restaurant'
  if (p.types != null && p.types is List && (p.types as List).isNotEmpty) {
    final first = (p.types as List).first.toString();
    return first[0].toUpperCase() + first.substring(1);
  }
  return 'Restaurant';
}

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset('assets/images/home/top_5_green_logo.svg'),
        Text('Search'.tr, style: h3.copyWith(color: AppColors.top5Black, fontSize: 24.sp)),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.homeProfileBorderColor, width: 2),
          ),
          child: CircleAvatar(
            radius: 16.r,
            backgroundImage: const AssetImage('assets/images/home/profile_pic.jpg'),
          ),
        ),
      ],
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController searchBarText;
  const SearchBar({required this.searchBarText, super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = Get.find<SearchController>();
    final homeController = Get.find<HomeController>();
    final voice = Get.put(VoiceService());

    Future<void> _handleVoice() async {
      final text = await voice.listenOnce();
      if (text == null || text.isEmpty) {
        Get.snackbar('Voice', 'Didn\'t catch that. Please try again.');
        return;
      }
      searchBarText.text = text;
      // keep both controllers in sync, like your typing flow
      searchController.setSearchQuery(text);
      homeController.performSearch(text);
    }

    return TextFormField(
      controller: searchBarText,
      onFieldSubmitted: (value) {
        searchController.setSearchQuery(value.trim());
        homeController.performSearch(value);
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        filled: true,
        fillColor: AppColors.homeSearchBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: const BorderSide(color: AppColors.top5Transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: const BorderSide(color: AppColors.top5Transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: const BorderSide(color: AppColors.top5Transparent),
        ),
        hintText: searchBarText.text,
        hintStyle: h4.copyWith(color: AppColors.homeGray, fontSize: 14.sp),
        prefixIcon: Image.asset('assets/images/home/search.png', scale: 4),

        // ↓ Only this part changed: we call _handleVoice()
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          spacing: 8.w,
          children: [
            GestureDetector(
              onTap: _handleVoice,
              child: Image.asset('assets/images/home/voice.png', scale: 4),
            ),
            Container(width: 1.w, height: 20.h, color: AppColors.homeSearchBarLineColor),
            Image.asset('assets/images/home/filter.png', scale: 4),
            Text('Filter'.tr, style: h4.copyWith(color: AppColors.homeGray, fontSize: 12.sp)),
            SizedBox(width: 20.w),
          ],
        ),
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



class CategorySelectionCardSearch extends StatelessWidget {
  final String text;
  final String icon;
  final RxList<RxBool> selectedCategory;
  final int index;
  final Color color;
  final Color textColor;

  const CategorySelectionCardSearch({
    required this.text,
    required this.icon,
    required this.selectedCategory,
    required this.index,
    required this.color,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Hellow");
        // 🔁 Switch from HomeController to SearchController
        Get.find<SearchController>().selectCategory(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          spacing: 4.w,
          children: [
            Text(
              text,
              style: h3.copyWith(color: textColor, fontSize: 12.sp),
            ),
            SvgPicture.asset(icon, color: textColor),
          ],
        ),
      ),
    );
  }
}



class SearchListCard extends StatelessWidget {
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
  final String placeId; // NEW
  final double destLat; // NEW
  final double destLng; // NEW

  const SearchListCard({
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
    required this.placeId, // NEW
    required this.destLat, // NEW
    required this.destLng, // NEW
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          SearchDetailsView(
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
            SizedBox(height: 16.h),
            Row(
              spacing: 18.w,
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
                    onTap: _openDirections, // Updated
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
    );
  }
}
