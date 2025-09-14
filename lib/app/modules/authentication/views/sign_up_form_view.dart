import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/authentication/controllers/authentication_controller.dart';
import 'package:top5/app/modules/authentication/views/sign_up_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';

class SignUpFormView extends GetView<AuthenticationController> {
  const SignUpFormView({super.key});
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
                      children: [
                        Text(
                          'Welcome back',
                          style: h2.copyWith(
                            color: AppColors.authenticationBlack,
                            fontSize: 28.sp,
                          ),
                        ),

                        SizedBox(height: 24.h,),

                        CustomTextField(
                          hintText: 'abc@email.com',
                          prefixIcon: 'assets/images/authentication/mail.png',
                          isObscureText: false.obs,
                        ),

                        SizedBox(height: 20.h,),

                        Obx(() {
                          return CustomTextField(
                            hintText: 'Enter you password',
                            prefixIcon: 'assets/images/authentication/password.png',
                            suffixIcon: controller.isObscureText.value ? 'assets/images/authentication/invisible.png' : 'assets/images/authentication/visible.png',
                            isObscureText: controller.isObscureText,
                          );
                        }),

                        SizedBox(height: 24.h,),

                        CustomButton(
                          text: 'Sign In',
                          onTap: () {  },
                        ),

                        SizedBox(height: 30.h,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              spacing: 12.w,
                              children: [
                                Obx(() {
                                  return GestureDetector(
                                    onTap: () {
                                      controller.rememberMeController.value = !controller.rememberMeController.value;
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        left: controller.rememberMeController.value ? 15.2.w : 1.9.w,
                                        right: controller.rememberMeController.value ? 1.9.w : 15.2.w,
                                        top: 1.9.h,
                                        bottom: 1.9.h,
                                      ),
                                      decoration: BoxDecoration(
                                          color: AppColors.authenticationGreen.withAlpha(controller.rememberMeController.value ? 255 : 64),
                                          borderRadius: BorderRadius.circular(95.r)
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(7.6.r),
                                        decoration: BoxDecoration(
                                            color: AppColors.authenticationWhite,
                                            shape: BoxShape.circle
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                Text(
                                  'Remember Me',
                                  style: h4.copyWith(
                                    color: AppColors.authenticationRememberMeTextColor,
                                    fontSize: 14.sp,
                                  ),
                                )
                              ],
                            ),



                            Row(
                              children: [
                                Text(
                                  'Forgot Password?',
                                  style: h4.copyWith(
                                    color: AppColors.authenticationGreen,
                                    fontSize: 14.sp,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 22.w,
                          children: [
                            Container(
                              height: 1.h,
                              width: 103.w,
                              color: AppColors.authenticationButtonBorderColor,
                            ),

                            Text(
                              'Or',
                              style: h3.copyWith(
                                color: AppColors.authenticationButtonBorderColor,
                                fontSize: 20.sp,
                              ),
                            ),

                            Container(
                              height: 1.h,
                              width: 103.w,
                              color: AppColors.authenticationButtonBorderColor,
                            ),
                          ],
                        ),

                        SizedBox(height: 14.h,),

                        CustomButton(
                          text: 'Continue with Apple',
                          icon: 'assets/images/authentication/apple.svg',
                          color: AppColors.authenticationBlack,
                          onTap: () {  },
                        ),

                        SizedBox(height: 16.h,),

                        CustomButton(
                          text: 'Continue with Google',
                          icon: 'assets/images/authentication/google.svg',
                          color: AppColors.authenticationWhite,
                          borderColor: AppColors.authenticationButtonBorderColor,
                          textColor: AppColors.authenticationButtonTextColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.top5Black.withAlpha(64),
                              blurRadius: 6.r,
                              offset: Offset(1.w, 2.h),
                            )
                          ],
                          onTap: () {  },
                        ),

                        SizedBox(height: 60.h,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New To Top5? ',
                              style: h4.copyWith(
                                color: AppColors.authenticationGray,
                                fontSize: 14.sp,
                              ),
                            ),

                            GestureDetector(
                              onTap: () => Get.to(SignUpView()),
                              child: Text(
                                'Sign Up',
                                style: h4.copyWith(
                                  color: AppColors.authenticationGreen,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
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
