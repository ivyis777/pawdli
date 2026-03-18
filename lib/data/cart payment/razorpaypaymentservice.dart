import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/data/model/razorpaycreateordermodel.dart';
import 'package:pawlli/data/api%20service.dart';

class RazorpayPaymentService {
  static Future<RazorpayCreateResponseModel> createRazorpayOrder(
      RazorpayCreateRequestModel request) async {
    // 🔐 Get access token
    final accessToken = await ApiService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("User not authenticated");
    }

    final response = await http.post(
      Uri.parse(AppUrl.CreateRazorpayRequest),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(request.toJson()),
    );

    // ✅ Success
    if (response.statusCode == 200 || response.statusCode == 201) {
      return RazorpayCreateResponseModel.fromJson(
        jsonDecode(response.body),
      );
    }

    // 🔁 Token expired → refresh & retry once
    if (response.statusCode == 401) {
      final refreshed = await ApiService.refreshToken();
      if (refreshed == true) {
        return createRazorpayOrder(request); // retry once
      }
    }

    // ❌ Other errors
    throw Exception("Razorpay order creation failed: ${response.body}");
  }
}
