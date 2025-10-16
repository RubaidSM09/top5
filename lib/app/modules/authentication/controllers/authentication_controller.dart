import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:top5/app/modules/authentication/views/password_change_view.dart';
import 'package:top5/app/modules/authentication/views/sign_up_form2_view.dart';
import 'package:top5/app/modules/dashboard/views/dashboard_view.dart';

import '../../../data/services/api_services.dart';
import '../views/create_new_password_view.dart';
import '../views/mail_verification_view.dart';
import '../views/otp_verifications_view.dart';

class AuthenticationController extends GetxController {
  final RxBool isSignInPasswordVisible = true.obs;
  final RxBool isSignUpPasswordVisible = true.obs;
  final RxBool isSignUpConfirmPasswordVisible = true.obs;
  final RxBool isNewPasswordVisible = true.obs;
  final RxBool isConfirmNewPasswordVisible = true.obs;

  final RxBool rememberMeController = true.obs;
  final RxBool tppCheckboxController = true.obs;

  final ApiService _service = ApiService();
  var isLoading = false.obs;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // === OTP state ===
  final otpList = List<String>.filled(6, '').obs;

  // Persistent controllers & focus nodes
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final focusNodes = List.generate(6, (_) => FocusNode());

  // Computed helpers
  String get otp => otpControllers.map((c) => c.text).join();
  bool get isOTPComplete => otpControllers.every((c) => c.text.isNotEmpty);

  // Store tokens securely
  Future<void> storeTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  // Login Method
  Future<void> login(String email, String password) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.login(email, password);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final accessToken = responseBody['access'];
        final refreshToken = responseBody['refresh'];

        await storeTokens(accessToken, refreshToken);

        print(':::::::::responseBody:::::::::$responseBody');
        print(':::::::::accessToken:::::::::$accessToken');
        print(':::::::::refreshToken:::::::::$refreshToken');

        Get.snackbar('Success', 'Logged in Successfully');

        Get.off(() => DashboardView());
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Login failed', responseBody['message'] ?? 'Please use Correct UserName and Password');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sign Up Method
  Future<void> signUpSendOtp (String email) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.signUpSendOtp(email);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        Get.snackbar(responseBody['status'], responseBody['message']);

        Get.to(() => MailVerificationView(email: email,));
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Sign up failed', responseBody['message'] ?? 'Please use Correct email');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpOtpVerification (String email, String otp) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.signUpOtpVerification(email,otp);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        Get.snackbar(responseBody['status'], responseBody['message']);

        Get.to(() => SignUpForm2View(email: email,));
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Sign up failed', responseBody['message'] ?? 'Please use Correct email');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp (String fullName, String email, String password, String confirmPassword) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.signUp(fullName,email,password,confirmPassword);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final accessToken = responseBody['access'];
        final refreshToken = responseBody['refresh'];

        await storeTokens(accessToken, refreshToken);

        print(':::::::::responseBody:::::::::$responseBody');
        print(':::::::::accessToken:::::::::$accessToken');
        print(':::::::::refreshToken:::::::::$refreshToken');

        Get.snackbar('Success', 'Account created Successfully');

        Get.off(() => DashboardView());
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Sign up failed', responseBody['message'] ?? 'Please use Correct password');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot Password Method
  Future<void> resetPasswordSendOtp (String email) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.resetPasswordSendOtp(email);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        Get.snackbar(responseBody['status'], responseBody['message']);

        Get.to(() => OtpVerificationsView(email: email,));
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Reset password failed', responseBody['message'] ?? 'Please use Correct email');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPasswordOtpVerification (String email, String otp) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.resetPasswordOtpVerification(email,otp);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        Get.snackbar(responseBody['status'], responseBody['message']);

        Get.to(() => CreateNewPasswordView(email: email,));
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Reset password failed', responseBody['message'] ?? 'Please use Correct email');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword (String email, String password, String confirmPassword) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.resetPassword(email,password,confirmPassword);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        Get.snackbar('Success', 'Password changed Successfully');

        Get.off(() => PasswordChangeView());
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Reset password failed', responseBody['message'] ?? 'Please use Correct password');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

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
