import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:top5/app/modules/dashboard/views/dashboard_view.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';
import 'package:top5/common/widgets/custom_button.dart';

import '../controllers/subscription_controller.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SubscriptionController());

    final screenHeight = MediaQuery.of(context).size.height;
    final paddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 32.h),

              Text(
                'Explore Our Plans',
                style: h2.copyWith(
                  color: AppColors.authenticationBlack,
                  fontSize: 36.sp,
                ),
              ),

              SizedBox(height: 32.h),

              Container(
                // make the blue card at least almost full-screen tall
                constraints: BoxConstraints(
                  minHeight: screenHeight - paddingTop - 115.h,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.r),
                    topLeft: Radius.circular(30.r),
                  ),
                  color: AppColors.splashBlue,
                  border: Border.all(
                    color: AppColors.subscriptionBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.subscriptionBoxShadowColor.withAlpha(8),
                      blurRadius: 6.r,
                      spreadRadius: -2.r,
                      offset: Offset(0.w, 4.h),
                    ),
                    BoxShadow(
                      color:
                      AppColors.subscriptionBoxShadowColor.withAlpha(20),
                      blurRadius: 16.r,
                      spreadRadius: -4.r,
                      offset: Offset(0.w, 12.h),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 32.h),
                  child: Column(
                    children: [
                      // swipable plan content
                      GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity == null) return;
                          if (details.primaryVelocity! < 0) {
                            controller.next(); // swipe left → next
                          } else if (details.primaryVelocity! > 0) {
                            controller.back(); // swipe right → back
                          }
                        },
                        child: Obx(() {
                          if (controller.isLoading.value &&
                              controller.subscriptionPlans.isEmpty) {
                            return SizedBox(
                              height: 200.h,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (controller.subscriptionPlans.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 40.h,
                              ),
                              child: Text(
                                'No subscription plans available.',
                                textAlign: TextAlign.center,
                                style: h4.copyWith(
                                  color: AppColors.authenticationWhite,
                                  fontSize: 16.sp,
                                ),
                              ),
                            );
                          }

                          final plan = controller
                              .subscriptionPlans[controller.current.value];

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: PlanDetails(
                              key: ValueKey(plan['plan_name']),
                              subscriptionPlan: plan,
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 32.h),

                      // Get started button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22.w),
                        child: Obx(() {
                          final plans = controller.subscriptionPlans;
                          final bool showLoader =
                              controller.isLoading.value && plans.isNotEmpty;

                          // Default text
                          String buttonText = 'Get started';

                          if (showLoader) {
                            buttonText = 'Processing...';
                          } else if (plans.isNotEmpty &&
                              controller.hasActivePaidPlan.value &&
                              controller.activePlanId.value != null) {
                            final currentPlan = plans[controller.current.value];
                            final int? currentPlanId = currentPlan['id'] as int?;

                            // 🔁 If this card's plan id == active plan id → show Renew
                            if (currentPlanId != null &&
                                currentPlanId == controller.activePlanId.value) {
                              buttonText = 'Renew';
                            }
                          }

                          return CustomButton(
                            text: buttonText,
                            onTap: showLoader
                                ? null
                                : () {
                              final plans = controller.subscriptionPlans;
                              if (plans.isEmpty) return;

                              final currentPlan = plans[controller.current.value];
                              final String name =
                                  (currentPlan['plan_name'] as String?)
                                      ?.toUpperCase() ??
                                      '';

                              // FREE → go to dashboard (unchanged)
                              if (name == 'FREE') {
                                Get.offAll(() => DashboardView());
                              } else {
                                // BASIC / PREMIUM → Stripe checkout (new or renew)
                                controller.checkoutCurrentPlan();
                              }
                            },
                          );
                        }),
                      ),

                      SizedBox(height: 22.5.h),

                      // Dots
                      Obx(() {
                        final length = controller.subscriptionPlans.length;

                        return Row(
                          spacing: 16.w,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            length,
                                (dotIndex) => Container(
                              width: 14.w,
                              height: 14.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.current.value == dotIndex
                                    ? AppColors.homeGreen
                                    : AppColors.subscriptionInactiveContainer,
                              ),
                            ),
                          ),
                        );
                      }),

                      SizedBox(height: 22.5.h),

                      // Back / Next
                      Obx(() {
                        final length = controller.subscriptionPlans.length;

                        return Padding(
                          padding: EdgeInsets.only(
                            left: 22.w,
                            right: 22.w,
                          ),
                          child: Row(
                            spacing: 32.w,
                            children: [
                              if (length > 0 && controller.current.value > 0)
                                Expanded(
                                  child: CustomButton(
                                    color: AppColors.authenticationWhite,
                                    borderColor: AppColors.authenticationWhite,
                                    text: 'Back',
                                    textColor: AppColors.homeGreen,
                                    textSize: 18.sp,
                                    onTap: controller.back,
                                  ),
                                ),
                              if (length > 0 &&
                                  controller.current.value < length - 1)
                                Expanded(
                                  child: CustomButton(
                                    color: AppColors.homeGreen,
                                    borderColor: AppColors.homeGreen,
                                    text: 'Next',
                                    textColor: AppColors.authenticationWhite,
                                    textSize: 18.sp,
                                    onTap: controller.next,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlanDetails extends StatelessWidget {
  final Map<String, dynamic> subscriptionPlan;

  const PlanDetails({
    required this.subscriptionPlan,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> features =
    List<String>.from(subscriptionPlan['features'] as List);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 40.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subscriptionPlan['plan_name'],
                style: h4.copyWith(
                  color: AppColors.authenticationWhite,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '€${subscriptionPlan['cost_amount']}${subscriptionPlan['cost_type'] == 'monthly' ? '/mth' : subscriptionPlan['cost_type'] == 'annually' ? '/year' : ''}',
                    style: h2.copyWith(
                      color: AppColors.authenticationWhite,
                      fontSize: 40.sp,
                    ),
                  ),
                  if (subscriptionPlan['is_most_popular'] == true)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.authenticationWhite,
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      child: Text(
                        'Most Popular',
                        style: h3.copyWith(
                          color: AppColors.homeBlack,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 21.w,
            right: 21.w,
            top: 32.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.h,
            children: features
                .map<Widget>(
                  (feature) => SubscriptionPlanFeature(
                feature: feature,
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class SubscriptionPlanFeature extends StatelessWidget {
  final String feature;

  const SubscriptionPlanFeature({
    required this.feature,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12.w,
      children: [
        Container(
          padding: EdgeInsets.all(6.735.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.authenticationWhite,
          ),
          child: SvgPicture.asset(
            'assets/images/subscription/tick_mark.svg',
          ),
        ),
        SizedBox(
          width: 320.w,
          child: Text(
            feature,
            style: h4.copyWith(
              color: AppColors.authenticationWhite,
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }
}

/// GetX controller for Stripe checkout WebView
class CheckoutController extends GetxController {
  final String checkoutUrl;
  final String successUrlPrefix;

  CheckoutController({
    required this.checkoutUrl,
    required this.successUrlPrefix,
  });

  late final WebViewController webViewController;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => isLoading.value = true,
          onPageFinished: (_) => isLoading.value = false,
          onNavigationRequest: (NavigationRequest request) {
            // Detect success redirect
            if (request.url.startsWith(successUrlPrefix)) {
              // Payment successful → navigate to Dashboard and clear stack
              Get.offAll(() => DashboardView());
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(checkoutUrl));
  }
}

/// WebView screen for Stripe checkout
class SubscriptionCheckoutView extends StatelessWidget {
  final String checkoutUrl;
  final String successUrlPrefix;

  const SubscriptionCheckoutView({
    super.key,
    required this.checkoutUrl,
    required this.successUrlPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final CheckoutController controller = Get.put(
      CheckoutController(
        checkoutUrl: checkoutUrl,
        successUrlPrefix: successUrlPrefix,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller.webViewController,
          ),
          Obx(() {
            return controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
