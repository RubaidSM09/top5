import 'dart:convert';

import 'package:get/get.dart';
import 'package:top5/app/data/model/all_subscription_list.dart';
import 'package:top5/app/data/services/api_services.dart';
import 'package:top5/app/modules/subscription/views/subscription_view.dart';

class SubscriptionController extends GetxController {
  final current = 0.obs;
  final isLoading = false.obs;

  final ApiService _apiService = ApiService();

  /// This drives your UI. Same structure as before, but now populated from API.
  RxList<Map<String, dynamic>> subscriptionPlans =
      <Map<String, dynamic>>[].obs;

  /// Active paid plan from /subscription/user/current-active-plan/
  final RxBool hasActivePaidPlan = false.obs;
  final Rxn<int> activePlanId = Rxn<int>(); // backend's plan id

  /// Change this to whatever `success_url` your backend is using for Stripe.
  static const String stripeSuccessUrlPrefix =
      'http://0.0.0.0:8080/success'; // TODO: set real success URL

  @override
  void onInit() {
    super.onInit();
    fetchSubscriptionPlans();
    fetchCurrentActivePlan();
  }

  Future<void> fetchSubscriptionPlans() async {
    try {
      isLoading.value = true;

      final response = await _apiService.getSubscriptionList();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody =
        jsonDecode(response.body) as Map<String, dynamic>;

        final all = AllSubscriptionList.fromJson(jsonBody);

        final List<Map<String, dynamic>> plans = [];

        if (all.data != null) {
          for (final Data d in all.data!) {
            // Only active plans
            if (d.status != true) continue;

            // Collect non-null, non-empty features
            final List<String> features = [];
            final List<String?> rawFeatures = [
              d.feature1,
              d.feature2,
              d.feature3,
              d.feature4,
              d.feature5,
              d.feature6,
              d.feature7,
              d.feature8,
              d.feature9,
              d.feature10,
            ];

            for (final f in rawFeatures) {
              if (f != null && f.trim().isNotEmpty) {
                features.add(f.trim());
              }
            }

            // Map duration_days to cost_type like before
            String costType = '';
            if (d.durationDays == 30) {
              costType = 'monthly';
            } else if (d.durationDays == 365) {
              costType = 'annually';
            } else {
              costType = '';
            }

            // Decide "most popular" – BASIC
            final bool isMostPopular = (d.name ?? '').toUpperCase() == 'BASIC';

            plans.add({
              'plan_name': d.name ?? '',
              'cost_amount': double.tryParse(d.price ?? '0') ?? 0.0,
              'cost_type': costType,
              'is_most_popular': isMostPopular,
              'features': features,
              // extra info if you need later
              'id': d.id,
              'duration_days': d.durationDays,
              'place_limit': d.placeLimit,
              'ai_limit': d.aiLimit,
              'weather_limit': d.weatherLimit,
            });
          }
        }

        subscriptionPlans.assignAll(plans);

        if (subscriptionPlans.isNotEmpty) {
          current.value = 0;
        }
      } else {
        print('Failed to fetch subscription list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching subscription list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCurrentActivePlan() async {
    try {
      final response = await _apiService.getCurrentActivePlan();

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;

        // e.g. "paid" or maybe something else for free
        final String planType = body['plan']?.toString() ?? '';

        final Map<String, dynamic>? data =
        body['data'] as Map<String, dynamic>?;
        final Map<String, dynamic>? details =
        body['plan_details'] as Map<String, dynamic>?;

        final bool isActive = data?['is_active'] == true;

        int? planId;
        if (details?['id'] is int) {
          planId = details?['id'] as int;
        } else if (details?['id'] != null) {
          planId = int.tryParse(details!['id'].toString());
        }

        if (planType == 'paid' && isActive && planId != null) {
          hasActivePaidPlan.value = true;
          activePlanId.value = planId; // 👈 e.g. 2 for BASIC
        } else {
          hasActivePaidPlan.value = false;
          activePlanId.value = null;
        }
      } else {
        // No active subscription or error → treat as free user
        hasActivePaidPlan.value = false;
        activePlanId.value = null;
      }
    } catch (e) {
      // On error, also treat as free
      hasActivePaidPlan.value = false;
      activePlanId.value = null;
      print('Error fetching current active plan: $e');
    }
  }

  void next() {
    if (subscriptionPlans.isEmpty) return;
    if (current.value < subscriptionPlans.length - 1) {
      current.value++;
    }
  }

  void back() {
    if (subscriptionPlans.isEmpty) return;
    if (current.value > 0) {
      current.value--;
    }
  }

  /// Called when Get started is pressed for BASIC/PREMIUM.
  Future<void> checkoutCurrentPlan() async {
    if (subscriptionPlans.isEmpty) return;

    final plan = subscriptionPlans[current.value];
    final int? planId = plan['id'] as int?;

    if (planId == null) {
      print('No plan id found for current plan');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _apiService.subscriptionCheckout(planId);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;

        final String? checkoutUrl = body['checkout_url'] as String?;

        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          Get.to(() => SubscriptionCheckoutView(
            checkoutUrl: checkoutUrl,
            successUrlPrefix: stripeSuccessUrlPrefix,
          ));
        } else {
          print('checkout_url not found in response');
        }
      } else {
        print(
            'Failed to create checkout session: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error during checkout: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
