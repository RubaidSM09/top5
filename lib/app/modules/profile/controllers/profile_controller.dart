import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:top5/app/data/model/action_places_details.dart';
import 'package:top5/app/data/services/api_services.dart';
import 'package:top5/app/modules/authentication/views/sign_in_view.dart';
import 'package:top5/app/modules/dashboard/views/dashboard_view.dart';

class ProfileController extends GetxController {
  RxList<RxBool> selectedDefaultFilters = [true.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedDietary = [true.obs, false.obs, false.obs].obs;
  RxList<RxBool> selectedDistanceUnit = [true.obs, false.obs, false.obs].obs;

  final RxBool isCurrentPasswordVisible = true.obs;
  final RxBool isNewPasswordVisible = true.obs;
  final RxBool isConfirmPasswordVisible = true.obs;

  var isLoading = false.obs;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final ApiService _service = ApiService();

  var fullName = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var image = ''.obs;

  var savedPlaces = <ActionPlacesDetails>[].obs;
  var recentPlaces = <ActionPlacesDetails>[].obs;
  var reservedPlaces = <ActionPlacesDetails>[].obs;

  Future<void> fetchProfileInfo() async {
    final http.Response verificationResponse = await _service.getProfileInfo();

    print('fetchProfileData CODE : ${verificationResponse.statusCode}');
    print('fetchProfileData body : ${verificationResponse.body}');

    if (verificationResponse.statusCode == 200) {
      final responseData = jsonDecode(verificationResponse.body);

      print(':::::::::RESPONSE: ${responseData.toString()}');

      String? _fullName = responseData['user']['full_name'];
      String? _email = responseData['user']['email'];
      String? _phone= responseData['user']['phone'];
      String? _image = responseData['user']['image'];

      fullName.value = _fullName ?? '';
      email.value = _email ?? '';
      phone.value = _phone ?? '';
      image.value = _image ?? '';
    }
  }

  void updateFullName (String newValue) {
    fullName.value = newValue;
    print(':::::::::update hit');
  }

  void updateEmail (String newValue) {
    email.value = newValue;
    print(':::::::::update hit');
  }

  void updatePhone (String newValue) {
    phone.value = newValue;
    print(':::::::::update hit');
  }

  Future<void> editProfile(String? newFullName, String? newEmail, String? newPhone, File? image) async {
    try {
      final http.Response response = await _service.editProfile(newFullName, newEmail, newPhone, image);

      if (response.statusCode == 200) {
        if (newFullName != null)  fullName.value = newFullName;
        if (newEmail != null)  email.value = newEmail;
        if (newPhone != null)  phone.value = newPhone;

        if (image != null) {
          await fetchProfileInfo();
        }

        Get.snackbar('Success', 'Profile updated successfully');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to update profile';
        Get.snackbar('Error', error);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> changePassword (String currentPassword, String newPassword, String confirmPassword) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.changePassword(currentPassword,newPassword,confirmPassword);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        Get.snackbar('Success', 'Password changed Successfully');

        Get.offAll(DashboardView());
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Change password failed', responseBody['message'] ?? 'Please use Correct password');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> userLogout() async {
    try {
      final http.Response response = await _service.logout();

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        await FlutterSecureStorage().deleteAll();
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');

        await _storage.deleteAll();
        Get.snackbar('Success', 'Logged out successfully!');

        Get.offAll(() => SignInView());
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Logout failed', responseBody['message'] ?? 'Please try again');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while logging out. Please try again.');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final http.Response response = await _service.deleteAccount();

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        await FlutterSecureStorage().deleteAll();
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');

        await _storage.deleteAll();
        Get.snackbar('Success', 'Account deleted successfully!');

        Get.offAll(() => SignInView());
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Delete failed', responseBody['message'] ?? 'Please try again');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while deleting account. Please try again.');
    }
  }

  Future<void> submitProblem (String supportEmail, String problem) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.submitProblem(supportEmail,problem);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        Get.snackbar('Success', 'Problem submitted Successfully');

        Get.offAll(DashboardView());
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Problem submit failed', responseBody['message'] ?? 'Please provide correct email or problem');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitReport (String supportEmail, String reportUrl, String report) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.submitReport(supportEmail,reportUrl,report);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        Get.snackbar('Success', 'Report submitted Successfully');

        Get.offAll(DashboardView());
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Report submit failed', responseBody['message'] ?? 'Please provide correct email or url or report');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitFeedback (String supportEmail, String feedback) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.submitFeedback(supportEmail,feedback);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        Get.snackbar('Success', 'Problem submitted Successfully');

        Get.offAll(DashboardView());
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('Problem submit failed', responseBody['message'] ?? 'Please provide correct email or problem');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }


  /// Recent, Saved, Reservation
  Future<void> actionPlaces (String placeId, double latitude, double longitude, String placeName, double rating, String directionUrl, String phone, String email, String website, String priceCurrency, String activityType, String image) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.actionPlaces(placeId, latitude, longitude, placeName, rating, directionUrl, phone, email, website, priceCurrency, activityType, image);

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        Get.snackbar('Success', '$activityType toggled successfully');
      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('$activityType toggle failed', responseBody['message'] ?? 'Please try again later');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    }
  }

  Future<void> actionPlacesDetails (String actionType) async {
    isLoading.value = true;

    try {
      final http.Response response = await _service.actionPlacesDetails();

      print(':::::::::RESPONSE:::::::::${response.body.toString()}');
      print(':::::::::CODE:::::::::${response.statusCode}');
      print(':::::::::REQUEST:::::::::${response.request}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print(':::::::::responseBody:::::::::$responseBody');

        if (actionType == 'saved') {
          savedPlaces.assignAll(responseBody);
          Get.snackbar('Success', 'Saved list fetched successfully');
          return;
        }

      } else {
        final responseBody = jsonDecode(response.body);
        Get.snackbar('$actionType list fetch failed', responseBody['message'] ?? 'Please try again later');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occured');
      print('Error: $e');
    }
  }

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    fetchProfileInfo();
    // actionPlacesDetails('saved');
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
