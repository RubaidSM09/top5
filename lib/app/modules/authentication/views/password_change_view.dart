import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/authentication/views/sign_in_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';

class PasswordChangeView extends GetView {
  const PasswordChangeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authenticationBlue,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 32.h,),

              SvgPicture.asset(
                'assets/images/authentication/top5_logo_horizontal.svg',
              ),

              SizedBox(height: 32.h,),

              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 54.15.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                    color: AppColors.authenticationWhite,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/images/authentication/successmark.svg',
                        ),

                        SizedBox(height: 23.85.h,),

                        Text(
                          'Password Change!',
                          style: h2.copyWith(
                              color: AppColors.authenticationBlack,
                              fontSize: 36.sp,
                              shadows: [
                                Shadow(
                                    color: AppColors.top5Black.withAlpha(26),
                                    blurRadius: 42.4.r,
                                    offset: Offset(0.w, 4.h)
                                )
                              ]
                          ),
                        ),

                        SizedBox(height: 12.h,),

                        Text(
                            'Your password has been changed successfully.',
                            style: h4.copyWith(
                              color: AppColors.authenticationButtonBorderColor,
                              fontSize: 18.sp,
                            ),
                            textAlign: TextAlign.center
                        ),

                        SizedBox(height: 30.h,),

                        CustomButton(
                          text: 'Back To Login',
                          paddingLeft: 60,
                          paddingRight: 60,
                          onTap: () => Get.to(SignInView()),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
