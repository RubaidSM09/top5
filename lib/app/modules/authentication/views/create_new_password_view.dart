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
  const CreateNewPasswordView({super.key});
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
                          'Create new password',
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
                            'Your new password must be unique from those previously used.',
                            style: h4.copyWith(
                              color: AppColors.authenticationButtonBorderColor,
                              fontSize: 18.sp,
                            ),
                            textAlign: TextAlign.center
                        ),

                        SizedBox(height: 24.h,),

                        Obx(() {
                          return CustomTextField(
                            hintText: 'New password',
                            prefixIcon: 'assets/images/authentication/password.png',
                            suffixIcon: controller.isNewPasswordVisible.value ? 'assets/images/authentication/invisible.png' : 'assets/images/authentication/visible.png',
                            isObscureText: controller.isNewPasswordVisible,
                          );
                        }),

                        SizedBox(height: 20.h,),

                        Obx(() {
                          return CustomTextField(
                            hintText: 'Confirm password',
                            prefixIcon: 'assets/images/authentication/password.png',
                            suffixIcon: controller.isConfirmNewPasswordVisible.value ? 'assets/images/authentication/invisible.png' : 'assets/images/authentication/visible.png',
                            isObscureText: controller.isConfirmNewPasswordVisible,
                          );
                        }),

                        SizedBox(height: 30.h,),

                        CustomButton(
                          text: 'Save',
                          paddingLeft: 60,
                          paddingRight: 60,
                          onTap: () => Get.to(PasswordChangeView()),
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
