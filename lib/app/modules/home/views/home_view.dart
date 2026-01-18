import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/home/views/service_view.dart';
import 'package:top5/app/modules/home/views/set_your_location_view.dart';
import 'package:top5/app/modules/profile/controllers/profile_controller.dart';
import 'package:top5/app/modules/profile/views/profile_view.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';

import '../../../../common/voice/voice_service.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.homeBgColorGradient,
        automaticallyImplyLeading: false,
        title: Obx(() => HomeAppBar(time: controller.formatted, profileController: profileController,)),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.homeBgColorGradient,
                AppColors.homeWhite,
                AppColors.homeBgColorGradient,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.62.h,),

                  // TOP CATEGORY CHIPS (unchanged)
                  Obx(() {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 10.w,
                        children: [
                          CategorySelectionCard(
                            text: 'Restaurant'.tr,
                            icon: 'assets/images/home/restaurant.svg',
                            selectedCategory: controller.selectedCategory,
                            index: 0,
                            color: controller.selectedCategory[0].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                            textColor: controller.selectedCategory[0].value ? AppColors.homeWhite : AppColors.homeGray,
                            page: 'Home',
                          ),

                          CategorySelectionCard(
                            text: 'Cafes'.tr,
                            icon: 'assets/images/home/coffee_x5F_cup.svg',
                            selectedCategory: controller.selectedCategory,
                            index: 1,
                            color: controller.selectedCategory[1].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                            textColor: controller.selectedCategory[1].value ? AppColors.homeWhite : AppColors.homeGray,
                            page: 'Home',
                          ),

                          CategorySelectionCard(
                            text: 'Bars'.tr,
                            icon: 'assets/images/home/bars.svg',
                            selectedCategory: controller.selectedCategory,
                            index: 2,
                            color: controller.selectedCategory[2].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                            textColor: controller.selectedCategory[2].value ? AppColors.homeWhite : AppColors.homeGray,
                            page: 'Home',
                          ),

                          CategorySelectionCard(
                            text: 'Activities'.tr,
                            icon: 'assets/images/home/activities.svg',
                            selectedCategory: controller.selectedCategory,
                            index: 3,
                            color: controller.selectedCategory[3].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                            textColor: controller.selectedCategory[3].value ? AppColors.homeWhite : AppColors.homeGray,
                            page: 'Home',
                          ),

                          CategorySelectionCard(
                            text: 'Services'.tr,
                            icon: 'assets/images/home/services.svg',
                            selectedCategory: controller.selectedCategory,
                            index: 4,
                            color: controller.selectedCategory[4].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                            textColor: controller.selectedCategory[4].value ? AppColors.homeWhite : AppColors.homeGray,
                            page: 'Home',
                          ),

                          CategorySelectionCard(
                            text: 'Super-shops'.tr,
                            icon: 'assets/images/home/services.svg',
                            selectedCategory: controller.selectedCategory,
                            index: 5,
                            color: controller.selectedCategory[5].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                            textColor: controller.selectedCategory[5].value ? AppColors.homeWhite : AppColors.homeGray,
                            page: 'Home',
                          ),
                        ],
                      ),
                    );
                  }),

                  // HEADER DROPDOWN FOR ACTIVITIES/SERVICES (unchanged behaviour)
                  Obx(() {
                    final c = Get.find<HomeController>();
                    final bool showActivities =
                        c.showActivitiesDropdown.value && c.selectedCategory[3].value;
                    final bool showServices =
                        c.showServicesDropdown.value && c.selectedCategory[4].value;
                    final bool showSuperShops =
                        c.showSuperShopsDropdown.value && c.selectedCategory[5].value;

                    if (!showActivities && !showServices && !showSuperShops) {
                      return const SizedBox.shrink();
                    }

                    final bool isActivities = showActivities;
                    final bool isServices = showServices;
                    final List<CategoryNode> parents = isActivities
                        ? c.activitiesCategories
                        : isServices
                        ? c.servicesCategories
                        : c.superShopsCategories;

                    final CategoryNode? selectedParent = isActivities
                        ? c.selectedActivitiesParent.value
                        : isServices
                        ? c.selectedServicesParent.value
                        : c.selectedSuperShopsParent.value;

                    final CategoryNode? selectedChild = isActivities
                        ? c.selectedActivitiesChild.value
                        : isServices
                        ? c.selectedServicesChild.value
                        : c.selectedSuperShopsChild.value;

                    final Color bgColor = isActivities
                        ? (c.selectedCategory[3].value
                        ? AppColors.homeGreen
                        : AppColors.homeInactiveBg)
                        : isServices
                        ? (c.selectedCategory[4].value
                        ? AppColors.homeGreen
                        : AppColors.homeInactiveBg)
                        : (c.selectedCategory[5].value
                        ? AppColors.homeGreen
                        : AppColors.homeInactiveBg);

                    final Color chipBgActive   = AppColors.homeWhite;
                    final Color chipBgInactive = bgColor.withOpacity(0.85);
                    final Color chipTextActive   = AppColors.homeGreen;
                    final Color chipTextInactive = AppColors.homeWhite;

                    return Container(
                      margin: EdgeInsets.only(top: 12.h),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
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
                              final bool isSelected =
                                  selectedParent?.id == node.id;
                              return GestureDetector(
                                onTap: () {
                                  if (isActivities) {
                                    c.selectActivitiesParent(node);
                                  } else if (isServices) {
                                    c.selectServicesParent(node);
                                  } else {
                                    c.selectSuperShopsParent(node);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? chipBgActive
                                        : chipBgInactive,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    node.label.tr,
                                    style: h4.copyWith(
                                      color: isSelected
                                          ? chipTextActive
                                          : chipTextInactive,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          if (selectedParent != null &&
                              selectedParent.children.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            Divider(color: chipBgActive,),
                            SizedBox(height: 6.h),

                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: selectedParent.children.map((node) {
                                final bool isSelectedChild =
                                    selectedChild?.id == node.id;
                                return GestureDetector(
                                  onTap: () {
                                    if (isActivities) {
                                      // header → allow ideas
                                      c.selectActivitiesChild(node, refreshIdeasFlag: true);
                                    } else if (isServices) {
                                      c.selectServicesChild(node, refreshIdeasFlag: true);
                                    } else {
                                      c.selectSuperShopsChild(node, refreshIdeasFlag: true);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelectedChild
                                          ? chipBgActive
                                          : chipBgInactive,
                                      borderRadius:
                                      BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      node.label.tr,
                                      style: h4.copyWith(
                                        color: isSelectedChild
                                            ? chipTextActive
                                            : chipTextInactive,
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

                  SizedBox(height: 24.h,),

                  HomeSearchBar(),

                  SizedBox(height: 16.38.h,),

                  Obx(() {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: IntrinsicHeight(
                        child: Row(
                          spacing: 10.w,
                          children: [
                            FilterSelectionCard(
                              text: 'Open now'.tr,
                              selectedFilter: controller.selectedFilter,
                              index: 0,
                              color: controller.selectedFilter[0].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                              textColor: controller.selectedFilter[0].value ? AppColors.homeWhite : AppColors.homeGray,
                              page: 'Home',
                            ),

                            FilterSelectionCard(
                              text: '10 min',
                              selectedFilter: controller.selectedFilter,
                              index: 1,
                              color: controller.selectedFilter[1].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                              textColor: controller.selectedFilter[1].value ? AppColors.homeWhite : AppColors.homeGray,
                              page: 'Home',
                            ),

                            // ✅ NEW: 5 min (after 10 min)
                            FilterSelectionCard(
                              text: '5 min',
                              selectedFilter: controller.selectedFilter,
                              index: 2,
                              color: controller.selectedFilter[2].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                              textColor: controller.selectedFilter[2].value ? AppColors.homeWhite : AppColors.homeGray,
                              page: 'Home',
                            ),

                            FilterSelectionCard(
                              text: profileController.selectedDistanceUnit[0].value
                                  ? '1 km'
                                  : "${controller.convertToMiles('1 km').toStringAsFixed(2)} miles",
                              selectedFilter: controller.selectedFilter,
                              index: 3,
                              color: controller.selectedFilter[3].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                              textColor: controller.selectedFilter[3].value ? AppColors.homeWhite : AppColors.homeGray,
                              page: 'Home',
                            ),

                            // ✅ NEW: 0.5 km (after 1 km)
                            FilterSelectionCard(
                              text: profileController.selectedDistanceUnit[0].value
                                  ? '0.5 km'
                                  : "${controller.convertToMiles('0.5 km').toStringAsFixed(2)} miles",
                              selectedFilter: controller.selectedFilter,
                              index: 4,
                              color: controller.selectedFilter[4].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                              textColor: controller.selectedFilter[4].value ? AppColors.homeWhite : AppColors.homeGray,
                              page: 'Home',
                            ),

                            FilterSelectionCard(
                              text: 'Outdoor'.tr,
                              selectedFilter: controller.selectedFilter,
                              index: 5,
                              color: controller.selectedFilter[5].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                              textColor: controller.selectedFilter[5].value ? AppColors.homeWhite : AppColors.homeGray,
                              page: 'Home',
                            ),

                            FilterSelectionCard(
                              text: 'Vegetarian'.tr,
                              selectedFilter: controller.selectedFilter,
                              index: 6,
                              color: controller.selectedFilter[6].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                              textColor: controller.selectedFilter[6].value ? AppColors.homeWhite : AppColors.homeGray,
                              page: 'Home',
                            ),
                            /*FilterSelectionCard(
                              text: 'Bookable'.tr,
                              selectedFilter: controller.selectedFilter,
                              index: 5,
                              color: controller.selectedFilter[5].value ? AppColors.homeGreen : AppColors.homeInactiveBg,
                              textColor: controller.selectedFilter[5].value ? AppColors.homeWhite : AppColors.homeGray,
                              page: 'Home',
                            ),*/
                          ],
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: 30.h,),

                  Text(
                    'Quick Glance (5-in-5)'.tr,
                    style: h2.copyWith(
                      color: AppColors.homeBlack,
                      fontSize: 24.sp,
                    ),
                  ),

                  SizedBox(height: 20.h,),

                  // MAIN QUICK GLANCE CARDS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16.w,
                      children: [
                        QuickGlanceCard(
                          image: 'assets/images/home/restaurant.jpg',
                          text: 'Restaurant'.tr,
                          rating: 4.6,
                          selectedCategory: controller.selectedCategory,
                          index: 0,
                        ),
                        QuickGlanceCard(
                          image: 'assets/images/home/cafes.jpg',
                          text: 'Cafes'.tr,
                          rating: 4.6,
                          selectedCategory: controller.selectedCategory,
                          index: 1,
                        ),
                        QuickGlanceCard(
                          image: 'assets/images/home/bar.jpg',
                          text: 'Bar'.tr,
                          rating: 4.6,
                          selectedCategory: controller.selectedCategory,
                          index: 2,
                        ),
                        QuickGlanceCard(
                          image: 'assets/images/home/services.jpg',
                          text: 'Services'.tr,
                          rating: 4.6,
                          selectedCategory: controller.selectedCategory,
                          index: 4,
                        ),
                        QuickGlanceCard(
                          image: 'assets/images/home/activities.jpg',
                          text: 'Activities'.tr,
                          rating: 4.6,
                          selectedCategory: controller.selectedCategory,
                          index: 3,
                        ),
                        QuickGlanceCard(
                          image: 'assets/images/home/super_shops.jpg',
                          text: 'Super-shops'.tr,
                          rating: 4.6,
                          selectedCategory: controller.selectedCategory,
                          index: 5,
                        ),
                      ],
                    ),
                  ),

                  // QUICK GLANCE SUBCATEGORIES (Activities / Services)
                  Obx(() {
                    final c = Get.find<HomeController>();
                    final bool showActivities = c.showActivitiesQuickGlance.value;
                    final bool showServices   = c.showServicesQuickGlance.value;
                    final bool showSuperShops   = c.showSuperShopsQuickGlance.value;

                    if (!showActivities && !showServices && !showSuperShops) {
                      return const SizedBox.shrink();
                    }

                    final bool isActivities = showActivities;
                    final bool isServices = showServices;
                    final List<CategoryNode> parents = isActivities
                        ? c.activitiesCategories
                        : isServices
                        ? c.servicesCategories
                        : c.superShopsCategories;

                    final CategoryNode? selectedParent = isActivities
                        ? c.selectedActivitiesParent.value
                        : isServices
                        ? c.selectedServicesParent.value
                        : c.selectedSuperShopsParent.value;

                    final CategoryNode? selectedChild = isActivities
                        ? c.selectedActivitiesChild.value
                        : isServices
                        ? c.selectedServicesChild.value
                        : c.selectedSuperShopsChild.value;

                    final String bgImage = isActivities
                        ? 'assets/images/home/activities.jpg'
                        : isServices
                        ? 'assets/images/home/services.jpg'
                        : 'assets/images/home/super_shops.jpg';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),

                        // Parent sub-categories as Quick Glance style
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 16.w,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: parents.map((node) {
                              final bool isSelected = selectedParent?.id == node.id;
                              return QuickGlanceCategoryCard(
                                image: bgImage,
                                text: node.label.tr,
                                rating: 4.6,
                                isSelected: isSelected,
                                onTap: () {
                                  if (isActivities) {
                                    c.selectActivitiesParent(node);
                                  } else if (isServices) {
                                    c.selectServicesParent(node);
                                  } else {
                                    c.selectSuperShopsParent(node);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        // Child sub-sub-categories
                        if (selectedParent != null &&
                            selectedParent.children.isNotEmpty) ...[
                          SizedBox(height: 16.h),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 16.w,
                              children: selectedParent.children.map((node) {
                                final bool isSelectedChild = selectedChild?.id == node.id;
                                return QuickGlanceCategoryCard(
                                  image: bgImage,
                                  text: node.label.tr,
                                  rating: 4.6,
                                  isSelected: isSelectedChild,
                                  onTap: () {
                                    final c = Get.find<HomeController>();
                                    if (isActivities) {
                                      // Quick Glance → do NOT trigger ideas
                                      c.selectActivitiesChild(node, refreshIdeasFlag: false);
                                      // mark that ServiceView was opened from Quick Glance
                                      c.navigatedFromQuickGlance.value = true;
                                      c.onCategoryChangedService(3);
                                    } else if (isServices) {
                                      c.selectServicesChild(node, refreshIdeasFlag: false);
                                      c.navigatedFromQuickGlance.value = true;
                                      c.onCategoryChangedService(4);
                                    } else {
                                      c.selectSuperShopsChild(node, refreshIdeasFlag: false);
                                      c.navigatedFromQuickGlance.value = true;
                                      c.onCategoryChangedService(5);
                                    }
                                    Get.to(ServiceView(appBarTitle: node.label.tr));
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),

                  SizedBox(height: 30.h,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ideas to Try'.tr,
                        style: h2.copyWith(
                          color: AppColors.homeBlack,
                          fontSize: 24.sp,
                        ),
                      ),

                      Row(
                        spacing: 6.w,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.homeInactiveBg,
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                            child: Obx(() => Text(
                              controller.formatted.value,
                              style: h4.copyWith(
                                color: AppColors.homeGreen,
                                fontSize: 12.sp,
                              ),
                            )),
                          ),

                          Obx(() => Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(color: AppColors.homeInactiveBg, borderRadius: BorderRadius.circular(50.r)),
                            child: Row(
                              spacing: 4.w,
                              children: [
                                Icon(
                                  Get.find<HomeController>().weatherIcon,
                                  color: Get.find<HomeController>().weatherIconColor,
                                  size: 15,
                                ),
                                Text(
                                  Get.find<HomeController>().tempText,
                                  style: h4.copyWith(color: AppColors.homeGreen, fontSize: 12.sp),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h,),

                  Obx(() {
                    final c = Get.find<HomeController>();
                    if (c.ideasLoading.value) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          children: [
                            const CircularProgressIndicator(strokeWidth: 2),
                            SizedBox(width: 8.w),
                            Text('Finding ideas...', style: h4.copyWith(color: AppColors.homeGray))
                          ],
                        ),
                      );
                    }

                    if (c.ideas.isEmpty) {
                      return Text(
                        'No ideas yet. Try changing category or wait a moment.',
                        style: h4.copyWith(color: AppColors.homeGray),
                      );
                    }

                    return Wrap(
                      spacing: 10.w,
                      runSpacing: 16.h,
                      children: c.ideas
                          .map((txt) => GestureDetector(
                        onTap: () => c.onIdeaClicked(txt),
                        child: IdeasToTryCard(text: txt),
                      ))
                          .toList(),
                    );
                  }),

                  SizedBox(height: 10.h,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget {
  final RxString time;
  final ProfileController profileController;

  const HomeAppBar({required this.time, required this.profileController, super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset('assets/images/home/top_5_green_logo.svg'),

        Row(
          spacing: 6.w,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.homeInactiveBg,
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Obx(() => Text(
                time.value,
                style: h4.copyWith(color: AppColors.homeGreen, fontSize: 12.sp),
              )),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.homeInactiveBg,
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Obx(() {
                final c = Get.find<HomeController>();
                return Row(
                  spacing: 4.w,
                  children: [
                    Icon(
                      c.weatherIcon,
                      color: c.weatherIconColor,
                      size: 15.r,
                    ),
                    Text(
                      c.tempText,
                      style: h4.copyWith(
                        color: AppColors.homeGreen,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),

        GestureDetector(
          onTap: () => Get.to(ProfileView()),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.homeProfileBorderColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 16.r,
              backgroundImage: profileController.image.value == ''
                  ? const AssetImage(
                'assets/images/home/profile_pic.jpg',
              )
                  : NetworkImage(
                'https://austin-ovisaclike-nonoptically.ngrok-free.dev${profileController.image.value}',
              ) as ImageProvider,
            ),
          ),
        )
      ],
    );
  }
}

class CategorySelectionCard extends StatelessWidget {
  final String text;
  final String icon;
  final RxList<RxBool> selectedCategory;
  final int index;
  final Color color;
  final Color textColor;
  final String page;

  const CategorySelectionCard({
    required this.text,
    required this.icon,
    required this.selectedCategory,
    required this.index,
    required this.color,
    required this.textColor,
    required this.page,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (page == 'Home') {
          final c = Get.find<HomeController>();
          c.onCategoryChangedHome(index);
        } else {
          final c = Get.find<HomeController>();
          c.onCategoryChangedService(index);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          spacing: 4.w,
          children: [
            Text(
              text,
              style: h3.copyWith(
                color: textColor,
                fontSize: 12.sp,
              ),
            ),
            SvgPicture.asset(
              icon,
              color: textColor,
            )
          ],
        ),
      ),
    );
  }
}

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final voice = Get.put(VoiceService());

    Future<void> _handleVoice() async {
      final text = await voice.listenOnce();
      if (text == null || text.trim().isEmpty) {
        Get.snackbar('Voice', 'Didn\'t catch that. Please try again.');
        return;
      }
      homeController.performSearch(text);
    }

    return Obx(() {
      return TextFormField(
        controller: homeController.searchController, // ✅ persistent
        textInputAction: TextInputAction.search,
        onFieldSubmitted: (value) => homeController.performSearch(value),
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

          // ✅ hint shows when controller is empty
          hintText: homeController.searchHint.value,
          hintStyle: h4.copyWith(color: AppColors.homeGray, fontSize: 14.sp),

          prefixIcon: Image.asset('assets/images/home/search.png', scale: 4),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _handleVoice,
                child: Image.asset('assets/images/home/voice.png', scale: 4),
              ),
              SizedBox(width: 8.w),
              Container(width: 1.w, height: 20.h, color: AppColors.homeSearchBarLineColor),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => Get.to(SetYourLocationView()),
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: AppColors.homeWhite,
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/images/home/set_your_location.svg'),
                      SizedBox(width: 2.w),
                      Text(
                        'Change location'.tr,
                        style: h4.copyWith(color: AppColors.homeGray, fontSize: 10.sp),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 20.w),
            ],
          ),
        ),
      );
    });
  }
}

class FilterSelectionCard extends StatelessWidget {
  final String text;
  final RxList<RxBool> selectedFilter;
  final int index;
  final Color color;
  final Color textColor;
  final String page;

  const FilterSelectionCard({
    required this.text,
    required this.selectedFilter,
    required this.index,
    required this.color,
    required this.textColor,
    required this.page,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        selectedFilter[index].value = !selectedFilter[index].value;
        if (page != 'Home') {
          Get.find<HomeController>().fetchTop5Places(
            search: Get.find<HomeController>().searchText.value,
          );
        }
      },
      child: Container(
        width: 90.w,
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: h3.copyWith(
              color: textColor,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class QuickGlanceCard extends StatelessWidget {
  final String image;
  final String text;
  final double rating;
  final RxList<RxBool> selectedCategory;
  final int index;

  const QuickGlanceCard({
    required this.image,
    required this.text,
    required this.rating,
    required this.selectedCategory,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            final c = Get.find<HomeController>();

            // Restaurant / Cafes / Bar → navigate to ServiceView (same as before)
            if (index == 0 || index == 1 || index == 2) {
              c.onCategoryChangedService(index);
              Get.to(ServiceView(appBarTitle: text));
            }
            // Activities from Quick Glance → ONLY show Quick Glance sub-categories
            else if (index == 3) {
              // *** IMPORTANT: do NOT touch top selectedCategory, do NOT call onCategoryChangedHome
              c.showActivitiesQuickGlance.value = true;
              c.showServicesQuickGlance.value   = false;
              c.showSuperShopsQuickGlance.value   = false;
              c.selectedActivitiesParent.value  = null;
              c.selectedActivitiesChild.value   = null;
            }
            // Services from Quick Glance → ONLY show Quick Glance sub-categories
            else if (index == 4) {
              // *** IMPORTANT: do NOT touch top selectedCategory, do NOT call onCategoryChangedHome
              c.showServicesQuickGlance.value   = true;
              c.showActivitiesQuickGlance.value = false;
              c.showSuperShopsQuickGlance.value   = false;
              c.selectedServicesParent.value    = null;
              c.selectedServicesChild.value     = null;
            }

            else if (index == 5) {
              // *** IMPORTANT: do NOT touch top selectedCategory, do NOT call onCategoryChangedHome
              c.showSuperShopsQuickGlance.value = true;
              c.showServicesQuickGlance.value   = false;
              c.showActivitiesQuickGlance.value = false;
              c.selectedSuperShopsParent.value    = null;
              c.selectedSuperShopsChild.value     = null;
            }
          },
          child: Container(
            width: 96.w,
            height: 88.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.top5Black.withAlpha(64),
                  blurRadius: 4.r,
                  offset: Offset(1.w, 1.h),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset(
                image,
                scale: 4,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h,),

        Text(
          text,
          style: h3.copyWith(
            color: AppColors.homeBlack,
            fontSize: 16.sp,
          ),
        ),

        /*SizedBox(height: 4.h,),

        Row(
          spacing: 6.w,
          children: [
            Icon(
              Icons.star,
              color: AppColors.homeGreen,
              size: 12.r,
            ),
            Text(
              '$rating',
              style: h3.copyWith(
                color: AppColors.top5Black,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),*/
      ],
    );
  }
}

// Quick Glance-style card used for sub-categories & sub-sub-categories
class QuickGlanceCategoryCard extends StatelessWidget {
  final String image;
  final String text;
  final double rating;
  final bool isSelected;
  final VoidCallback onTap;

  const QuickGlanceCategoryCard({
    required this.image,
    required this.text,
    required this.rating,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 96.w,
            height: 88.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.top5Black.withAlpha(64),
                  blurRadius: 4.r,
                  offset: Offset(1.w, 1.h),
                )
              ],
              border: isSelected
                  ? Border.all(color: AppColors.homeGreen, width: 2)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset(
                image,
                scale: 4,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h,),

        SizedBox(
          width: 96.w,
          child: Text(
            text,
            style: h3.copyWith(
              color: AppColors.homeBlack,
              fontSize: 16.sp,
            ),
          ),
        ),

        /*SizedBox(height: 4.h,),

        Row(
          spacing: 6.w,
          children: [
            Icon(
              Icons.star,
              color: AppColors.homeGreen,
              size: 12.r,
            ),
            Text(
              '$rating',
              style: h3.copyWith(
                color: AppColors.top5Black,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),*/
      ],
    );
  }
}

class IdeasToTryCard extends StatelessWidget {
  final String text;

  const IdeasToTryCard({
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.homeSearchBg,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Text(
        text,
        style: h3.copyWith(
          color: AppColors.homeGray,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
