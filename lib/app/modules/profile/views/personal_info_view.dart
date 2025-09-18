import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:top5/common/widgets/custom_text_field.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';

class PersonalInfoView extends GetView {
  const PersonalInfoView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ProfileAppBar(appBarTitle: 'Personal Info',),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 17.h),
              decoration: BoxDecoration(
                color: AppColors.profileSearchBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/images/home/profile_pic.jpg'
                    ),
                    radius: 35.r,
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

                  ProfileInfoSection(
                    title: 'Name',
                    info: 'Alex Martin',
                  ),

                  SizedBox(height: 8.h,),

                  ProfileInfoSection(
                    title: 'E-mail',
                    info: 'danmith1234@gmail.com',
                  ),

                  SizedBox(height: 8.h,),

                  ProfileInfoSection(
                    title: 'Phone',
                    info: '+1 123745689',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class ProfileAppBar extends StatelessWidget {
  final String appBarTitle;

  const ProfileAppBar({required this.appBarTitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: AppColors.serviceBlack,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.serviceWhite,
              size: 15.r,
            ),
          ),
        ),

        Text(
          appBarTitle,
          style: h2.copyWith(color: AppColors.top5Black, fontSize: 22.sp),
        ),

        SizedBox.shrink(),
      ],
    );
  }
}


class ProfileInfoSection extends StatelessWidget {
  final String title;
  final String info;

  const ProfileInfoSection({
    required this.title,
    required this.info,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: h3.copyWith(
                color: AppColors.profileGray,
                fontSize: 12.sp,
              ),
            )
          ],
        ),

        SizedBox(height: 4.h,),
        
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: AppColors.profileWhite,
            borderRadius: BorderRadius.circular(6.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.top5Black.withAlpha(64),
                blurRadius: 2.r,
                offset: Offset(0.w, 0.h),
              )
            ],
          ),
          child: Row(
            children: [
              Text(
                info,
                style: h4.copyWith(
                  color: AppColors.profileBlack,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
