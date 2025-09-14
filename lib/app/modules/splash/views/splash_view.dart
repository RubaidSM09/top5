import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/common/app_colors.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBlue,
      body: SafeArea(
        child: FadeTransition(
          opacity: controller.fade,
          child: Center(
            child: SvgPicture.asset(
              'assets/images/splash/top5_logo.svg',
            ),
          ),
        ),
      ),
    );
  }
}
