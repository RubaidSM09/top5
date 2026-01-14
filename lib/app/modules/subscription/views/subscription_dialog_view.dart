import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/subscription/views/subscription_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';

class SubscriptionDialogView extends GetView {
  final String purpose;

  const SubscriptionDialogView({
    required this.purpose,
    super.key
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.profileWhite,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$purpose limit exceeds'.tr,
              style: h1.copyWith(
                color: AppColors.profileBlack,
                fontSize: 20.sp,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h,),

            Text(
              'Your daily $purpose limit has been exceeded. Please buy subscription to get more limits'.tr,
              style: h4.copyWith(
                color: AppColors.profileDeleteButtonTextColor,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 30.h,),

            Row(
              spacing: 17.w,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Exit App'.tr,
                    color: AppColors.top5Transparent,
                    borderColor: AppColors.profileGray,
                    textColor: AppColors.profileBlack,
                    borderRadius: 6,
                    onTap: () => SystemNavigator.pop(),
                  ),
                ),

                Expanded(
                  child: CustomButton(
                    text: 'Buy Plans'.tr,
                    color: AppColors.profileDeleteButtonTextColor,
                    textColor: AppColors.profileWhite,
                    borderRadius: 6,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(SubscriptionView());
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
