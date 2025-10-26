import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';

class RemoveReservationListView extends GetView {
  const RemoveReservationListView({super.key});
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
              'Remove from reservation list'.tr,
              style: h1.copyWith(
                color: AppColors.profileBlack,
                fontSize: 20.sp,
              ),
            ),

            SizedBox(height: 16.h,),

            Text(
              'Are you sure you want to remove this item?'.tr,
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
                    text: 'Cancel'.tr,
                    color: AppColors.top5Transparent,
                    borderColor: AppColors.profileGray,
                    textColor: AppColors.profileBlack,
                    borderRadius: 6,
                    onTap: () {  },
                  ),
                ),

                Expanded(
                  child: CustomButton(
                    text: 'Remove'.tr,
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
