import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/app%20url.dart';

import 'package:pawlli/data/model/couponmodel.dart';

class CouponService {
  static Future<CouponModel?> getCouponByCode(String code) async {
    final token = await ApiService.getAccessToken();

    if (token == null) return null;

    final response = await http.get(
      Uri.parse(
          "${AppUrl.ApplyCouponURL}?code=$code"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CouponModel.fromJson(data['coupon']);
    }

    return null;
  }
}
