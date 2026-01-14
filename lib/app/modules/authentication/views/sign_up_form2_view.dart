import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/authentication/views/sign_up_form3_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../controllers/authentication_controller.dart';

class SignUpForm2View extends GetView<AuthenticationController> {
  final String email;

  SignUpForm2View({
    required this.email,
    super.key
  });

  final TextEditingController _fullNameController = TextEditingController();

  Future<void> _handleSignUp() async {
    final name = _fullNameController.text.trim();

    // ✅ Name validation HERE
    if (name.isEmpty || !RegExp(r'^[A-Za-z ]+$').hasMatch(name)) {
      Get.snackbar(
        'Error',
        'Name can contain only letters and spaces',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Optional: normalize spaces
    final cleanName = name.replaceAll(RegExp(r'\s+'), ' ');

    Get.to(() => SignUpForm3View(
      email: email,
      fullName: cleanName,
    ));
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
                          'What’s your name?'.tr,
                          style: h2.copyWith(
                            color: AppColors.authenticationBlack,
                            fontSize: 24.sp,
                          ),
                        ),

                        SizedBox(height: 24.h,),

                        CustomTextField(
                          hintText: 'Full name'.tr,
                          controller: _fullNameController,
                          prefixIcon: 'assets/images/authentication/full_name.png',
                          isObscureText: false.obs,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z ]")),
                          ],
                        ),

                        SizedBox(height: 444.h,),

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
                                _handleSignUp();
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
