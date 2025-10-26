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
  final Color color;
  final EdgeInsetsGeometry? padding;
  final Color borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color hintTextColor;
  final int maxLine;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool enabled;

  // ✅ NEW (optional): fire when user hits the keyboard action (search/go/done)
  final void Function(String)? onSubmitted;

  // ✅ NEW (optional): make the left icon clickable (e.g., trigger search)
  final VoidCallback? onPrefixTap;

  // ✅ NEW (optional): control keyboard action button (e.g., TextInputAction.search)
  final TextInputAction? textInputAction;

  const CustomTextField({
    required this.hintText,
    this.prefixIcon = '',
    this.suffixIcon = '',
    required this.isObscureText,
    this.color = AppColors.top5Transparent,
    this.padding = const EdgeInsets.symmetric(horizontal: 15.47, vertical: 17),
    this.borderColor = AppColors.authenticationButtonBorderColor,
    this.borderRadius = 12,
    this.boxShadow = const [BoxShadow()],
    this.hintTextColor = AppColors.authenticationButtonBorderColor,
    this.maxLine = 1,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.enabled = true,
    this.onSubmitted,      // NEW
    this.onPrefixTap,      // NEW
    this.textInputAction,  // NEW
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // boxShadow: boxShadow, // (kept commented as in your original)
      ),
      // Wrap with Obx so obscureText toggles immediately everywhere
      child: Obx(() => TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        enabled: enabled,

        // ✅ NEW
        onFieldSubmitted: onSubmitted,
        textInputAction: textInputAction,

        decoration: InputDecoration(
          contentPadding: padding,
          filled: true,
          fillColor: color,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
            borderSide: BorderSide(color: borderColor),
          ),

          hintText: hintText,
          hintStyle: h4.copyWith(
            color: hintTextColor,
            fontSize: 14.sp,
          ),

          // ✅ If onPrefixTap is provided, make the prefix icon tappable
          prefixIcon: prefixIcon != '' ? GestureDetector(
            onTap: onPrefixTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 22.w,
              height: 22.h,
              child: Image.asset(prefixIcon, scale: 4),
            ),
          ) : null,

          // Keep your suffix behavior (toggle obscure)
          suffixIcon: suffixIcon != '' ? GestureDetector(
            onTap: () {
              isObscureText.value = !isObscureText.value;
            },
            child: SizedBox(
              width: 24.w,
              height: 24.h,
              child: Image.asset(suffixIcon, scale: 4),
            ),
          ) : null,
        ),

        obscureText: isObscureText.value,
        maxLines: maxLine,
      )),
    );
  }
}
