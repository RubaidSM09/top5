import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/profile/views/personal_info_view.dart';
import 'package:top5/app/modules/profile/views/remove_reservation_list_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/views/details_view.dart';
import '../controllers/profile_controller.dart';

class ReservationListView extends GetView {
  const ReservationListView({super.key});
  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.put(ProfileController());
    HomeController homeController = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ProfileAppBar(appBarTitle: 'Reservation List'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: SingleChildScrollView(
            child: Column(
              spacing: 16.h,
              children: [
                ReservationListCard(
                  serialNo: 1,
                  title: 'Trattoria Bella Vita',
                  rating: 4.5,
                  image:
                  'assets/images/profile/trattoria_bella_vita.jpg',
                  isPromo: false,
                  status: 'Open',
                  distance: profileController.selectedDistanceUnit[0].value ? '900 m' : "${homeController.convertToMiles('900 m').toStringAsFixed(2)} miles",
                  time: 20,
                  type: 'Italian',
                  reasons: [
                    'Wood-fired pizza, 1k+ reviews',
                    '6-min walk, sunny terrace',
                  ],
                  isSaved: true.obs,
                  selectedLocations: homeController.selectedLocations,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class ReservationListCard extends StatelessWidget {
  final int serialNo;
  final String title;
  final double rating;
  final String image;
  final bool isPromo;
  final String status;
  final String distance;
  final double time;
  final String type;
  final List<String> reasons;
  final RxBool isSaved;
  final RxList<RxBool> selectedLocations;

  const ReservationListCard({
    required this.serialNo,
    required this.title,
    required this.rating,
    required this.image,
    required this.isPromo,
    required this.status,
    required this.distance,
    required this.time,
    required this.type,
    required this.reasons,
    required this.isSaved,
    required this.selectedLocations,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          DetailsView(
            serialNo: serialNo,
            title: title,
            rating: rating,
            image: image,
            isPromo: isPromo,
            status: status,
            distance: distance,
            time: time,
            type: type,
            reasons: reasons,
            isSaved: isSaved,
            placeId: '',
            destLat: 0,
            destLng: 0,
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 17.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.serviceGray, width: 0.5.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        left: 8.w,
                        right: 7.w,
                        top: 5.h,
                        bottom: 42.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        image: DecorationImage(
                          image: AssetImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isPromo ? AppColors.servicePromoGreen : AppColors.top5Transparent,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          'Promo',
                          style: h4.copyWith(
                            color: isPromo ? AppColors.serviceWhite : AppColors.top5Transparent,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8.h,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: h2.copyWith(
                                color: AppColors.serviceBlack,
                                fontSize: 16.sp,
                              ),
                            ),

                            SizedBox(width: 16.w),

                            Icon(
                              Icons.star,
                              size: 14.r,
                              color: AppColors.serviceGreen,
                            ),

                            SizedBox(width: 4.w),

                            Text(
                              '$rating',
                              style: h2.copyWith(
                                color: AppColors.top5Black,
                                fontSize: 14.sp,
                              ),
                            ),

                            SizedBox(width: 10.w),

                            Text(
                              '€€.',
                              style: h2.copyWith(
                                color: AppColors.top5Black,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          width: 255.w,
                          child: Row(
                            spacing: 10.w,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.serviceSearchBg,
                                  borderRadius: BorderRadius.circular(50.r),
                                ),
                                child: Text(
                                  status,
                                  style: h3.copyWith(
                                    color: AppColors.servicePromoGreen,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),

                              Text(
                                '$distance / ${time.toStringAsFixed(0)} min walk',
                                style: h4.copyWith(
                                  color: AppColors.serviceGray,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16.h,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      text: 'Directions',
                      prefixIcon: 'assets/images/home/directions.svg',
                      paddingLeft: 12,
                      paddingRight: 12,
                      paddingTop: 8,
                      paddingBottom: 8,
                      borderRadius: 6,
                      textSize: 12,
                      onTap: () {},
                    ),

                    CustomButton(
                      text: 'Book',
                      paddingLeft: 35,
                      paddingRight: 35,
                      paddingTop: 8,
                      paddingBottom: 8,
                      borderRadius: 6,
                      color: AppColors.top5Transparent,
                      borderColor: AppColors.serviceGray,
                      textColor: AppColors.serviceGray,
                      textSize: 12,
                      onTap: () {},
                    ),

                    CustomButton(
                      text: '',
                      icon: 'assets/images/home/call.svg',
                      paddingLeft: 40,
                      paddingRight: 20,
                      paddingTop: 8,
                      paddingBottom: 8,
                      borderRadius: 6,
                      color: AppColors.top5Transparent,
                      borderColor: AppColors.serviceGray,
                      textColor: AppColors.serviceGray,
                      textSize: 12,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            left: 332.w,
            top: 10.h,
            child: GestureDetector(
              onTap: () => Get.dialog(RemoveReservationListView()),
              child: SvgPicture.asset(
                  'assets/images/profile/remove_cross.svg'
              ),
            ),
          )
        ],
      ),
    );
  }
}
