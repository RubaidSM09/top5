import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:top5/common/app_colors.dart';

import '../../app/modules/dashboard/controllers/dashboard_controller.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    final List<Map<String, String>> navItems = [
      {
        'label': 'Explore'.tr,
        'filledIcon': 'assets/images/bottom_navigation_bar/explore_active.svg',
        'defaultIcon': 'assets/images/bottom_navigation_bar/explore.svg',
      },
      {
        'label': 'Search'.tr,
        'filledIcon': 'assets/images/bottom_navigation_bar/search_active.svg',
        'defaultIcon': 'assets/images/bottom_navigation_bar/search.svg',
      },
      {
        'label': 'Profile'.tr,
        'filledIcon': 'assets/images/bottom_navigation_bar/profile_active.svg',
        'defaultIcon': 'assets/images/bottom_navigation_bar/profile.svg',
      },
    ];

    return Container(
      height: 79.h, // Set the desired height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.homeBlack.withAlpha(38),
            blurRadius: 5.r,
            offset: Offset(1.w, 1.h),
          )
        ]
      ),
      padding: EdgeInsets.all(13.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          return GestureDetector(
            onTap: () => controller.updateIndex(index),
            child: Obx(() {
              final isSelected = index == controller.currentIndex.value;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200), // Smooth transition duration
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Column(
                  children: [
                    SvgPicture.asset(
                      isSelected ? item['filledIcon']! : item['defaultIcon']!,
                      key: ValueKey('${item['label']}_$isSelected'),
                    ),

                    SizedBox(height: 10.h,),

                    Text(
                      item['label']!,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                          color: isSelected ? AppColors.homeBottomNavbarTextColor : AppColors.homeText
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
