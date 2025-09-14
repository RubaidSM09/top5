import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/authentication/views/sign_in_view.dart';
import 'package:top5/app/modules/authentication/views/sign_up_form_view.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/widgets/custom_button.dart';

import '../../../../common/custom_fonts.dart';

class SignUpView extends GetView {
  const SignUpView({super.key});
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
                  padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 39.h),
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
                          'Welcome',
                          style: h2.copyWith(
                            color: AppColors.authenticationBlack,
                            fontSize: 28.sp,
                          ),
                        ),
                    
                        SizedBox(height: 73.h,),
                    
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
                    
                        SizedBox(height: 24.h,),
                    
                        CustomButton(
                          text: 'Continue with email',
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
                          onTap: () => Get.to(SignUpFormView()),
                        ),
                    
                        SizedBox(height: 39.h,),
                    
                        Column(
                          children: [
                            Text(
                              'By continuing, you agree to',
                              style: h4.copyWith(
                                color: AppColors.authenticationButtonBorderColor,
                                fontSize: 14.sp,
                              ),
                            ),
                    
                            Text(
                              'Terms and Privacy Policy.',
                              style: h4.copyWith(
                                color: AppColors.authenticationGreen,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                    
                        SizedBox(height: 39.h,),
                    
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: h4.copyWith(
                                color: AppColors.authenticationGray,
                                fontSize: 14.sp,
                              ),
                            ),
                    
                            GestureDetector(
                              onTap: () => Get.to(SignInView()),
                              child: Text(
                                'Sign In',
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
