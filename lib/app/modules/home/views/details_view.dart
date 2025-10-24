import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:top5/app/modules/home/views/contact_us_view.dart';
import 'package:top5/app/modules/home/views/service_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/custom_fonts.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../secrets/secrest.dart';
import '../controllers/home_controller.dart';
import 'google_map_webview.dart';

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
  final List<dynamic> reasons;
  final RxBool isSaved;
  final String placeId;  // New
  final double destLat;
  final double destLng;

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
    required this.placeId,  // New
    required this.destLat,
    required this.destLng,
    super.key,
  });

  Future<void> _openDirections() async {
    final c = Get.find<HomeController>();

    double oLat, oLng;
    if (c.manualOverride.value && c.manualLat.value != null && c.manualLng.value != null) {
      oLat = c.manualLat.value!;
      oLng = c.manualLng.value!;
    } else {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location', 'Location services disabled.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        Get.snackbar('Location', 'Permission denied for location.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      oLat = pos.latitude;
      oLng = pos.longitude;
    }

    Get.to(() => DirectionsMapWebView(
      googleApiKey: googleApiKey,
      originLat: oLat,
      originLng: oLng,
      destLat: destLat,
      destLng: destLng,
      travelMode: 'WALKING',
      destName: title,
      destImgUrl: image,
    ));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPlaceDetails(placeId);
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const DetailsAppBar(),
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Obx(() {
            final detailsReady = controller.placeDetails.isNotEmpty &&
                controller.placeAiDetails.isNotEmpty &&
                !controller.detailsLoading.value;

            // Filter out the current place from top5 list
            final otherPlaces = controller.top5Places
                .where((p) => p.placeId != placeId)
                .toList();

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
                            image: NetworkImage(image),
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

                      if (controller.detailsLoading.value)
                        const Center(child: CircularProgressIndicator())
                      else if (detailsReady)
                        Column(
                          spacing: 12.h,
                          children: (controller.placeAiDetails['ai_summary'] as List? ?? []).map((s) => WhyTop5Point(text: s.toString())).toList(),
                        )
                      else
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
                            onTap: () => Get.dialog(const ContactUsView()),
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
                            onTap: _openDirections,
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
                            onTap: () {}, // kept unchanged intentionally
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h,),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 151.w),
                  child: GestureDetector(
                    onTap: () {
                      controller.isMoreDetails.value = !controller.isMoreDetails.value;
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.serviceGreen,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        controller.isMoreDetails.value ? 'See Less' : 'More Details',
                        style: h3.copyWith(
                          color: AppColors.serviceWhite,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),

                controller.isMoreDetails.value ? Padding(
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

                      Obx(() {
                        if (!detailsReady) {
                          return const SizedBox.shrink();
                        }
                        final ratings = controller.placeAiDetails['ai_ratings'] as Map<String, dynamic>? ?? {};
                        return Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: ratings.entries.map((e) => DetailsTagCard(text: '${e.key.capitalizeFirst} ${e.value}')).toList(),
                        );
                      }),

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
                        children: const [
                          DetailsTagCard(
                            text: 'Best time',
                            isActive: true,
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

                      SizedBox(height: 24.h,),

                      Text(
                        'Top dishes / Amenities',
                        style: h2.copyWith(
                          color: AppColors.serviceBlack,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 12.h,),

                      Obx(() {
                        if (!detailsReady) {
                          return const SizedBox.shrink();
                        }
                        final types = controller.placeAiDetails['types'] as List? ?? [];
                        return Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: types.map((t) => DetailsTagCard(text: t.toString().capitalizeFirst ?? t.toString())).toList(),
                        );
                      }),

                      SizedBox(height: 24.h,),

                      Text(
                        'Hours & contact',
                        style: h2.copyWith(
                          color: AppColors.serviceBlack,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 12.h,),

                      Obx(() {
                        if (!detailsReady) {
                          return const SizedBox.shrink();
                        }
                        var website = controller.placeDetails['website'] as String? ?? '';
                        var contactTime = controller.placeDetails['contact_time'] as String? ?? '';
                        return Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: [
                            DetailsTagCard(
                              text: contactTime,
                            ),

                            website.isNotEmpty ? DetailsTagCard(
                              text: 'Website',
                              icon: 'assets/images/home/website.svg',
                              onTap: () {
                                website = website.startsWith('http://') ? website.replaceFirst('http://', 'https://') : website;
                                print(website);
                                Get.to(() => WebViewPage(url: website));
                              },
                            ) : const SizedBox.shrink(),
                          ],
                        );
                      }),
                    ],
                  ),
                ) : const SizedBox.shrink(),

                Column(
                  children: [
                    SizedBox(height: 22.h,),

                    // ✅ Replaced static map_bg with live GoogleMapWebView
                    SizedBox(
                      height: 194.h,
                      width: double.infinity,
                      child: otherPlaces.isNotEmpty
                          ? GoogleMapWebView(
                        googleApiKey: googleApiKey,
                        originLat: destLat,
                        originLng: destLng,
                        excludeLat: destLat,
                        excludeLng: destLng,
                      )
                          : const Center(
                        child: Text('No other nearby places to show on map'),
                      ),
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

        const SizedBox.shrink(),
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
            decoration: const BoxDecoration(
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
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}


class DetailsTagCard extends StatelessWidget {
  final String text;
  final String icon;
  final bool isActive;
  final VoidCallback? onTap;  // New

  const DetailsTagCard({
    required this.text,
    this.icon = '',
    this.isActive = false,
    this.onTap,  // New
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.serviceSearchBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        spacing: 4.w,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: h3.copyWith(
              color: AppColors.serviceGray,
              fontSize: 12.sp,
            ),
          ),

          isActive ? Container(
            padding: EdgeInsets.all(3.r),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.serviceGreen,
            ),
          ) : icon != '' ? SvgPicture.asset(
              'assets/images/home/website.svg'
          ) : const SizedBox.shrink()
        ],
      ),
    );

    return onTap != null ? GestureDetector(onTap: onTap, child: child) : child;
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Website')),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.disabled)
          ..loadRequest(Uri.parse(url)),
      ),
    );
  }
}
