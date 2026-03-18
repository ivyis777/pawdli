import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/data/model/storeverifypaymentmodel.dart';
import 'package:pawlli/data/api%20service.dart';

class RazorpayVerifyService {
  static Future<RazorpayVerifyResponseModel> verifyPayment(
      RazorpayVerifyRequestModel request) async {
    // 🔐 Get access token
    final accessToken = await ApiService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("User not authenticated");
    }

    final response = await http.post(
      Uri.parse(AppUrl.VerifyStorePayment),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(request.toJson()),
    );

    // ✅ Success
    if (response.statusCode == 200 || response.statusCode == 201) {
      return RazorpayVerifyResponseModel.fromJson(
        jsonDecode(response.body),
      );
    }

    // 🔁 Token expired → refresh and retry once
    if (response.statusCode == 401) {
      final refreshed = await ApiService.refreshToken();

      if (refreshed == true) {
        return verifyPayment(request); // retry once
      }
    }

    // ❌ Other errors
    throw Exception("Payment verification failed: ${response.body}");
  }
}
