import 'package:get/get.dart';

class ProfileController extends GetxController {
  RxList<RxBool> selectedDefaultFilters = [true.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedDietary = [true.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedDistanceUnit = [true.obs, false.obs, false.obs].obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
