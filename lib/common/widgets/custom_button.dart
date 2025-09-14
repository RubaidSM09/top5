import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String icon;
  final void Function()? onTap;
  final double paddingLeft;
  final double paddingRight;
  final double paddingTop;
  final double paddingBottom;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  const CustomButton({
    required this.text,
    required this.onTap,
    this.icon = '',
    this.paddingLeft = 10,
    this.paddingRight = 10,
    this.paddingTop = 10,
    this.paddingBottom = 10,
    this.color = AppColors.authenticationGreen,
    this.borderColor = AppColors.top5Transparent,
    this.textColor = AppColors.authenticationWhite,
    this.borderWidth = 1,
    this.boxShadow = const [],
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: paddingLeft.w,
          right: paddingRight.w,
          top: paddingTop.h,
          bottom: paddingBottom.h,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: borderColor,
            width: borderWidth.r,
          ),
          boxShadow: boxShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16.w,
          children: [
            icon != '' ? SvgPicture.asset(
                  icon
                ) : SizedBox.shrink(),

            Text(
              text,
              style: h2.copyWith(
                color: textColor,
                fontSize: 18.sp
              ),
            )
          ],
        ),
      ),
    );
  }
}
