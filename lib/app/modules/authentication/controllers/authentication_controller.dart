import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthenticationController extends GetxController {
  TextEditingController emailController = TextEditingController();

  final RxBool isSignInPasswordVisible = true.obs;
  final RxBool isSignUpPasswordVisible = true.obs;
  final RxBool isSignUpConfirmPasswordVisible = true.obs;
  final RxBool isNewPasswordVisible = true.obs;
  final RxBool isConfirmNewPasswordVisible = true.obs;

  final RxBool rememberMeController = true.obs;
  final RxBool tppCheckboxController = true.obs;

  // === OTP state ===
  final otpList = List<String>.filled(6, '').obs;

  // Persistent controllers & focus nodes
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final focusNodes = List.generate(6, (_) => FocusNode());

  // Computed helpers
  String get otp => otpControllers.map((c) => c.text).join();
  bool get isOTPComplete => otpControllers.every((c) => c.text.isNotEmpty);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    for (final c in otpControllers) c.dispose();
    for (final f in focusNodes) f.dispose();
    super.onClose();
  }

  // ---- OTP editing logic ----

  /// Call this from TextField.onChanged of field [index].
  /// Handles single char entry and multi-char paste starting at [index].
  void updateOTP(int index, String value) {
    if (value.isEmpty) {
      // cleared current field
      otpList[index] = '';
      otpControllers[index].text = '';
      return;
    }

    // If user pasted multiple digits in a single field
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      _applyPastedDigits(index, digits);
      return;
    }

    // Normal single-digit input
    final ch = digits[0];
    otpList[index] = ch;
    _setControllerText(index, ch);

    // Move to next focus if not last
    if (index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
      otpControllers[index + 1].selection =
          TextSelection.collapsed(offset: otpControllers[index + 1].text.length);
    } else {
      focusNodes[index].unfocus();
    }
  }

  /// Call this from a RawKeyboardListener onKey when backspace pressed and current is empty.
  void handleBackspaceWhenEmpty(int index) {
    if (index > 0) {
      focusNodes[index - 1].requestFocus();
      otpControllers[index - 1].selection =
          TextSelection.collapsed(offset: otpControllers[index - 1].text.length);
    }
  }

  /// Clear all boxes.
  void clear() {
    for (var i = 0; i < otpControllers.length; i++) {
      otpControllers[i].clear();
      otpList[i] = '';
    }
    // Move focus to first box
    if (focusNodes.isNotEmpty) {
      focusNodes.first.requestFocus();
    }
  }

  /// Programmatically set the full OTP (e.g., from an autofill) and focus last box.
  void setOtp(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '').split('');
    clear();
    for (int i = 0; i < digits.length && i < 6; i++) {
      _setControllerText(i, digits[i]);
      otpList[i] = digits[i];
    }
    final last = (digits.length - 1).clamp(0, 5);
    focusNodes[last].requestFocus();
  }

  void _applyPastedDigits(int startIndex, String digits) {
    var idx = startIndex;
    for (final d in digits.split('')) {
      if (idx >= 6) break;
      _setControllerText(idx, d);
      otpList[idx] = d;
      idx++;
    }
    final next = idx <= 5 ? idx : 5;
    if (next <= 5 && !isOTPComplete) {
      focusNodes[next].requestFocus();
    } else {
      focusNodes[(idx - 1).clamp(0, 5)].unfocus();
    }
  }

  void _setControllerText(int index, String value) {
    // Avoid triggering extra onChanged cycles by directly setting text and selection.
    otpControllers[index]
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
  }
}
