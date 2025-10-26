import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../controllers/profile_controller.dart';

class DeleteAccountView extends GetView {
  const DeleteAccountView({super.key});
  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());

    return Dialog(
      backgroundColor: AppColors.profileWhite,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.54.w, vertical: 29.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete Account'.tr,
              style: h1.copyWith(
                color: AppColors.profileBlack,
                fontSize: 16.sp,
              ),
            ),

            SizedBox(height: 16.h,),

            Text(
              'Are you absolutely sure you want to delete your account?'.tr,
              style: h4.copyWith(
                color: AppColors.profileBlack,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 7.h,),

            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.profileSearchBg,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '⚠️ This action is permanent and cannot be undone. All your data will be lost.'.tr,
                style: h4.copyWith(
                  color: AppColors.profileDeleteButtonTextColor,
                  fontSize: 12.sp
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 30.h,),

            Row(
              spacing: 17.w,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel'.tr,
                    color: AppColors.top5Transparent,
                    borderColor: AppColors.profileGray,
                    textColor: AppColors.profileBlack,
                    borderRadius: 6,
                    onTap: () => Get.back(),
                  ),
                ),

                Expanded(
                  child: CustomButton(
                    text: 'Delete'.tr,
                    color: AppColors.profileDeleteButtonTextColor,
                    textColor: AppColors.profileWhite,
                    borderRadius: 6,
                    onTap: () {
                      profileController.deleteAccount();
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
