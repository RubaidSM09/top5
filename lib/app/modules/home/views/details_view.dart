import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/home/views/service_view.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../controllers/home_controller.dart';

class DetailsView extends GetView<HomeController> {
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

  const DetailsView({
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
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: DetailsAppBar(),
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          left: 14.w,
                          right: 14.w,
                          top: 9.38.h,
                          bottom: 170.62.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                          image: DecorationImage(
                            image: AssetImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 6.h,),
                              decoration: BoxDecoration(
                                color: AppColors.serviceSearchBg,
                                borderRadius: BorderRadius.circular(50.r),
                              ),
                              child: Text(
                                status,
                                style: h3.copyWith(
                                  color: AppColors.servicePromoGreen,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                isSaved.value = !isSaved.value;
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 6.h,),
                                decoration: BoxDecoration(
                                  color: AppColors.serviceSearchBg,
                                  borderRadius: BorderRadius.circular(50.r),
                                ),
                                child: Row(
                                  spacing: 6.w,
                                  children: [
                                    Text(
                                      isSaved.value == false ? 'Save' : 'Saved',
                                      style: h3.copyWith(
                                        color: isSaved.value == false
                                            ? AppColors.serviceGray
                                            : AppColors.serviceGreen,
                                        fontSize: 14.sp,
                                      ),
                                    ),

                                    SvgPicture.asset(
                                        isSaved.value == false ? 'assets/images/home/save.svg' : 'assets/images/home/saved.svg'
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 10.h,),

                      Row(
                        spacing: 12.w,
                        children: [
                          Text(
                            title,
                            style: h1.copyWith(
                              color: AppColors.serviceBlack,
                              fontSize: 22.sp,
                            ),
                          ),

                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14.r,
                                color: AppColors.serviceGreen,
                              ),

                              SizedBox(width: 4.w),

                              Text(
                                '$rating ',
                                style: h2.copyWith(
                                  color: AppColors.top5Black,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),

                          Text(
                            '€€',
                            style: h2.copyWith(
                              color: AppColors.top5Black,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h,),

                      Row(
                        spacing: 12.w,
                        children: [
                          Text(
                            '$distance / ${time.toStringAsFixed(0)} min walk',
                            style: h4.copyWith(
                              color: AppColors.serviceGray,
                              fontSize: 12.sp,
                            ),
                          ),

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
                              type,
                              style: h4.copyWith(
                                color: AppColors.serviceText2,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h,),

                      Text(
                        'Why it’s in the Top 5',
                        style: h2.copyWith(
                          color: AppColors.serviceBlack,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 14.h,),

                      Column(
                        spacing: 12.h,
                        children: [
                          for (int i=0; i<reasons.length; i++) ...[
                            WhyTop5Point(text: reasons[i]),
                          ]
                        ],
                      ),

                      SizedBox(height: 24.h,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomButton(
                            text: 'Book',
                            paddingLeft: 35,
                            paddingRight: 35,
                            paddingTop: 8,
                            paddingBottom: 8,
                            borderRadius: 6,
                            textSize: 12,
                            onTap: () {},
                          ),

                          CustomButton(
                            text: 'Directions',
                            prefixIcon: 'assets/images/home/directions2.svg',
                            paddingLeft: 12,
                            paddingRight: 12,
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

                SizedBox(height: 20.h,),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 151.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.serviceGreen,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'More Details',
                      style: h3.copyWith(
                        color: AppColors.serviceWhite,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h,),

                      Text(
                        'Review highlights',
                        style: h2.copyWith(
                          color: AppColors.serviceBlack,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 12.h,),

                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: [
                          DetailsTagCard(
                            text: 'Food 4.6',
                          ),

                          DetailsTagCard(
                            text: 'Service 4.6',
                          ),

                          DetailsTagCard(
                            text: 'Atmosphere 4.6',
                          ),

                          DetailsTagCard(
                            text: 'Price 4.6',
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h,),

                      Text(
                        'Best time / Busy now',
                        style: h2.copyWith(
                          color: AppColors.serviceBlack,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 12.h,),

                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: [
                          DetailsTagCard(
                            text: 'Best time',
                          ),

                          DetailsTagCard(
                            text: 'Busy now',
                          ),

                          DetailsTagCard(
                            text: 'Quiet now',
                          ),

                          DetailsTagCard(
                            text: 'Busier after 8 pm',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    SizedBox(height: 22.h,),

                    Stack(
                      children: [
                        Image.asset(
                          'assets/images/home/map_bg.jpg',
                          fit: BoxFit.cover,
                          scale: 4,
                        ),

                        DetailsLocationPointer(
                          serialNo: 1,
                          latitude: 218.33,
                          longitude: 45.67,
                          name: 'Bella Italia',
                          image: 'assets/images/home/bella_italia.jpg',
                          selectedLocations: controller.selectedLocations,
                        ),

                        DetailsLocationPointer(
                          serialNo: 2,
                          latitude: 293.33,
                          longitude: 73.67,
                          name: 'Sushi Zen',
                          image: 'assets/images/home/sushi_zen.jpg',
                          selectedLocations: controller.selectedLocations,
                        ),

                        DetailsLocationPointer(
                          serialNo: 3,
                          latitude: 338.33,
                          longitude: 133.67,
                          name: 'The Green Bistro',
                          image:
                          'assets/images/home/the_green_bistro.jpg',
                          selectedLocations: controller.selectedLocations,
                        ),

                        DetailsLocationPointer(
                          serialNo: 4,
                          latitude: 184.33,
                          longitude: 155.67,
                          name: 'Spice Route',
                          image: 'assets/images/home/spice_route.jpg',
                          selectedLocations: controller.selectedLocations,
                        ),

                        DetailsLocationPointer(
                          serialNo: 5,
                          latitude: 65.33,
                          longitude: 153.67,
                          name: 'Le Petit Cafe',
                          image: 'assets/images/home/le_petit_cafe.jpg',
                          selectedLocations: controller.selectedLocations,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}


class DetailsAppBar extends StatelessWidget {
  const DetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
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

        SvgPicture.asset(
          'assets/images/home/top_5_green_logo.svg',
        ),

        SizedBox.shrink(),
      ],
    );
  }
}


class WhyTop5Point extends StatelessWidget {
  final String text;

  const WhyTop5Point({
    required this.text,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6.w,
      children: [
        Container(
          padding: EdgeInsets.all(2.5.r),
          decoration: BoxDecoration(
            color: AppColors.serviceGreen,
            shape: BoxShape.circle,
          ),
        ),

        Text(
          text,
          style: h4.copyWith(
            color: AppColors.serviceGray,
            fontSize: 12.sp,
          ),
        )
      ],
    );
  }
}


class DetailsLocationPointer extends StatelessWidget {
  final int serialNo;
  final double latitude;
  final double longitude;
  final String name;
  final String image;
  final RxList<RxBool> selectedLocations;

  const DetailsLocationPointer({
    required this.serialNo,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.image,
    required this.selectedLocations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: longitude.h,
      left: latitude.w,
      child: Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.topCenter,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 4.67.w,
                vertical: 5.33.h,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/home/location_pointer.png',
                  ),
                ),
              ),
              child: Text(
                '$serialNo',
                style: h3.copyWith(
                  color: AppColors.serviceWhite,
                  fontSize: 6.sp,
                ),
              ),
            ),

            selectedLocations[serialNo - 1].value == false
                ? Positioned(
              bottom: 11.33.h,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  color: AppColors.serviceGreen,
                ),
                child: Column(
                  spacing: 6.h,
                  children: [
                    Text(
                      name,
                      style: h2.copyWith(
                        color: AppColors.serviceWhite,
                        fontSize: 10.sp,
                      ),
                    ),

                    Container(
                      width: 52.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        image: DecorationImage(
                          image: AssetImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : SizedBox.shrink(),
          ],
        ),
    );
  }
}


class DetailsTagCard extends StatelessWidget {
  final String text;
  final bool isActive;

  const DetailsTagCard({
    required this.text,
    this.isActive = false,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.serviceSearchBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        spacing: 4.w,
        children: [
          Text(
            text,
            style: h3.copyWith(
              color: AppColors.serviceGray,
              fontSize: 12.sp,
            ),
          ),

          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.serviceGreen,
            ),
          )
        ],
      ),
    );
  }
}
