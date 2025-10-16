import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/authentication/views/create_new_password_view.dart';
import 'package:top5/common/widgets/custom_otp_field.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../controllers/authentication_controller.dart';

class OtpVerificationsView extends GetView<AuthenticationController> {
  final String email;

  OtpVerificationsView({
    required this.email,
    super.key
  });

  final AuthenticationController _controller = Get.put(AuthenticationController());

  Future<void> _handleResetPasswordOtpVerification() async {
    if (_controller.otp.isEmpty) {
      Get.snackbar(
        'Error',
        'Incorrect OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _controller.resetPasswordOtpVerification(email, _controller.otp);
    } catch (e) {
      print('Error logging in: $e');
      Get.snackbar(
        'Error',
        'Failed to sign up. Please try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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
                          'OTP verifications',
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
                            'Enter the verification code we just sent on your email address.',
                            style: h4.copyWith(
                              color: AppColors.authenticationButtonBorderColor,
                              fontSize: 18.sp,
                            ),
                            textAlign: TextAlign.center
                        ),

                        SizedBox(height: 24.h,),

                        CustomOtpField(
                          otpControllers: controller.otpControllers,
                          focusNodes: controller.focusNodes,
                          updateOTP: controller.updateOTP,
                        ),

                        SizedBox(height: 40.15.h,),

                        CustomButton(
                          text: 'Send',
                          paddingLeft: 60,
                          paddingRight: 60,
                          onTap: () {
                            _handleResetPasswordOtpVerification();
                          },
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
