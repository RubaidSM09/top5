import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/widgets/custom_button.dart';

import '../../../../common/custom_fonts.dart';

class ContactUsView extends GetView {
  const ContactUsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 59.w, vertical: 24.h,),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: AppColors.serviceWhite,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us',
              style: h1.copyWith(
                fontSize: 20.sp,
                color: AppColors.serviceBlack,
              ),
            ),

            SizedBox(height: 13.h,),

            Text(
              'Your reservation is just a call away!',
              style: h4.copyWith(
                fontSize: 16.sp,
                color: AppColors.serviceGreen,
              ),
            ),

            SizedBox(height: 24.h,),

            Row(
              spacing: 6.w,
              children: [
                SvgPicture.asset(
                  'assets/images/home/contact_no.svg'
                ),

                Text(
                  '+1 123456789',
                  style: h4.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.serviceGray,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h,),

            Row(
              spacing: 6.w,
              children: [
                SvgPicture.asset(
                    'assets/images/home/mail.svg'
                ),

                Text(
                  'resturant123@mail.com',
                  style: h4.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.serviceGray,
                  ),
                ),
              ],
            ),

            SizedBox(height: 30.h,),

            CustomButton(
              text: 'Save To Reservation',
              textSize: 16.sp,
              onTap: () {  },
            )
          ],
        ),
      ),
    );
  }
}
