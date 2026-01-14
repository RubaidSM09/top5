import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/authentication/controllers/authentication_controller.dart';
import 'package:top5/app/modules/authentication/views/mail_verification_view.dart';
import 'package:top5/app/modules/authentication/views/sign_up_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';

class SignUpFormView extends GetView<AuthenticationController> {
  SignUpFormView({super.key});

  final AuthenticationController _controller = Get.find<AuthenticationController>();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _handleSignUpSendOtp(BuildContext context) async {
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please provide email address',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _controller.signUpSendOtp(context, _emailController.text.trim());
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
                          'What’s your email address?'.tr,
                          style: h2.copyWith(
                            color: AppColors.authenticationBlack,
                            fontSize: 24.sp,
                          ),
                        ),

                        SizedBox(height: 24.h,),

                        CustomTextField(
                          hintText: 'abc@email.com',
                          controller: _emailController,
                          prefixIcon: 'assets/images/authentication/mail.png',
                          isObscureText: false.obs,
                        ),

                        SizedBox(height: 24.h,),

                        Row(
                          spacing: 12.w,
                          children: [
                            Obx(() {
                              return GestureDetector(
                                onTap: () {
                                  controller.tppCheckboxController.value = !controller.tppCheckboxController.value;
                                },
                                child: Icon(
                                  controller.tppCheckboxController.value ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                  color: AppColors.authenticationGreen,
                                  size: 24.r,
                                ),
                              );
                            }),

                            Row(
                              children: [
                                Text(
                                  'I agree to '.tr,
                                  style: h4.copyWith(
                                    color: AppColors.authenticationButtonBorderColor,
                                    fontSize: 14.sp,
                                  ),
                                ),

                                SizedBox(
                                  width: 235.w,
                                  child: Text(
                                    'Terms and Privacy Policy.'.tr,
                                    style: h4.copyWith(
                                      color: AppColors.authenticationGreen,
                                      fontSize: 14.sp,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),

                        SizedBox(height: 412.h,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: 'Back'.tr,
                              color: AppColors.top5Transparent,
                              borderColor: AppColors.authenticationButtonBorderColor,
                              textColor: AppColors.authenticationButtonTextColor2,
                              paddingLeft: 60,
                              paddingRight: 60,
                              onTap: () => Navigator.pop(context),
                            ),

                            CustomButton(
                              text: 'Next'.tr,
                              paddingLeft: 60,
                              paddingRight: 60,
                              onTap: () {
                                _handleSignUpSendOtp(context);
                              },
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
