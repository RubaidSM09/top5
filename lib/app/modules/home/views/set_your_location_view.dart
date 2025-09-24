import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/home/controllers/home_controller.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/custom_fonts.dart';
import 'package:top5/common/widgets/custom_button.dart';
import 'package:top5/common/widgets/custom_text_field.dart';

class SetYourLocationView extends GetView<HomeController> {
  const SetYourLocationView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    controller.isMapClicked.value = !controller.isMapClicked.value;
                  },
                  child: Image.asset(
                    'assets/images/home/set_your_location_map.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

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
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.serviceWhite,
                      size: 18.r,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: controller.isMapClicked.value ? 281.h : 467.h,
                left: controller.isMapClicked.value ? 201.w : 181.w,
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/home/location_pointer.png',
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 0.h,
                left: 0.w,
                right: 0.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 32.h,
                  ),
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
                          Text(
                            'Set your location',
                            style: h2.copyWith(
                              color: AppColors.homeWhite,
                              fontSize: 20.sp,
                            ),
                          ),

                          Text(
                            'Drag map to move pin',
                            style: h4.copyWith(
                              color: AppColors.homeWhite,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),

                      Divider(color: AppColors.homeWhite,),

                      Column(
                        spacing: 12.h,
                        children: [
                          CustomTextField(
                            hintText: controller.isMapClicked.value ? 'Bella Italia' : 'Where to?',
                            prefixIcon: 'assets/images/home/search.png',
                            color: AppColors.homeWhite,
                            borderRadius: 50,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 10.h),
                            isObscureText: false.obs,
                          ),

                          CustomButton(
                            text: controller.isMapClicked.value ? 'Confirm Destination' : 'Search Destination',
                            onTap: () {},
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
