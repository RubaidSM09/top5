import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';
import 'package:top5/common/widgets/custom_button.dart';

class LogOutView extends GetView {
  const LogOutView({super.key});
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
              'Log Out',
              style: h1.copyWith(
                color: AppColors.profileBlack,
                fontSize: 20.sp,
              ),
            ),

            SizedBox(height: 16.h,),

            Text(
              'Are you sure you want to log out?',
              style: h4.copyWith(
                color: AppColors.profileDeleteButtonTextColor,
                fontSize: 16.sp,
              ),
            ),

            SizedBox(height: 30.h,),

            Row(
              spacing: 17.w,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    color: AppColors.top5Transparent,
                    borderColor: AppColors.profileGray,
                    textColor: AppColors.profileBlack,
                    borderRadius: 6,
                    onTap: () {  },
                  ),
                ),

                Expanded(
                  child: CustomButton(
                    text: 'Log Out',
                    color: AppColors.profileDeleteButtonTextColor,
                    textColor: AppColors.profileWhite,
                    borderRadius: 6,
                    onTap: () {  },
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
