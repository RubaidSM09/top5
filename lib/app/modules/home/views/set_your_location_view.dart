import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/home/controllers/home_controller.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';
import 'package:top5/common/widgets/custom_button.dart';
import 'package:top5/common/widgets/custom_text_field.dart';

import '../../../secrets/secrets.dart';
import 'google_map_webview.dart';

class SetYourLocationView extends GetView<HomeController> {
  const SetYourLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    // local state: the current center from WebView
    final RxDouble pickedLat = (controller.manualLat.value ?? 23.7809063).obs;
    final RxDouble pickedLng = (controller.manualLng.value ?? 90.4075592).obs;
    final RxString pickedAddress = ''.obs;

    // user can type here to search; when submitted we push into the webview
    final TextEditingController addressCtl = TextEditingController();
    final RxString searchAddress = ''.obs; // triggers geocode in the WebView

    // keep textfield in sync with pickedAddress (from reverse geocode)
    ever<String>(pickedAddress, (addr) {
      if (addr.isNotEmpty && addressCtl.text != addr) {
        addressCtl.text = addr;
      }
    });

    void submitSearch() {
      final q = addressCtl.text.trim();
      if (q.isEmpty) return;
      searchAddress.value = q; // this re-builds the WebView with a new searchAddress, which geocodes and centers
    }

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              // --- GoogleMapPickerWebView with search & reverse geocode ---
              Positioned.fill(
                child: GoogleMapPickerWebView(
                  googleApiKey: googleApiKey,
                  initialLat: controller.manualLat.value ?? 23.7809063,
                  initialLng: controller.manualLng.value ?? 90.4075592,
                  searchAddress: searchAddress.value.isEmpty ? null : searchAddress.value,
                  onCenterChanged: (latLng) {
                    pickedLat.value = latLng.latitude;
                    pickedLng.value = latLng.longitude;
                  },
                  onAddressResolved: (addr) {
                    pickedAddress.value = addr;
                  },
                ),
              ),

              // --- Your custom center pin as a Flutter overlay (unchanged) ---
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: SizedBox(
                      width: 28, height: 28,
                      child: Image.asset('assets/images/home/location_pointer.png'),
                    ),
                  ),
                ),
              ),

              // Back button (unchanged)
              Positioned(
                top: 33.h,
                left: 20.w,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: AppColors.serviceBlack,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: AppColors.serviceWhite, size: 18.r),
                  ),
                ),
              ),

              // Bottom Sheet (UI unchanged except the text field enabled and showing address)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12.r),
                      topLeft: Radius.circular(12.r),
                    ),
                    color: AppColors.homeBlue,
                  ),
                  child: Column(
                    spacing: 24.h,
                    children: [
                      Column(
                        spacing: 14.h,
                        children: [
                          Text('Set your location',
                            style: h2.copyWith(color: AppColors.homeWhite, fontSize: 20.sp),
                          ),
                          Text('Drag map or search to move pin',
                            style: h4.copyWith(color: AppColors.homeWhite, fontSize: 16.sp),
                          ),
                        ],
                      ),

                      Divider(color: AppColors.homeWhite),

                      Column(
                        spacing: 12.h,
                        children: [
                          // Address-enabled search bar (ENABLED now)
                          CustomTextField(
                            hintText: pickedAddress.value.isEmpty
                                ? 'Search by address (e.g., Banani 11, Dhaka)'
                                : pickedAddress.value,
                            prefixIcon: 'assets/images/home/search.png',
                            color: AppColors.homeWhite,
                            borderRadius: 50,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                            isObscureText: false.obs,
                            controller: addressCtl,
                            onSubmitted: (_) => submitSearch(),
                            onPrefixTap: submitSearch, // if your CustomTextField supports it; if not, keep onSubmitted
                            enabled: true, // ✅ enabled now
                          ),

                          // Confirm -> tell HomeController to override and refresh
                          CustomButton(
                            text: 'Confirm Destination',
                            onTap: () async {
                              await controller.overrideLocationAndRefresh(
                                pickedLat.value, pickedLng.value,
                              );
                              Get.back(); // return to previous screen
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
