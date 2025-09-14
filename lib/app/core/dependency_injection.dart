import 'package:get/get.dart';

import '../modules/authentication/controllers/authentication_controller.dart';

void setupDependencies() {

  // Controllers

  Get.put(AuthenticationController());
}