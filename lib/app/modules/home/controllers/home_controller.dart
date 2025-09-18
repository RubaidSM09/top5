import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final now = DateTime.now().obs;
  Timer? _timer;

  RxList<RxBool> selectedCategory = [true.obs, false.obs, false.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedFilter = [true.obs, false.obs, false.obs, false.obs, false.obs, false.obs].obs;

  RxBool isListView = true.obs;

  RxList<RxBool> selectedLocations = [false.obs, false.obs, false.obs, false.obs, false.obs].obs;

  final double dragSensitivity = 600;
  final RxDouble sheetPosition = 0.48.obs;

  final RxBool isMoreDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    // tick at the next minute, then every minute
    _tick(); // set initial value
    final firstDelay = Duration(seconds: 60 - DateTime.now().second);
    _timer = Timer(firstDelay, () {
      now.value = DateTime.now();
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        now.value = DateTime.now();
      });
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  RxString get formatted {
    final d = DateFormat('EEE', 'en_US').format(now.value);
    final t = DateFormat('h:mma', 'en_US')
        .format(now.value)
        .replaceAll(' ', '')
        .toLowerCase();
    return '$d, $t'.obs;
  }

  void _tick() => now.value = DateTime.now();

  bool get isOnDesktopAndWeb =>
      kIsWeb ||
          switch (defaultTargetPlatform) {
            TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows => true,
            TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => false,
          };

  void onDragUpdate(DragUpdateDetails details) {
    double next = sheetPosition.value - details.delta.dy / dragSensitivity;
    if (next < 0.25) next = 0.25;
    if (next > 1.0) next = 1.0;
    sheetPosition.value = next;
  }

  double convertToMiles(String input) {
    // Conversion factors
    const double metersInKm = 1000;
    const double metersInMile = 1609.34;

    // Split the string into value and unit
    final parts = input.trim().split(' ');
    if (parts.length != 2) {
      throw FormatException("Invalid input format. Example: '1 km' or '20 m'");
    }

    final double value = double.tryParse(parts[0]) ??
        (throw FormatException("Invalid number"));
    final String unit = parts[1].toLowerCase();

    // Convert input to meters
    double meters;
    switch (unit) {
      case 'km':
        meters = value * metersInKm;
        break;
      case 'm':
        meters = value;
        break;
      default:
        throw FormatException("Unsupported unit. Use 'm' or 'km'");
    }

    // Convert meters to miles
    return meters / metersInMile;
  }
}
