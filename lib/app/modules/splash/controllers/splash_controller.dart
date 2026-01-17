import 'dart:convert';

import 'package:flutter/animation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:top5/app/modules/dashboard/views/dashboard_view.dart';

import '../../../data/services/api_services.dart'; // <-- update path based on your project

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late final AnimationController anim;
  late final Animation<double> fade;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _api = ApiService();

  @override
  void onInit() {
    super.onInit();

    anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    fade = CurvedAnimation(parent: anim, curve: Curves.easeIn);
    anim.forward();

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: 2));

    final bool isLoggedIn = await _isUserLoggedIn();

    if (isLoggedIn) {
      Get.offAll(() => const DashboardView());
    } else {
      Get.offAllNamed('/onboarding');
    }
  }

  Future<bool> _isUserLoggedIn() async {
    try {
      final rememberMe = await _storage.read(key: 'remember_me');
      if (rememberMe != 'true') return false;

      // Must have refresh token to safely re-login after app restart
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) return false;

      // If access token exists, we can try to use it as-is (optional),
      // but safest is: refresh access token at app start.
      final refreshResp = await _api.refreshAccessToken(refreshToken);

      if (refreshResp.statusCode == 200) {
        final data = jsonDecode(refreshResp.body);

        final newAccess = (data['access'] ?? '').toString();
        if (newAccess.isEmpty) {
          // unexpected response
          await _clearAuthStorage();
          return false;
        }

        await _storage.write(key: 'access_token', value: newAccess);
        return true;
      }

      // If refresh failed, check server message and treat as logged out
      // Example:
      // {"detail":"Token is blacklisted","code":"token_not_valid"}
      await _clearAuthStorage();
      return false;
    } catch (e) {
      print('Error while checking login state in SplashController: $e');
      await _clearAuthStorage();
      return false;
    }
  }

  Future<void> _clearAuthStorage() async {
    try {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'remember_me');
    } catch (_) {}
  }

  @override
  void onClose() {
    anim.dispose();
    super.onClose();
  }
}
