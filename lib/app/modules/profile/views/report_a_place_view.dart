import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/profile/views/personal_info_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../controllers/profile_controller.dart';

class ReportAPlaceView extends GetView {
  ReportAPlaceView({super.key});

  final ProfileController _controller = Get.put(ProfileController());
  final TextEditingController _supportEmailController = TextEditingController();
  final TextEditingController _reportUrlController = TextEditingController();
  final TextEditingController _reportController = TextEditingController();

  Future<void> _handleSubmitReport() async {
    if (_supportEmailController.text.trim().isEmpty || _reportController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in every field',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _controller.submitReport(_supportEmailController.text.trim(),_reportUrlController.text.trim(),_reportController.text.trim(),);
    } catch (e) {
      print('Error submitting report: $e');
      Get.snackbar(
        'Error',
        'Failed to submit report. Please try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ProfileAppBar(appBarTitle: 'Report a place'.tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 21.h),
                  decoration: BoxDecoration(
                    color: AppColors.profileSearchBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'E-mail'.tr,
                            style: h2.copyWith(
                              color: AppColors.profileBlack,
                              fontSize: 16.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 5.h,),

                      CustomTextField(
                        hintText: 'Enter Email'.tr,
                        controller: _supportEmailController,
                        hintTextColor: AppColors.profileGray,
                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 11.h),
                        borderColor: AppColors.profileGray,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.top5Black.withAlpha(64),
                            blurRadius: 2.r,
                          )
                        ],
                        isObscureText: false.obs,
                      ),

                      SizedBox(height: 15.h,),

                      Row(
                        children: [
                          Text(
                            'Enter URL'.tr,
                            style: h2.copyWith(
                              color: AppColors.profileBlack,
                              fontSize: 16.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 5.h,),

                      CustomTextField(
                        hintText: 'Enter the place URL'.tr,
                        controller: _reportUrlController,
                        hintTextColor: AppColors.profileGray,
                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 11.h),
                        borderColor: AppColors.profileGray,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.top5Black.withAlpha(64),
                            blurRadius: 2.r,
                          )
                        ],
                        isObscureText: false.obs,
                      ),

                      SizedBox(height: 15.h,),

                      Row(
                        children: [
                          Text(
                            'Report'.tr,
                            style: h2.copyWith(
                              color: AppColors.profileBlack,
                              fontSize: 16.sp,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 5.h,),

                      CustomTextField(
                        hintText: 'Describe Your report'.tr,
                        controller: _reportController,
                        hintTextColor: AppColors.profileGray,
                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 11.h),
                        borderColor: AppColors.profileGray,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.top5Black.withAlpha(64),
                            blurRadius: 2.r,
                          )
                        ],
                        isObscureText: false.obs,
                        maxLine: 6,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h,),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: CustomButton(
                    text: 'Send'.tr,
                    onTap: () {
                      _handleSubmitReport();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
