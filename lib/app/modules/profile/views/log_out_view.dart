import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/profile/controllers/profile_controller.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';
import 'package:top5/common/widgets/custom_button.dart';

class LogOutView extends GetView {
  const LogOutView({super.key});
  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());

    return Dialog(
      backgroundColor: AppColors.profileWhite,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Log Out'.tr,
              style: h1.copyWith(
                color: AppColors.profileBlack,
                fontSize: 20.sp,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h,),

            Text(
              'Are you sure you want to log out?'.tr,
              style: h4.copyWith(
                color: AppColors.profileDeleteButtonTextColor,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 30.h,),

            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 17.w,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel'.tr,
                      color: AppColors.top5Transparent,
                      borderColor: AppColors.profileGray,
                      textColor: AppColors.profileBlack,
                      borderRadius: 6,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
              
                  Expanded(
                    child: CustomButton(
                      text: 'Log Out'.tr,
                      color: AppColors.profileDeleteButtonTextColor,
                      textColor: AppColors.profileWhite,
                      mainAxisAlignment: MainAxisAlignment.center,
                      borderRadius: 6,
                      onTap: () {
                        profileController.userLogout();
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
