import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final String prefixIcon;
  final String suffixIcon;
  final RxBool isObscureText;

  const CustomTextField({
    required this.hintText,
    this.prefixIcon = '',
    this.suffixIcon = '',
    required this.isObscureText,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15.47.w, vertical: 17.h),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.authenticationButtonBorderColor,
          )
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.authenticationButtonBorderColor,
            )
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.authenticationButtonBorderColor,
            )
        ),

        hintText: hintText,
        hintStyle: h4.copyWith(
          color: AppColors.authenticationButtonBorderColor,
          fontSize: 14.sp,
        ),

        prefixIcon: prefixIcon != '' ? SizedBox(
          width: 22.w,
          height: 22.h,
          child: Image.asset(
            prefixIcon,
            scale: 4,
          ),
        ) : SizedBox.shrink(),

        suffixIcon: suffixIcon != '' ? GestureDetector(
          onTap: () {
            isObscureText.value = !isObscureText.value;
          },
          child: SizedBox(
            child: Image.asset(
              width: 24.w,
              height: 24.h,
              suffixIcon,
              scale: 4,
            ),
          ),
        ) : SizedBox.shrink(),
      ),

      obscureText: isObscureText.value,
    );
  }
}
