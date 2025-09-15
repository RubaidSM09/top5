import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:top5/common/app_colors.dart';

import 'app/core/dependency_injection.dart';
import 'app/routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    setupDependencies();
  runApp(
    ScreenUtilInit(
      designSize: const Size(402, 874), // Set your design size (e.g., based on your design mockup)
      minTextAdapt: true, // Allows text to scale adaptively
      splitScreenMode: true, // Supports split-screen mode
      builder: (context, child) {
        return GetMaterialApp(
          title: "Top 5",
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.rightToLeft,
          transitionDuration: Duration(milliseconds: 300),
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.homeWhite,

            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.homeWhite,
              foregroundColor: AppColors.homeWhite,
            ),
          ),
        );
        },
    ),
  );
  });
}
