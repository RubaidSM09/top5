import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/home/controllers/home_controller.dart';
import 'package:top5/app/modules/profile/views/change_password_view.dart';
import 'package:top5/app/modules/profile/views/delete_account_view.dart';
import 'package:top5/app/modules/profile/views/edit_personal_info_view.dart';
import 'package:top5/app/modules/profile/views/help_n_support_view.dart';
import 'package:top5/app/modules/profile/views/log_out_view.dart';
import 'package:top5/app/modules/profile/views/personal_info_view.dart';
import 'package:top5/app/modules/profile/views/privacy_policy_view.dart';
import 'package:top5/app/modules/profile/views/recent_list_view.dart';
import 'package:top5/app/modules/profile/views/report_a_place_view.dart';
import 'package:top5/app/modules/profile/views/reservation_list_view.dart';
import 'package:top5/app/modules/profile/views/saved_list_view.dart';
import 'package:top5/app/modules/profile/views/send_feedback_view.dart';
import 'package:top5/app/modules/profile/views/terms_of_services_view.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';
import 'package:top5/common/widgets/custom_button.dart';

import '../../../../common/localization/localization_controller.dart';
import '../../search/controllers/search_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.put(ProfileController());
    HomeController homeController = Get.put(HomeController());
    SearchController searchController = Get.put(SearchController());
    final LocalizationController localizationController = Get.find<LocalizationController>();

    // Fetch the recent count once when the screen first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Avoid duplicate concurrent calls
      if (!homeController.recentCountLoading.value) {
        homeController.fetchRecentCount();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 16.w,
                      children: [
                        CircleAvatar(
                          radius: 32.r,
                          backgroundImage: profileController.image.value == '' ?
                          const AssetImage(
                            'assets/images/home/profile_pic.jpg',
                          )
                              :
                          NetworkImage(
                            'http://10.10.13.99:8090${profileController.image.value}',
                          ) as ImageProvider,
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12.h,
                          children: [
                            Text(
                              profileController.fullName.value,
                              style: h1.copyWith(
                                color: AppColors.profileBlack,
                                fontSize: 22.sp,
                              ),
                            ),

                            Text(
                              profileController.email.value,
                              style: h4.copyWith(
                                color: AppColors.profileTextLight,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    CustomButton(
                      text: 'Edit Profile'.tr,
                      paddingLeft: 12,
                      paddingRight: 12,
                      paddingTop: 8,
                      paddingBottom: 8,
                      color: AppColors.top5Transparent,
                      borderColor: AppColors.profileGray,
                      textColor: AppColors.profileGray,
                      textSize: 12,
                      borderRadius: 6,
                      onTap: () => Get.to(EditPersonalInfoView()),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                Row(
                  spacing: 24.w,
                  children: [
                    Expanded(
                      child: Obx(() {
                        final count = homeController.savedCount.value;
                        final loading = homeController.savedCountLoading.value;
                        final label = localizationController.selectedLanguage.value == 'English' ? loading ? 'Saved …' : 'Saved $count' : loading ? 'économiser …' : 'économiser $count';
                        return CustomButton(
                          text: label,
                          // left as-is unless you also have an API for saved count
                          icon: 'assets/images/profile/saved.svg',
                          paddingTop: 6,
                          paddingBottom: 6,
                          color: AppColors.profileSearchBg,
                          borderRadius: 6,
                          textSize: 16,
                          textColor: AppColors.profileGreen,
                          onTap: () {},
                        );
                      }),
                    ),

                    /*Expanded(
                      child: Obx(() {
                        final count = homeController.recentCount.value;
                        final loading = homeController.recentCountLoading.value;
                        final label = localizationController.selectedLanguage.value == 'English' ? loading ? 'Recents …' : 'Recents $count' : loading ? 'Récents …' : 'Récents $count';
                        return CustomButton(
                          text: label,
                          icon: 'assets/images/profile/recents.svg',
                          paddingTop: 6,
                          paddingBottom: 6,
                          color: AppColors.profileSearchBg,
                          borderRadius: 6,
                          textSize: 16,
                          textColor: AppColors.profileGreen,
                          onTap: () {},
                        );
                      }),
                    ),*/
                  ],
                ),

                SizedBox(height: 24.h),

                Text(
                  'Quick Actions'.tr,
                  style: h2.copyWith(
                    color: AppColors.profileBlack,
                    fontSize: 24.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                Row(
                  spacing: 31.w,
                  children: [
                    Expanded(
                      child: ProfileQuickActionButton(
                        text: 'Saved'.tr,
                        icon: 'assets/images/profile/saved.svg',
                        onTap: () => Get.to(const SavedListView()),
                      ),
                    ),

                    /*ProfileQuickActionButton(
                      text: 'Recents'.tr,
                      icon: 'assets/images/profile/recents.svg',
                      onTap: () => Get.to(const RecentListView()),
                    ),

                    ProfileQuickActionButton(
                      text: 'Reservations'.tr,
                      icon: 'assets/images/profile/reservations.svg',
                      onTap: () => Get.to(const ReservationListView()),
                    ),*/
                  ],
                ),

                SizedBox(height: 24.h),

                Text(
                  'Account'.tr,
                  style: h2.copyWith(
                    color: AppColors.profileBlack,
                    fontSize: 24.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                Row(
                  spacing: 24.w,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Personal Info'.tr,
                        icon: 'assets/images/profile/personal_info.svg',
                        paddingTop: 6,
                        paddingBottom: 6,
                        color: AppColors.top5Transparent,
                        borderColor: AppColors.profileGray,
                        textColor: AppColors.profileBlack,
                        textSize: 14,
                        borderRadius: 6,
                        mainAxisAlignment: MainAxisAlignment.start,
                        onTap: () => Get.to(PersonalInfoView(profileController: profileController,)),
                      ),
                    ),

                    Expanded(
                      child: CustomButton(
                        text: 'Change password'.tr,
                        paddingTop: 6,
                        paddingBottom: 6,
                        icon: 'assets/images/profile/change_password.svg',
                        color: AppColors.top5Transparent,
                        borderColor: AppColors.profileGray,
                        textColor: AppColors.profileBlack,
                        textSize: 14,
                        borderRadius: 6,
                        onTap: () => Get.to(ChangePasswordView()),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: AppColors.profileGray,
                      width: 0.75.r,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 6.w,
                        children: [
                          SvgPicture.asset(
                            'assets/images/profile/connected_accounts.svg',
                          ),

                          Text(
                            'Connected accounts'.tr,
                            style: h2.copyWith(
                              color: AppColors.profileBlack,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        spacing: 16.w,
                        children: [
                          SvgPicture.asset(
                            'assets/images/profile/apple_id.svg',
                          ),

                          Text(
                            'Apple Id'.tr,
                            style: h2.copyWith(
                              color: AppColors.profileBlack,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                Text(
                  'Preferences'.tr,
                  style: h2.copyWith(
                    color: AppColors.profileBlack,
                    fontSize: 24.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: AppColors.profileBorderColor,
                      width: 0.75.r,
                    ),
                  ),
                  child: Column(
                    spacing: 8.h,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.profileBorderColor,
                              width: 0.75.r,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              spacing: 6.w,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/profile/default_filters.svg',
                                ),

                                Text(
                                  'Default filters'.tr,
                                  style: h4.copyWith(
                                    color: AppColors.profileBlack,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),

                            Obx(() {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 15.w,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      profileController.selectedDefaultFilters[0].value = true;
                                      profileController.selectedDefaultFilters[1].value = false;
                                      profileController.selectedDefaultFilters[2].value = false;
                                      homeController.selectedFilter[0].value = true;
                                      homeController.selectedFilter[1].value = false;
                                      homeController.selectedFilter[2].value = false;
                                      homeController.selectedFilter[3].value = false;
                                      homeController.selectedFilter[4].value = false;
                                      searchController.selectedFilter[0].value = true;
                                      searchController.selectedFilter[1].value = false;
                                      searchController.selectedFilter[2].value = false;
                                      searchController.selectedFilter[3].value = false;
                                      searchController.selectedFilter[4].value = false;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: profileController.selectedDefaultFilters[0].value
                                            ? AppColors.profileGreen
                                            : AppColors.profileInactiveBg,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Open Now'.tr,
                                          style: h4.copyWith(
                                            color: profileController.selectedDefaultFilters[0].value
                                                ? AppColors.profileWhite
                                                : AppColors.profileGray,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      profileController.selectedDefaultFilters[0].value = false;
                                      profileController.selectedDefaultFilters[1].value = true;
                                      profileController.selectedDefaultFilters[2].value = false;
                                      homeController.selectedFilter[0].value = false;
                                      homeController.selectedFilter[1].value = false;
                                      homeController.selectedFilter[2].value = true;
                                      homeController.selectedFilter[3].value = false;
                                      homeController.selectedFilter[4].value = false;
                                      searchController.selectedFilter[0].value = false;
                                      searchController.selectedFilter[1].value = false;
                                      searchController.selectedFilter[2].value = true;
                                      searchController.selectedFilter[3].value = false;
                                      searchController.selectedFilter[4].value = false;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: profileController.selectedDefaultFilters[1].value
                                            ? AppColors.profileGreen
                                            : AppColors.profileInactiveBg,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '1 Km',
                                          style: h4.copyWith(
                                            color: profileController.selectedDefaultFilters[1].value
                                                ? AppColors.profileWhite
                                                : AppColors.profileGray,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      profileController.selectedDefaultFilters[0].value = false;
                                      profileController.selectedDefaultFilters[1].value = false;
                                      profileController.selectedDefaultFilters[2].value = true;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: profileController.selectedDefaultFilters[2].value
                                            ? AppColors.profileGreen
                                            : AppColors.profileInactiveBg,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '\$\$',
                                          style: h4.copyWith(
                                            color: profileController.selectedDefaultFilters[2].value
                                                ? AppColors.profileWhite
                                                : AppColors.profileGray,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.profileBorderColor,
                              width: 0.75.r,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              spacing: 6.w,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/profile/dietary.svg',
                                ),

                                Text(
                                  'Dietary'.tr,
                                  style: h4.copyWith(
                                    color: AppColors.profileBlack,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),

                            Obx(() {
                              return Row(
                                spacing: 7.w,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      profileController.selectedDietary[0]
                                          .value = true;
                                      profileController.selectedDietary[1]
                                          .value = false;
                                      profileController.selectedDietary[2]
                                          .value = false;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: profileController
                                            .selectedDietary[0].value
                                            ? AppColors.profileGreen
                                            : AppColors.profileInactiveBg,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Not-Vegan'.tr,
                                          style: h4.copyWith(
                                            color: profileController
                                                .selectedDietary[0].value
                                                ? AppColors.profileWhite
                                                : AppColors.profileGray,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      profileController.selectedDietary[0]
                                          .value = false;
                                      profileController.selectedDietary[1]
                                          .value = true;
                                      profileController.selectedDietary[2]
                                          .value = false;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: profileController
                                            .selectedDietary[1].value
                                            ? AppColors.profileGreen
                                            : AppColors.profileInactiveBg,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Vegan'.tr,
                                          style: h4.copyWith(
                                            color: profileController
                                                .selectedDietary[1].value
                                                ? AppColors.profileWhite
                                                : AppColors.profileGray,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      profileController.selectedDietary[0]
                                          .value = false;
                                      profileController.selectedDietary[1]
                                          .value = false;
                                      profileController.selectedDietary[2]
                                          .value = true;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: profileController
                                            .selectedDietary[2].value
                                            ? AppColors.profileGreen
                                            : AppColors.profileInactiveBg,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Gluten-free'.tr,
                                          style: h4.copyWith(
                                            color: profileController
                                                .selectedDietary[2].value
                                                ? AppColors.profileWhite
                                                : AppColors.profileGray,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.profileBorderColor,
                              width: 0.75.r,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              spacing: 6.w,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/profile/distance_unit.svg',
                                ),

                                Text(
                                  'Distance Unit'.tr,
                                  style: h4.copyWith(
                                    color: AppColors.profileBlack,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),

                            Obx(() {
                              return Row(
                                spacing: 8.w,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      profileController.selectedDistanceUnit[0].value = true;
                                      profileController.selectedDistanceUnit[1].value = false;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.5.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: profileController.selectedDistanceUnit[0].value ? AppColors.profileGreen : AppColors.profileInactiveBg,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'km',
                                          style: h4.copyWith(
                                            color: profileController.selectedDistanceUnit[0].value ? AppColors.profileWhite : AppColors.profileGray,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      profileController.selectedDistanceUnit[0].value = false;
                                      profileController.selectedDistanceUnit[1].value = true;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 7.5.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: profileController.selectedDistanceUnit[1].value ? AppColors.profileGreen : AppColors.profileInactiveBg,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'miles',
                                          style: h4.copyWith(
                                            color: profileController.selectedDistanceUnit[1].value ? AppColors.profileWhite : AppColors.profileGray,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 6.w,
                            children: [
                              SvgPicture.asset(
                                'assets/images/profile/language.svg',
                              ),

                              Text(
                                'Language'.tr,
                                style: h4.copyWith(
                                  color: AppColors.profileBlack,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),

                          Obx(() {
                            return Row(
                              spacing: 8.w,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    localizationController.changeLanguage(
                                        'English');
                                    print('Language changed to: English');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18.48.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: localizationController
                                          .selectedLanguage.value == 'English'
                                          ? AppColors.profileGreen
                                          : AppColors.profileWhite,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'English',
                                        style: h4.copyWith(
                                          color: localizationController
                                              .selectedLanguage.value ==
                                              'English'
                                              ? AppColors.profileWhite
                                              : AppColors.profileGray,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    localizationController.changeLanguage(
                                        'French');
                                    print('Language changed to: French');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18.48.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: localizationController
                                          .selectedLanguage.value == 'French'
                                          ? AppColors.profileGreen
                                          : AppColors.profileWhite,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'French',
                                        style: h4.copyWith(
                                          color: localizationController
                                              .selectedLanguage.value ==
                                              'French'
                                              ? AppColors.profileWhite
                                              : AppColors.profileGray,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h,),

                Text(
                  'Privacy & Security'.tr,
                  style: h2.copyWith(
                    color: AppColors.profileBlack,
                    fontSize: 24.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                Row(
                  spacing: 19.91.w,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Location permission'.tr,
                        icon: 'assets/images/profile/location_permission.svg',
                        paddingTop: 6,
                        paddingBottom: 6,
                        color: AppColors.top5Transparent,
                        borderColor: AppColors.profileGray,
                        textColor: AppColors.profileBlack,
                        textSize: 14,
                        borderRadius: 6,
                        spaceBetweenIconText: 6,
                        onTap: () {  },
                      ),
                    ),

                    Expanded(
                      child: CustomButton(
                        text: 'Download my data'.tr,
                        icon: 'assets/images/profile/download_my_data.svg',
                        paddingTop: 6,
                        paddingBottom: 6,
                        color: AppColors.top5Transparent,
                        borderColor: AppColors.profileGray,
                        textColor: AppColors.profileBlack,
                        textSize: 14,
                        borderRadius: 6,
                        spaceBetweenIconText: 6,
                        onTap: () {  },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                CustomButton(
                  text: 'Delete my account'.tr,
                  icon: 'assets/images/profile/delete_my_account.svg',
                  borderRadius: 6,
                  paddingTop: 10,
                  paddingBottom: 10,
                  color: AppColors.profileDeleteButtonColor,
                  textColor: AppColors.profileDeleteButtonTextColor,
                  onTap: () => Get.dialog(const DeleteAccountView()),
                ),

                SizedBox(height: 24.h),

                Text(
                  'Help & Legal'.tr,
                  style: h2.copyWith(
                    color: AppColors.profileBlack,
                    fontSize: 24.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                CustomButton(
                  text: 'Help & Support'.tr,
                  prefixIcon: 'assets/images/profile/arrow_next.svg',
                  paddingTop: 6,
                  paddingBottom: 6,
                  borderRadius: 6,
                  color: AppColors.top5Transparent,
                  borderColor: AppColors.profileGray,
                  textColor: AppColors.profileBlack,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  onTap: () => Get.to(HelpNSupportView()),
                ),

                SizedBox(height: 16.h),

                CustomButton(
                  text: 'Report a place'.tr,
                  prefixIcon: 'assets/images/profile/arrow_next.svg',
                  paddingTop: 6,
                  paddingBottom: 6,
                  borderRadius: 6,
                  color: AppColors.top5Transparent,
                  borderColor: AppColors.profileGray,
                  textColor: AppColors.profileBlack,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  onTap: () => Get.to(ReportAPlaceView()),
                ),

                SizedBox(height: 16.h),

                CustomButton(
                  text: 'Send feedback'.tr,
                  prefixIcon: 'assets/images/profile/arrow_next.svg',
                  paddingTop: 6,
                  paddingBottom: 6,
                  borderRadius: 6,
                  color: AppColors.top5Transparent,
                  borderColor: AppColors.profileGray,
                  textColor: AppColors.profileBlack,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  onTap: () => Get.to(SendFeedbackView()),
                ),

                SizedBox(height: 16.h),

                CustomButton(
                  text: 'Terms of Service'.tr,
                  prefixIcon: 'assets/images/profile/arrow_next.svg',
                  paddingTop: 6,
                  paddingBottom: 6,
                  borderRadius: 6,
                  color: AppColors.top5Transparent,
                  borderColor: AppColors.profileGray,
                  textColor: AppColors.profileBlack,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  onTap: () => Get.to(const TermsOfServicesView()),
                ),

                SizedBox(height: 16.h),

                CustomButton(
                  text: 'Privacy Policy'.tr,
                  prefixIcon: 'assets/images/profile/arrow_next.svg',
                  paddingTop: 6,
                  paddingBottom: 6,
                  borderRadius: 6,
                  color: AppColors.top5Transparent,
                  borderColor: AppColors.profileGray,
                  textColor: AppColors.profileBlack,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  onTap: () => Get.to(const PrivacyPolicyView()),
                ),

                SizedBox(height: 24.h),

                CustomButton(
                  text: 'Log out'.tr,
                  icon: 'assets/images/profile/log_out.svg',
                  paddingTop: 6,
                  paddingBottom: 6,
                  borderRadius: 6,
                  color: AppColors.top5Transparent,
                  borderColor: AppColors.profileGray,
                  textColor: AppColors.profileDeleteButtonTextColor,
                  onTap: () => Get.dialog(const LogOutView()),
                ),

                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileQuickActionButton extends StatelessWidget {
  final String text;
  final String icon;
  final void Function()? onTap;

  const ProfileQuickActionButton({
    required this.text,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.profileGray, width: 0.75.r),
        ),
        child: Column(
          spacing: 8.h,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.profileSearchBg,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(icon),
            ),

            Text(
              text,
              style: h1.copyWith(
                color: AppColors.profileBlack,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
