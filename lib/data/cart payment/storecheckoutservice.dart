import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/data/model/storecheckoutmodel.dart';
import 'package:pawlli/data/api%20service.dart';

class StoreCheckoutService {
  static Future<StoreCheckoutResponseModel> createOrder(
      StoreCheckoutRequestModel requestModel) async {
        
    // 🔐 Get access token
    final accessToken = await ApiService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("User not authenticated");
    }

      print("🔐 ACCESS TOKEN: $accessToken");
  print("📤 CHECKOUT REQUEST PAYLOAD:");
  print(jsonEncode(requestModel.toJson()));
  print("🌐 CHECKOUT URL: ${AppUrl.CheckOutOrder}");


    final response = await http.post(
      Uri.parse(AppUrl.CheckOutOrder),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(requestModel.toJson()),
    );

    

      print("📥 CHECKOUT RESPONSE STATUS: ${response.statusCode}");
  print("📥 CHECKOUT RESPONSE BODY:");
  print(response.body);


    // ✅ Success
    if (response.statusCode == 200 || response.statusCode == 201) {
      return StoreCheckoutResponseModel.fromJson(
        jsonDecode(response.body),
      );
    }

    // 🔁 Token expired → try refresh ONCE
    if (response.statusCode == 401) {
      final refreshed = await ApiService.refreshToken();

      if (refreshed == true) {
        return createOrder(requestModel); // retry once
      }
    }

    // ❌ Other errors
    throw Exception("Checkout failed: ${response.body}");
  }


static Future<bool> cancelOrder({
  required String orderId,
  required String reason,
}) async {
  // 🔐 Get access token
  final accessToken = await ApiService.getAccessToken();

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception("User not authenticated");
  }

  print("🔐 ACCESS TOKEN: $accessToken");
  print("📤 CANCEL ORDER REQUEST PAYLOAD:");
  print(jsonEncode({
    "order_id": orderId,
    "reason": reason,
  }));
  print("🌐 CANCEL ORDER URL: ${AppUrl.CancelOrder}");

  final response = await http.post(
    Uri.parse(AppUrl.CancelOrder),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    },
    body: jsonEncode({
      "order_id": orderId,
      "reason": reason,
    }),
  );

  print("📥 CANCEL ORDER RESPONSE STATUS: ${response.statusCode}");
  print("📥 CANCEL ORDER RESPONSE BODY:");
  print(response.body);

  // ✅ Success
  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  }

  // 🔁 Token expired → try refresh ONCE
  if (response.statusCode == 401) {
    final refreshed = await ApiService.refreshToken();

    if (refreshed == true) {
      return cancelOrder(
        orderId: orderId,
        reason: reason,
      ); // retry once
    }
  }

  // ❌ Other errors
  throw Exception("Cancel order failed: ${response.body}");
}
static Future<void> downloadInvoice({
  required String orderId,
}) async {
  try {
    // 🔐 Get token (same as your existing APIs)
    final accessToken = await ApiService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("User not authenticated");
    }

    final dio = Dio();

    final dir = await getApplicationDocumentsDirectory();

    final filePath = "${dir.path}/invoice_order_$orderId.pdf";

    print("🌐 INVOICE URL: /user/store/order/$orderId/receipt/");

    await dio.download(
      "https://app.pawdli.com/user/store/order/$orderId/receipt/",
      filePath,
      options: Options(
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    print("✅ Invoice downloaded: $filePath");

    // Open automatically
    OpenFilex.open(filePath);

  } catch (e) {
    print("❌ Invoice download failed: $e");
    rethrow;
  }
}

}