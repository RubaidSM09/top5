import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  final String baseUrl = "https://austin-ovisaclike-nonoptically.ngrok-free.dev";

  // login method
  Future<http.Response> login (String email, String password) async {
    final Uri url = Uri.parse('$baseUrl/api/v1/user/signin/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, String> body = {
      "email": email,
      "password": password
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // Sign-up method
  Future<http.Response> signUpSendOtp (String email) async {
    final Uri url = Uri.parse('$baseUrl/api/v1/user/signup/send-otp/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, String> body = {
      "email": email,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> signUpOtpVerification (String email, String otp) async {
    final Uri url = Uri.parse('$baseUrl/api/v1/user/otp-code-verified/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, String> body = {
      "email": email,
      "otp": otp,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> signUp (String fullName, String email, String password, String confirmPassword) async {
    final Uri url = Uri.parse('$baseUrl/api/v1/user/signup/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, String> body = {
      "full_name": fullName,
      "email": email,
      "password": password,
      "confirm_password": confirmPassword,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> socialSignIn (String email, String fullName, String authProvider) async {
    final Uri url = Uri.parse('$baseUrl/api/v1/user/social-login/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, String> body = {
      "email": email,
      "full_name": fullName,
      "auth_provider": authProvider,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // Profile
  Future<http.Response> getProfileInfo () async {
    final Uri url = Uri.parse('$baseUrl/api/v1/user/profile/');

    String? accessToken = await _storage.read(key: 'access_token');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    return await http.get(
      url,
      headers: headers,
    );
  }

  Future<http.Response> editProfile (String? fullName, String? email, String? phone, File? image) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/user/profile/');

    try {
      var request = http.MultipartRequest('PATCH', url);

      if (fullName != null && fullName.isNotEmpty) {
        request.fields['full_name'] = fullName;
      }
      if (email != null && email.isNotEmpty) {
        request.fields['email'] = email;
      }
      if (phone != null && phone.isNotEmpty) {
        request.fields['phone'] = phone;
      }

      if (image != null && image.existsSync()) {
        var imageStream = http.ByteStream(image.openRead());
        var imageLength = await image.length();

        String extension = image.uri.pathSegments.last.split('.').last.toLowerCase();
        String contentType;

        switch (extension) {
          case 'png':
            contentType = 'image/png';
            break;
          case 'jpg':
          case 'jpeg':
            contentType = 'image/jpeg';
            break;
          default:
            contentType = 'application/octet-stream';
            break;
        }

        var imageMultipart = http.MultipartFile(
          'image',
          imageStream,
          imageLength,
          filename: image.uri.pathSegments.last,
          contentType: MediaType.parse(contentType),
        );
        request.files.add(imageMultipart);
      }

      request.headers['Authorization'] = 'Bearer $accessToken';

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        print('Profile updated successfully: $responseString');
        return http.Response(responseString, 200);
      } else {
        final responseString = await response.stream.bytesToString();
        print('Failed to update profile: $responseString');
        return http.Response(responseString, response.statusCode);
      }
    } catch (e) {
      print('Error updating profile: $e');
      return http.Response('Error: $e', 500);
    }
  }

  Future<http.Response> changePassword (String currentPassword, String newPassword, String confirmPassword) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/user/changed_password/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, String> body = {
      "current_password": currentPassword,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // Forgot Password
  Future<http.Response> resetPasswordSendOtp (String email) async {
    final Uri url = Uri.parse('$baseUrl/api/v1/user/reset_send_otp/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, String> body = {
      "email": email,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> resetPasswordOtpVerification (String email, String otp) async {
    final Uri url = Uri.parse('$baseUrl/api/v1/user/otp-code-verified/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, String> body = {
      "email": email,
      "otp": otp,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> resetPassword (String email, String password, String confirmPassword) async {
    final Uri url = Uri.parse('$baseUrl/api/v1/user/reset_new_password/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, String> body = {
      "email": email,
      "password": password,
      "confirm_password": confirmPassword,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // Logout
  Future<http.Response> logout () async {
    String? refreshToken = await _storage.read(key: 'refresh_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/user/token/blacklist/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, String> body = {
      "refresh": refreshToken!,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // Delete Account
  Future<http.Response> deleteAccount () async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/user/account/delete/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    return await http.delete(
      url,
      headers: headers,
    );
  }

  // Help and Support
  Future<http.Response> submitProblem (String supportEmail, String problem) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/support/help_and_support/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, String> body = {
      "support_email": supportEmail,
      "type": "PROBLEM",
      "problem": problem,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> submitReport (String supportEmail, String reportUrl, String report) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/support/help_and_support/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, String> body = {
      "support_email": supportEmail,
      "type": "REPORT",
      "report": report,
      "url": reportUrl,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> submitFeedback (String supportEmail, String feedback) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/support/help_and_support/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, String> body = {
      "support_email": supportEmail,
      "type": "FEEDBACK",
      "feedback": feedback
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // Home
  Future<http.Response> getTimeAndTemperature (String latitude, String longitude) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/home/time-temp/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, String> body = {
      "latitude": latitude,
      "longitude": longitude
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> generateIdeas (String weatherDescription, String dayName, String timeStr, double tempCelsius, String category, String language) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/home/generate-idea/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, dynamic> body = {
      "weather_description": weatherDescription,
      "day_name": dayName,
      "time_str": timeStr,
      "temp_celsius": tempCelsius,
      "category": category,
      "language": language,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> top5PlaceList(
      double latitude,
      double longitude,
      String placeType, {
        String? search,
        double? radius,
        String? maxTime,
        String? mode,
        bool? openNow,
        bool? outdoor,
        bool? vegetarian,
        bool? bookable,
      }) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/home/top-five-place-list/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, dynamic> body = {
      "latitude": latitude,
      "longitude": longitude,
      "place_type": placeType,
      if (search != null && search.isNotEmpty) "search": search,
      if (radius != null) "radius": radius,
      if (maxTime != null) "max_time": maxTime,
      if (mode != null) "mode": mode,
      if (openNow != null) "open_now": openNow,
      if (outdoor != null) "outdoor": outdoor,
      if (vegetarian != null) "vegetarian": vegetarian,
      if (bookable != null) "bookable": bookable,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> placeDetails (
      String placeId, {
        required double userLatitude,
        required double userLongitude,
      }) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/home/place-details/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, dynamic> body = {
      "place_id": placeId,
      "user_latitude": userLatitude.toString(),
      "user_longitude": userLongitude.toString(),
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> mapUrls (List<String> placeIds,) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/home/maps-urls/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, dynamic> body = {
      "place_ids": placeIds,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> placeDetailsWithAi (String placeId,) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/home/place-details-with-ai/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, dynamic> body = {
      "place_id": placeId,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }


  /// Recent, Saved, Reserved
  Future<http.Response> actionPlaces (String placeId, double latitude, double longitude, String placeName, double rating, String directionUrl, String phone, String email, String website, String priceCurrency, String activityType, String image) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/actions/action_places/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, dynamic> body = {
      "place_id": placeId,
      "latitude": latitude,
      "longitude": longitude,
      "place_name": placeName,
      "rating": rating,
      "directions_url": directionUrl,
      "phone": phone,
      "email": email,
      "website": website,
      "price_currency": priceCurrency,
      "activity_type": activityType, // saved, recent, reservation, saved-delete, recent-delete, reservation-delete
      "image": image,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> actionPlacesDetails () async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/actions/action_places_details/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    return await http.get(
      url,
      headers: headers,
    );
  }



  /// Subscription Plan
  Future<http.Response> getSubscriptionList() async {
    final Uri url = Uri.parse('$baseUrl/api/v1/subscription/list/');

    String? accessToken = await _storage.read(key: 'access_token');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    return await http.get(
      url,
      headers: headers,
    );
  }

  Future<http.Response> subscriptionCheckout(int planId) async {
    String? accessToken = await _storage.read(key: 'access_token');

    final Uri url = Uri.parse('$baseUrl/api/v1/subscription/checkout/');

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, dynamic> body = {
      "plan_id": planId,
    };

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> getCurrentActivePlan() async {
    final String? accessToken = await _storage.read(key: 'access_token');

    final uri = Uri.parse(
      '$baseUrl/api/v1/subscription/user/current-active-plan/',
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    return http.get(uri, headers: headers);
  }

  Future<http.Response> downloadProfilePdf() async {
    final token = await _storage.read(key: 'access_token');

    final url = Uri.parse('$baseUrl/api/v1/home/download-profile-pdf/');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        // 'Accept': 'application/pdf',
      },
    );
  }
}
