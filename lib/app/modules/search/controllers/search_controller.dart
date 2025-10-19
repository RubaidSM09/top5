import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';

class SearchController extends GetxController {
  TextEditingController searchBarTextController = TextEditingController(text: 'Italian restaurants');

  RxList<RxBool> isRemoved = [false.obs, false.obs, false.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedCategory = [true.obs, false.obs, false.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedFilter = [true.obs, false.obs, false.obs, false.obs, false.obs, false.obs].obs;

  late RxString searchText = ''.obs;

  final RxString searchQuery = ''.obs;

  void setSearchQuery(String query) {
    searchQuery.value = query;
    Get.find<HomeController>().performSearch(query);
  }

  @override
  void onInit() {
    super.onInit();
    searchText.value = searchBarTextController.text; // set initial
    searchBarTextController.addListener(() {
      searchText.value = searchBarTextController.text;
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    searchBarTextController.dispose();
    super.onClose();
  }
}
