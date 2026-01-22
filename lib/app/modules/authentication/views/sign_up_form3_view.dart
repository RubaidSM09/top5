import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/dashboard/views/dashboard_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../controllers/authentication_controller.dart';

class SignUpForm3View extends GetView<AuthenticationController> {
  final String email;
  final String fullName;

  SignUpForm3View({
    required this.email,
    required this.fullName,
    super.key
  });

  final AuthenticationController _controller = Get.put(AuthenticationController());
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _handleSignUp(BuildContext context) async {
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      Get.snackbar('Error', 'Please fill in every field', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // ✅ Check strength before matching confirm
    final strength = validateStrongPassword(password);
    if (!strength.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strength.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      /*Get.snackbar(
        'Weak password',
        strength.message,
        snackPosition: SnackPosition.BOTTOM,
      );*/
      return;
    }

    if (password != confirm) {
      Get.snackbar('Error', 'Password and Confirm Password must be same', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      await _controller.signUp(fullName, email, password, confirm);
    } catch (e) {
      print('Error signing up: $e');
      Get.snackbar('Error', 'Failed to sign up. Please try again', snackPosition: SnackPosition.BOTTOM);
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
                          'Enter password'.tr,
                          style: h2.copyWith(
                            color: AppColors.authenticationBlack,
                            fontSize: 24.sp,
                          ),
                        ),

                        SizedBox(height: 30.h,),

                        Obx(() {
                          return CustomTextField(
                            hintText: 'Type you password'.tr,
                            controller: _passwordController,
                            prefixIcon: 'assets/images/authentication/password2.png',
                            suffixIcon: controller.isSignUpPasswordVisible.value ? 'assets/images/authentication/invisible.png' : 'assets/images/authentication/visible.png',
                            isObscureText: controller.isSignUpPasswordVisible,
                          );
                        }),

                        SizedBox(height: 24.h,),

                        Text(
                          'Confirm password'.tr,
                          style: h2.copyWith(
                            color: AppColors.authenticationBlack,
                            fontSize: 24.sp,
                          ),
                        ),

                        SizedBox(height: 24.h,),

                        Obx(() {
                          return CustomTextField(
                            hintText: 'Type you password again'.tr,
                            controller: _confirmPasswordController,
                            prefixIcon: 'assets/images/authentication/password2.png',
                            suffixIcon: controller.isSignUpConfirmPasswordVisible.value ? 'assets/images/authentication/invisible.png' : 'assets/images/authentication/visible.png',
                            isObscureText: controller.isSignUpConfirmPasswordVisible,
                          );
                        }),

                        SizedBox(height: 306.h,),

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
                                _handleSignUp(context);
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


class PasswordValidationResult {
  final bool isValid;
  final String message;
  const PasswordValidationResult(this.isValid, this.message);
}

PasswordValidationResult validateStrongPassword(String password) {
  final p = password.trim();

  // Adjust these rules as you like:
  const minLen = 8;
  final hasUpper = RegExp(r'[A-Z]').hasMatch(p);
  final hasLower = RegExp(r'[a-z]').hasMatch(p);
  final hasDigit = RegExp(r'\d').hasMatch(p);
  final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]~`+=;]').hasMatch(p);
  final hasSpace = RegExp(r'\s').hasMatch(p);

  if (p.length < minLen) {
    return const PasswordValidationResult(false, 'Password must be at least 8 characters');
  }
  if (hasSpace) {
    return const PasswordValidationResult(false, 'Password must not contain spaces');
  }
  if (!hasUpper) {
    return const PasswordValidationResult(false, 'Add at least 1 uppercase letter (A-Z)');
  }
  if (!hasLower) {
    return const PasswordValidationResult(false, 'Add at least 1 lowercase letter (a-z)');
  }
  if (!hasDigit) {
    return const PasswordValidationResult(false, 'Add at least 1 number (0-9)');
  }
  if (!hasSpecial) {
    return const PasswordValidationResult(false, 'Add at least 1 special character (!@#...)');
  }

  return const PasswordValidationResult(true, 'Strong password');
}
