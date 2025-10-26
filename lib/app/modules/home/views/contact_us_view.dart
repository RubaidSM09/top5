import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/common/app_colors.dart';
import 'package:top5/common/widgets/custom_button.dart';

import '../../../../common/custom_fonts.dart';
import '../controllers/home_controller.dart';

class ContactUsView extends GetView<HomeController> {
  final String placeId; // Add placeId to pass from DetailsView
  final double destLat; // Add for directions
  final double destLng; // Add for directions
  final String title; // Add for display
  final String image; // Add for display
  final double rating; // Add for display
  final String status; // Add for display
  final String distance; // Add for display
  final double time; // Add for display
  final String type; // Add for display
  final List<dynamic> reasons; // Add for display

  const ContactUsView({
    required this.placeId,
    required this.destLat,
    required this.destLng,
    required this.title,
    required this.image,
    required this.rating,
    required this.status,
    required this.distance,
    required this.time,
    required this.type,
    required this.reasons,
    super.key,
  });

  Future<void> _toggleReservation() async {
    final c = Get.find<HomeController>();
    final activityType = c.isPlaceReserved(placeId) ? 'reservation-delete' : 'reservation';

    await c.submitActionPlaces(placeId, activityType);
    await c.fetchReservationPlaces(); // Refresh reservation places list
    await c.fetchReservationCount();
    Get.snackbar(
      'Reservation',
      c.isPlaceReserved(placeId) ? 'Place added to reservation list' : 'Place removed from reservation list',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    return Dialog(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 54.w, vertical: 24.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: AppColors.serviceWhite,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us'.tr,
              style: h1.copyWith(
                fontSize: 20.sp,
                color: AppColors.serviceBlack,
              ),
            ),
            SizedBox(height: 13.h),
            Text(
              c.isPlaceReserved(placeId) ? 'You have already reserved this place'.tr : 'Your reservation is just a call away!'.tr,
              style: h4.copyWith(
                fontSize: 16.sp,
                color: AppColors.serviceGreen,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              spacing: 6.w,
              children: [
                SvgPicture.asset('assets/images/home/contact_no.svg'),
                Text(
                  '+1 123456789',
                  style: h4.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.serviceGray,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            Obx(() => CustomButton(
              text: c.isPlaceReserved(placeId) ? 'Remove from Reservation'.tr : 'Save to Reservation'.tr,
              textSize: 16.sp,
              color: c.isPlaceReserved(placeId) ? AppColors.profileDeleteButtonTextColor : AppColors.authenticationGreen,
              onTap: _toggleReservation,
            )),
          ],
        ),
      ),
    );
  }
}
