import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/profile/views/personal_info_view.dart';
import 'package:top5/common/widgets/custom_button.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_text_field.dart';

class EditPersonalInfoView extends GetView {
  const EditPersonalInfoView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ProfileAppBar(appBarTitle: 'Edit Personal Info',),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 17.h),
                  decoration: BoxDecoration(
                    color: AppColors.profileSearchBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(
                                'assets/images/home/profile_pic.jpg'
                            ),
                            radius: 35.r,
                          ),

                          Positioned(
                            left: 62.w,
                            top: 45.h,
                            child: SvgPicture.asset(
                              'assets/images/profile/camera.svg'
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 8.h,),

                      Text(
                        'Alex Martin',
                        style: h2.copyWith(
                          fontSize: 20.sp,
                          color: AppColors.profileBlack,
                        ),
                      ),

                      SizedBox(height: 9.h,),

                      Row(
                        children: [
                          Text(
                            'Name',
                            style: h3.copyWith(
                              color: AppColors.profileGray,
                              fontSize: 12.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 4.h,),

                      CustomTextField(
                        hintText: 'Alex Martin',
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
                            'E-mail',
                            style: h3.copyWith(
                              color: AppColors.profileGray,
                              fontSize: 12.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 4.h,),

                      CustomTextField(
                        hintText: 'danmith1234@gmail.com',
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
                            'Phone',
                            style: h3.copyWith(
                              color: AppColors.profileGray,
                              fontSize: 12.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 4.h,),

                      CustomTextField(
                        hintText: '+1 123745689',
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
                  text: 'Save',
                  onTap: () {  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
