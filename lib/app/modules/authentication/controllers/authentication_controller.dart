import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:top5/app/modules/authentication/views/password_change_view.dart';
import 'package:top5/app/modules/authentication/views/sign_up_form2_view.dart';
import 'package:top5/app/modules/dashboard/views/dashboard_view.dart';
import 'package:top5/app/modules/subscription/views/subscription_view.dart';

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
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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

  // ===== LOGIN =====
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

        // 🔐 Save Remember Me choice for future app launches
        await _storage.write(
          key: 'remember_me',
          value: rememberMeController.value ? 'true' : 'false',
        );

        print(':::::::::responseBody:::::::::$responseBody');
        print(':::::::::accessToken:::::::::$accessToken');
        print(':::::::::refreshToken:::::::::$refreshToken');

        await _storage.write(key: 'account_type', value: 'email');

        Get.snackbar('Success', 'Logged in Successfully');

        // Decide where to go based on current plan
        await _checkUserSubscriptionAndNavigate();
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar(
          'Login failed',
          responseBody['message'] ?? 'Please use Correct UserName and Password',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ===== SIGN UP (SEND OTP) =====
  Future<void> signUpSendOtp(BuildContext context, String email) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.signUpSendOtp(email);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['message']),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Get.snackbar(responseBody['status'], responseBody['message']);

        Get.to(() => MailVerificationView(email: email));
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar(
          'Sign up failed',
          responseBody['message'] ?? 'Please use Correct email',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpOtpVerification(String email, String otp) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.signUpOtpVerification(email, otp);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        clear();

        Get.snackbar(responseBody['status'], responseBody['message']);

        Get.to(() => SignUpForm2View(email: email));
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar(
          'Sign up failed',
          responseBody['message'] ?? 'Please use Correct email',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ===== SIGN UP (FINAL) =====
  Future<void> signUp(
      String fullName,
      String email,
      String password,
      String confirmPassword,
      ) async {
    isLoading.value = true;

    try {
      final http.Response response =
      await _service.signUp(fullName, email, password, confirmPassword);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final accessToken = responseBody['access'];
        final refreshToken = responseBody['refresh'];

        await storeTokens(accessToken, refreshToken);

        // 🟢 For new sign ups we always remember the user
        await _storage.write(key: 'remember_me', value: 'true');
        await _storage.write(key: 'account_type', value: 'email');

        print(':::::::::responseBody:::::::::$responseBody');
        print(':::::::::accessToken:::::::::$accessToken');
        print(':::::::::refreshToken:::::::::$refreshToken');

        Get.snackbar('Success', 'Account created Successfully');

        await _checkUserSubscriptionAndNavigate();
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar(
          'Sign up failed',
          responseBody['message'] ?? 'Please use Correct password',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ===== GOOGLE SIGN IN =====
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> googleSignIn() async {
    isLoading.value = true;

    try {
      UserCredential userCredential = await signInWithGoogle();
      final user = userCredential.user;

      print(user);

      if (user == null || user.email == null) {
        Get.snackbar('Error', "Google sign-in failed. Please try again.");
        return;
      }

      final http.Response response = await _service.socialSignIn(
        user.email ?? '',
        user.displayName ?? '',
        'google',
      );

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final accessToken = responseBody['token']['access'];
        final refreshToken = responseBody['token']['refresh'];

        await storeTokens(accessToken, refreshToken);

        // 🟢 Keep Google users logged in by default
        await _storage.write(key: 'remember_me', value: 'true');
        await _storage.write(key: 'account_type', value: 'google');
        // await _storage.write(key: 'google_photo_url', value: user.photoURL)

        print(':::::::::responseBody:::::::::$responseBody');
        print(':::::::::accessToken:::::::::$accessToken');
        print(':::::::::refreshToken:::::::::$refreshToken');

        Get.snackbar('Success', 'Google sign in successful');

        await _checkUserSubscriptionAndNavigate();
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar(
          'Google Sign In Failed',
          responseBody['message'] ?? 'Please use correct gmail',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> appleSignIn() async {
    isLoading.value = true;

    try {
      // ── 1. Perform Sign in with Apple ──
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // Optional: nonce for security (recommended)
        // nonce: generateNonce(),  // implement if you want replay protection
      );

      print('Rubaid');

      // ── 2. Create OAuth credential for Firebase ──
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        // accessToken: appleCredential.authorizationCode,   // usually not needed
        // rawNonce: yourNonceIfUsed,
      );

      // ── 3. Sign in to Firebase ──
      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception("Apple sign-in failed - no user returned");
      }

      // Optional: Update display name on first sign-in (Apple only gives name once)
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        String fullName = [
          appleCredential.givenName ?? '',
          appleCredential.familyName ?? ''
        ].join(' ').trim();

        if (fullName.isNotEmpty) {
          await firebaseUser.updateDisplayName(fullName);
        }
      }

      // ── 4. Handle your app logic (similar to Google) ──
      // You now have firebaseUser.uid, firebaseUser.email, firebaseUser.displayName, etc.

      print('Apple Sign-In Success: ${firebaseUser.uid} | ${firebaseUser.email}');

      // Decide what to do next:
      // Option A: Auto-create/log in user in your backend using Firebase UID
      // Option B: Call your own backend to create/sync user (recommended)

      await _handleSuccessfulSocialLogin(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        fullName: firebaseUser.displayName ?? 'Apple User',
        provider: 'apple',
      );

      Get.snackbar('Success', 'Signed in with Apple');

      await _checkUserSubscriptionAndNavigate();  // your existing method

    } on SignInWithAppleAuthorizationException catch (e) {
      // User canceled or other Apple error
      print(e);
      if (e.code != AuthorizationErrorCode.canceled) {
        Get.snackbar('Apple Sign-In Error', e.message ?? 'Failed to sign in');
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      String message = 'Authentication failed';
      if (e.code == 'account-exists-with-different-credential') {
        message = 'Account exists with different sign-in method';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Apple sign-in is not enabled in Firebase';
      }
      Get.snackbar('Error', message);
      print('Firebase Apple Error: ${e.code} - ${e.message}');
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      print('Apple Sign-In Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleSuccessfulSocialLogin({
    required String uid,
    required String email,
    required String fullName,
    required String provider,
  }) async {
    try {
      // Option: Call your backend to create / sync user
      final response = await _service.socialSignIn(
        email,
        fullName,
        provider,  // 'apple'
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);

        // Assuming your backend returns access/refresh tokens
        final accessToken = body['access'] ?? body['token']?['access'];
        final refreshToken = body['refresh'] ?? body['token']?['refresh'];

        if (accessToken != null && refreshToken != null) {
          await storeTokens(accessToken, refreshToken);
          await _storage.write(key: 'account_type', value: provider);
          await _storage.write(key: 'remember_me', value: 'true');
        }
      } else {
        // Handle backend error
        print('Backend sync failed: ${response.body}');
      }

      // Fallback: store Firebase UID or something
      await _storage.write(key: 'firebase_uid', value: uid);
    } catch (e) {
      print('Backend sync error: $e');
    }
  }

  // ===== FORGOT / RESET PASSWORD =====
  Future<void> resetPasswordSendOtp(String email) async {
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

        Get.to(() => OtpVerificationsView(email: email));
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar(
          'Reset password failed',
          responseBody['message'] ?? 'Please use Correct email',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPasswordOtpVerification(String email, String otp) async {
    isLoading.value = true;

    try {
      final http.Response response =
      await _service.resetPasswordOtpVerification(email, otp);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        clear();

        Get.snackbar(responseBody['status'], responseBody['message']);

        Get.to(() => CreateNewPasswordView(email: email));
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar(
          'Reset password failed',
          responseBody['message'] ?? 'Please use Correct email',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(
      String email,
      String password,
      String confirmPassword,
      ) async {
    isLoading.value = true;

    try {
      final http.Response response =
      await _service.resetPassword(email, password, confirmPassword);

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
        Get.snackbar(
          'Reset password failed',
          responseBody['message'] ?? 'Please use Correct password',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ===== SUBSCRIPTION CHECK =====
  Future<void> _checkUserSubscriptionAndNavigate() async {
    try {
      final response = await _service.getCurrentActivePlan();

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;

        final planDetails = body['plan_details'] as Map<String, dynamic>?;

        final String planName =
        (planDetails?['name'] ?? '').toString().toUpperCase();

        await _storage.write(key: 'current_plan', value: planName);

        if (planName == 'BASIC' || planName == 'PREMIUM') {
          Get.offAll(() => const DashboardView());
          return;
        }

        Get.offAll(() => const SubscriptionView());
      } else {
        print(
            'Failed to fetch current plan: ${response.statusCode} ${response.body}');
        Get.offAll(() => const SubscriptionView());
      }
    } catch (e) {
      print('Error checking current plan: $e');
      Get.offAll(() => const SubscriptionView());
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
  void updateOTP(int index, String value) {
    if (value.isEmpty) {
      otpList[index] = '';
      otpControllers[index].text = '';
      return;
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      _applyPastedDigits(index, digits);
      return;
    }

    final ch = digits[0];
    otpList[index] = ch;
    _setControllerText(index, ch);

    if (index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
      otpControllers[index + 1].selection =
          TextSelection.collapsed(offset: otpControllers[index + 1].text.length);
    } else {
      focusNodes[index].unfocus();
    }
  }

  void handleBackspaceWhenEmpty(int index) {
    if (index > 0) {
      focusNodes[index - 1].requestFocus();
      otpControllers[index - 1].selection =
          TextSelection.collapsed(offset: otpControllers[index - 1].text.length);
    }
  }

  void clear() {
    for (var i = 0; i < otpControllers.length; i++) {
      otpControllers[i].clear();
      otpList[i] = '';
    }
    if (focusNodes.isNotEmpty) {
      focusNodes.first.requestFocus();
    }
  }

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
    otpControllers[index]
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
  }
}
