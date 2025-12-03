import 'package:flutter/animation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:top5/app/modules/dashboard/views/dashboard_view.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late final AnimationController anim;
  late final Animation<double> fade;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
    // wait for animation a bit
    await Future.delayed(const Duration(seconds: 2));

    final bool isLoggedIn = await _isUserLoggedIn();

    if (isLoggedIn) {
      // ✅ User previously logged in (Sign up OR Sign in with Remember Me)
      Get.offAll(() => const DashboardView());
    } else {
      // ❌ Not logged in or Remember Me was off → start from first (onboarding/sign in)
      Get.offAllNamed('/onboarding');
    }
  }

  Future<bool> _isUserLoggedIn() async {
    try {
      final rememberMe = await _storage.read(key: 'remember_me');
      final accessToken = await _storage.read(key: 'access_token');

      // Only auto-login if:
      // 1) remember_me is true (login OR sign-up/Google with remember)
      // 2) We still have a stored access token
      if (rememberMe == 'true' &&
          accessToken != null &&
          accessToken.isNotEmpty) {
        return true;
      }
    } catch (e) {
      print('Error while checking login state in SplashController: $e');
    }
    return false;
  }

  @override
  void onClose() {
    anim.dispose();
    super.onClose();
  }
}
