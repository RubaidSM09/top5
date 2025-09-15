import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/authentication/views/sign_up_form2_view.dart';
import 'package:top5/common/widgets/custom_otp_field.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../controllers/authentication_controller.dart';

class MailVerificationView extends GetView<AuthenticationController> {
  const MailVerificationView({super.key});
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
                  padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 26.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                    color: AppColors.authenticationWhite,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter 6-digit code sent to your email',
                          style: h2.copyWith(
                            color: AppColors.authenticationBlack,
                            fontSize: 24.sp,
                          ),
                        ),

                        SizedBox(height: 24.h,),

                        CustomOtpField(
                          otpControllers: controller.otpControllers,
                          focusNodes: controller.focusNodes,
                          updateOTP: controller.updateOTP,
                        ),

                        SizedBox(height: 16.h,),

                        Text(
                          'Tip : Make sure check your inbox and spam folders',
                          style: h4.copyWith(
                            color: AppColors.authenticationButtonBorderColor,
                            fontSize: 14.sp,
                          ),
                        ),

                        SizedBox(height: 30.h,),

                        Row(
                          children: [
                            CustomButton(
                              text: 'Resend',
                              color: AppColors.authenticationResendButtonColor,
                              textColor: AppColors.authenticationButtonTextColor2,
                              paddingTop: 5,
                              paddingBottom: 5,
                              textSize: 14,
                              borderRadius: 24,
                              onTap: () {  },
                            ),
                          ],
                        ),

                        SizedBox(height: 341.h,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'Back',
                              color: AppColors.top5Transparent,
                              borderColor: AppColors.authenticationButtonBorderColor,
                              textColor: AppColors.authenticationButtonTextColor2,
                              paddingLeft: 60,
                              paddingRight: 60,
                              onTap: () => Get.back(),
                            ),

                            CustomButton(
                              text: 'Next',
                              paddingLeft: 60,
                              paddingRight: 60,
                              onTap: () => Get.to(SignUpForm2View()),
                            ),
                          ],
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
