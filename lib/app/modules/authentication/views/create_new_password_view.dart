import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/authentication/views/password_change_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../controllers/authentication_controller.dart';

class CreateNewPasswordView extends GetView<AuthenticationController> {
  final String email;

  CreateNewPasswordView({
    required this.email,
    super.key
  });

  final AuthenticationController _controller = Get.put(AuthenticationController());
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _handleResetPassword(BuildContext context) async {
    if (_passwordController.text.trim().isEmpty || _confirmPasswordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in every field',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final strength = validateStrongPassword(_passwordController.text.trim());
    if (!strength.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strength.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      Get.snackbar(
        'Error',
        'Password and Confirm Password must be same',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _controller.resetPassword(email,_passwordController.text.trim(),_confirmPasswordController.text.trim());
    } catch (e) {
      print('Error logging in: $e');
      Get.snackbar(
        'Error',
        'Failed to reset password. Please try again',
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
                          'Create new password'.tr,
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
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 20.h,),

                        Text(
                            'Your new password must be unique from those previously used.'.tr,
                            style: h4.copyWith(
                              color: AppColors.authenticationButtonBorderColor,
                              fontSize: 18.sp,
                            ),
                            textAlign: TextAlign.center
                        ),

                        SizedBox(height: 24.h,),

                        Obx(() {
                          return CustomTextField(
                            hintText: 'New password'.tr,
                            controller: _passwordController,
                            prefixIcon: 'assets/images/authentication/password.png',
                            suffixIcon: controller.isNewPasswordVisible.value ? 'assets/images/authentication/invisible.png' : 'assets/images/authentication/visible.png',
                            isObscureText: controller.isNewPasswordVisible,
                          );
                        }),

                        SizedBox(height: 20.h,),

                        Obx(() {
                          return CustomTextField(
                            hintText: 'Confirm password'.tr,
                            controller: _confirmPasswordController,
                            prefixIcon: 'assets/images/authentication/password.png',
                            suffixIcon: controller.isConfirmNewPasswordVisible.value ? 'assets/images/authentication/invisible.png' : 'assets/images/authentication/visible.png',
                            isObscureText: controller.isConfirmNewPasswordVisible,
                          );
                        }),

                        SizedBox(height: 30.h,),

                        CustomButton(
                          text: 'Save'.tr,
                          paddingLeft: 60,
                          paddingRight: 60,
                          onTap: () {
                            _handleResetPassword(context);
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


class PasswordValidationResult {
  final bool isValid;
  final String message;
  const PasswordValidationResult(this.isValid, this.message);
}

PasswordValidationResult validateStrongPassword(String password) {
  final p = password.trim();

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
