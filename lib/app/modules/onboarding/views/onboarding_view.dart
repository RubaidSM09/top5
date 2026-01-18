import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:top5/app/modules/authentication/views/sign_up_view.dart';
import 'package:video_player/video_player.dart';

import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';
import 'package:top5/common/widgets/custom_button.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  final bool? isProfile;

  const OnboardingView({
    this.isProfile = false,
    super.key
  });

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return 'Step 1 : Choose a category';
      case 1:
        return 'Step 2 : Choose a Filter';
      default:
        return 'Step 3 : Search & Result View';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authenticationBlue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(50.r),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/images/authentication/top5_logo_horizontal.svg',
                ),
                SizedBox(height: 43.08.h),

                Text(
                  'Quick and Simple Guide',
                  style: h2.copyWith(
                    color: AppColors.authenticationGreen,
                    fontSize: 28.sp,
                  ),
                ),
                SizedBox(height: 20.h),

                // STEP TEXT with fade + slide
                Obx(() {
                  final step = controller.currentStep.value;
                  return Row(
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) {
                            final inOffset =
                            Tween<Offset>(begin: const Offset(-0.25, 0), end: Offset.zero)
                                .animate(anim);
                            return FadeTransition(
                              opacity: anim,
                              child: SlideTransition(position: inOffset, child: child),
                            );
                          },
                          child: Text(
                            _stepTitle(step),
                            key: ValueKey(step),
                            style: h4.copyWith(
                              color: AppColors.authenticationWhite,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                SizedBox(height: 45.h),

                // PHONE FRAME + VIDEO inside an Obx that listens to Rxn<VideoPlayerController>
                Obx(() {
                  final VideoPlayerController? vp = controller.player.value;
                  if (vp == null || !vp.value.isInitialized) {
                    return SizedBox(
                      height: 420.h,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  return PhoneFrame(
                    child: AspectRatio(
                      aspectRatio: vp.value.aspectRatio == 0 ? 9 / 19.5 : vp.value.aspectRatio,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28.r),
                        child: VideoPlayer(vp),
                      ),
                    ),
                  );
                }),

                SizedBox(height: 35.h),

                if(!isProfile!)
                  CustomButton(
                    text: 'Skip',
                    onTap: () => Get.offAll(SignUpView()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple iPhone-style frame (matches your mock)
class PhoneFrame extends StatelessWidget {
  final Widget child;
  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 230.w,
        padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1B25),
          borderRadius: BorderRadius.circular(36.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.5), width: 2),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 18.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: Container(color: Colors.black, child: child),
              ),
            ),
            Container(
              width: 80.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
