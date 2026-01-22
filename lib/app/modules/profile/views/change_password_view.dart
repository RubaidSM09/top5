import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/profile/controllers/profile_controller.dart';
import 'package:top5/app/modules/profile/views/personal_info_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';

class ChangePasswordView extends GetView {
  ChangePasswordView({super.key});

  final ProfileController _controller = Get.find<ProfileController>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _handleChangePassword(BuildContext context) async {
    if (_currentPasswordController.text.trim().isEmpty || _newPasswordController.text.trim().isEmpty || _confirmPasswordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in every field',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final strength = validateStrongPassword(_newPasswordController.text.trim());
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

    if (_newPasswordController.text.trim() != _confirmPasswordController.text.trim()) {
      Get.snackbar(
        'Error',
        'Password and Confirm Password must be same',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final success = await _controller.changePassword(_currentPasswordController.text.trim(),_newPasswordController.text.trim(),_confirmPasswordController.text.trim());

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error logging in: $e');
      Get.snackbar(
        'Error',
        'Failed to change password. Please try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ProfileAppBar(appBarTitle: 'Change Password'.tr,),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 24.h),
                  decoration: BoxDecoration(
                    color: AppColors.profileSearchBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Current Password'.tr,
                            style: h3.copyWith(
                              color: AppColors.profileGray,
                              fontSize: 12.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 4.h,),

                      Obx(() {
                        return CustomTextField(
                          hintText: 'Enter Current Password'.tr,
                          controller: _currentPasswordController,
                          hintTextColor: AppColors.profileBlack,
                          color: AppColors.profileWhite,
                          padding: EdgeInsets.symmetric(
                              horizontal: 18.w, vertical: 11.h),
                          borderColor: AppColors.top5Transparent,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.top5Black.withAlpha(64),
                              blurRadius: 2.r,
                            )
                          ],
                          suffixIcon: _controller.isCurrentPasswordVisible.value
                              ? 'assets/images/authentication/invisible.png'
                              : 'assets/images/authentication/visible.png',
                          isObscureText: _controller.isCurrentPasswordVisible,
                        );
                      }),

                      SizedBox(height: 8.h,),

                      Row(
                        children: [
                          Text(
                            'New Password'.tr,
                            style: h3.copyWith(
                              color: AppColors.profileGray,
                              fontSize: 12.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 4.h,),

                      Obx(() {
                        return CustomTextField(
                          hintText: 'Enter New Password'.tr,
                          controller: _newPasswordController,
                          hintTextColor: AppColors.profileBlack,
                          color: AppColors.profileWhite,
                          padding: EdgeInsets.symmetric(
                              horizontal: 18.w, vertical: 11.h),
                          borderColor: AppColors.top5Transparent,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.top5Black.withAlpha(64),
                              blurRadius: 2.r,
                            )
                          ],
                          suffixIcon: _controller.isNewPasswordVisible.value
                              ? 'assets/images/authentication/invisible.png'
                              : 'assets/images/authentication/visible.png',
                          isObscureText: _controller.isNewPasswordVisible,
                        );
                      }),

                      SizedBox(height: 8.h,),

                      Row(
                        children: [
                          Text(
                            'Confirm Password'.tr,
                            style: h3.copyWith(
                              color: AppColors.profileGray,
                              fontSize: 12.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 4.h,),

                      Obx(() {
                        return CustomTextField(
                          hintText: 'Re-enter New Password'.tr,
                          controller: _confirmPasswordController,
                          hintTextColor: AppColors.profileBlack,
                          color: AppColors.profileWhite,
                          padding: EdgeInsets.symmetric(
                              horizontal: 18.w, vertical: 11.h),
                          borderColor: AppColors.top5Transparent,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.top5Black.withAlpha(64),
                              blurRadius: 2.r,
                            )
                          ],
                          suffixIcon: _controller.isConfirmPasswordVisible.value
                              ? 'assets/images/authentication/invisible.png'
                              : 'assets/images/authentication/visible.png',
                          isObscureText: _controller.isConfirmPasswordVisible,
                        );
                      }),
                    ],
                  ),
                ),

                SizedBox(height: 30.h,),

                CustomButton(
                  text: 'Update Password'.tr,
                  onTap: () {
                    _handleChangePassword(context);
                  },
                ),

                SizedBox(height: 10.h,),

                Text(
                  'Make sure your new password is at least 8 characters long.'.tr,
                  textAlign: TextAlign.center,
                  style: h4.copyWith(
                    color: AppColors.profileBlack,
                    fontSize: 12.sp,
                  ),
                )
              ],
            ),
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
  final hasSpecial =
  RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]~`+=;]').hasMatch(p);
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
