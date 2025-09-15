import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final now = DateTime.now().obs;
  Timer? _timer;

  RxList<RxBool> selectedCategory = [true.obs, false.obs, false.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedFilter = [true.obs, false.obs, false.obs, false.obs, false.obs, false.obs].obs;

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
}
