import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_colors.dart';
import '../custom_fonts.dart';

class CustomOtpField extends StatelessWidget {
  final List<TextEditingController> otpControllers;
  final List<FocusNode> focusNodes;
  final void Function(int, String) updateOTP;
  
  const CustomOtpField({
    required this.otpControllers,
    required this.focusNodes,
    required this.updateOTP,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Padding(
          padding: index == 0
              ? EdgeInsets.only(right: 4.w)
              : index == 5
              ? EdgeInsets.only(left: 4.w)
              : EdgeInsets.symmetric(horizontal: 4.w),
          child: SizedBox(
            width: 50.w,
            height: 50.h,
            child: RawKeyboardListener(
              focusNode: FocusNode(), // for backspace handling
              onKey: (event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    otpControllers[index].text.isEmpty &&
                    index > 0) {
                  // Move back when current is empty and backspace pressed
                  focusNodes[index - 1].requestFocus();
                  otpControllers[index - 1].selection = TextSelection.collapsed(
                    offset: otpControllers[index - 1].text.length,
                  );
                }
              },
              child: TextField(
                controller: otpControllers[index],
                focusNode: focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: h0.copyWith(
                  color: AppColors.authenticationButtonTextColor2,
                  fontSize: 15.sp,
                ),
                autofocus: index == 0,
                maxLength: 1, // UI counter off below
                decoration: InputDecoration(
                  counterText: '',
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.authenticationButtonBorderColor, width: 2),
                  ),
                ),
                // Keep only digits and limit to 1 char
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6), // allow paste of up to 6
                ],
                onChanged: (value) {
                  // Handle paste of multiple digits
                  if (value.length > 1) {
                    final chars = value.replaceAll(RegExp(r'\D'), '').split('');
                    for (int i = 0; i < chars.length && (index + i) < 6; i++) {
                      otpControllers[index + i].text = chars[i];
                      updateOTP(index + i, chars[i]);
                    }
                    final nextIndex = (index + chars.length).clamp(0, 5);
                    if (nextIndex < 5) {
                      focusNodes[nextIndex + 1].requestFocus();
                    } else {
                      focusNodes[nextIndex].unfocus(); // done
                    }
                    return;
                  }

                  // Normal single digit flow
                  updateOTP(index, value);

                  if (value.isNotEmpty && index < 5) {
                    focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
