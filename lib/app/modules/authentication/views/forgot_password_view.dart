import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/authentication/controllers/authentication_controller.dart';
import 'package:top5/app/modules/authentication/views/otp_verifications_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';

class ForgotPasswordView extends GetView<AuthenticationController> {
  const ForgotPasswordView({super.key});
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
                  padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 74.15.h),
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
                        Text(
                          'Forgot password?',
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

                        SizedBox(height: 20.h,),

                        Text(
                          'Don\'t worry! Please enter the email address linked with your account.',
                          style: h4.copyWith(
                            color: AppColors.authenticationButtonBorderColor,
                            fontSize: 18.sp,
                          ),
                          textAlign: TextAlign.center
                        ),

                        SizedBox(height: 24.h,),

                        CustomTextField(
                          hintText: 'abc@email.com',
                          prefixIcon: 'assets/images/authentication/mail.png',
                          isObscureText: false.obs,
                        ),

                        SizedBox(height: 30.h,),

                        CustomButton(
                          text: 'Send',
                          paddingLeft: 60,
                          paddingRight: 60,
                          onTap: () => Get.to(OtpVerificationsView()),
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
