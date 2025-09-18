import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/profile/views/personal_info_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';

class ChangePasswordView extends GetView {
  const ChangePasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ProfileAppBar(appBarTitle: 'Change Password',),
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
                            'Current Password',
                            style: h3.copyWith(
                              color: AppColors.profileGray,
                              fontSize: 12.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 4.h,),

                      CustomTextField(
                        hintText: 'Enter Current Password',
                        hintTextColor: AppColors.profileBlack,
                        color: AppColors.profileWhite,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
                        borderColor: AppColors.top5Transparent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.top5Black.withAlpha(64),
                            blurRadius: 2.r,
                          )
                        ],
                        isObscureText: false.obs,
                      ),

                      SizedBox(height: 8.h,),

                      Row(
                        children: [
                          Text(
                            'New Password',
                            style: h3.copyWith(
                              color: AppColors.profileGray,
                              fontSize: 12.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 4.h,),

                      CustomTextField(
                        hintText: 'Enter New Password',
                        hintTextColor: AppColors.profileBlack,
                        color: AppColors.profileWhite,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
                        borderColor: AppColors.top5Transparent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.top5Black.withAlpha(64),
                            blurRadius: 2.r,
                          )
                        ],
                        isObscureText: false.obs,
                      ),

                      SizedBox(height: 8.h,),

                      Row(
                        children: [
                          Text(
                            'Confirm Password',
                            style: h3.copyWith(
                              color: AppColors.profileGray,
                              fontSize: 12.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 4.h,),

                      CustomTextField(
                        hintText: 'Re-inter New Password',
                        hintTextColor: AppColors.profileBlack,
                        color: AppColors.profileWhite,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
                        borderColor: AppColors.top5Transparent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.top5Black.withAlpha(64),
                            blurRadius: 2.r,
                          )
                        ],
                        isObscureText: false.obs,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h,),

                CustomButton(
                  text: 'Update Password',
                  onTap: () {  },
                ),

                SizedBox(height: 10.h,),

                Text(
                  'Make sure your new password is at least 8 characters long.',
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
