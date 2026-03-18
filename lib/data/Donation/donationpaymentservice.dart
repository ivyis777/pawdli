import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/app%20url.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DonationPaymentService extends GetxService {
  late Razorpay _razorpay;
  String? _currentOrderId;

  // ================= INIT =================
  Future<DonationPaymentService> init() async {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    return this;
  }

  void disposeService() {
    _razorpay.clear();
  }

  // ================= START DONATION =================
  Future<void> startDonation({required double amount}) async {
    try {
      final userId =
          int.tryParse(await ApiService.getStoredUserId() ?? "0") ?? 0;

      if (userId == 0) {
        Fluttertoast.showToast(msg: "User not logged in");
        return;
      }

      print("🟢 Sending amount to backend: $amount");

      final res = await http.post(
        Uri.parse(AppUrl.OrderCreationURL),
        headers: {
          "Authorization": "Bearer ${await ApiService.getAccessToken()}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
          "amount": amount,
          "currency": "INR",
          "purpose": "Donation",
          "payment_mode": "Razorpay",
        }),
      );

      print("🟡 Donation Order Status: ${res.statusCode}");
      print("🟡 Donation Order Body: ${res.body}");

      // ✅ FIX: accept 201 also
      if (res.statusCode != 200 && res.statusCode != 201) {
        Fluttertoast.showToast(msg: "Order creation failed");
        return;
      }

      final data = jsonDecode(res.body);
      _currentOrderId = data["razorpay_order_id"];

      if (_currentOrderId == null) {
        Fluttertoast.showToast(msg: "Invalid order ID");
        return;
      }

      print("🟢 Razorpay Order ID: $_currentOrderId");

      _openRazorpay(amount);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  // ================= OPEN RAZORPAY =================
  void _openRazorpay(double amount) {
    final options = {
      "key": "rzp_live_hUYYZly69YfdVs", // use test key in debug
      "amount": (amount * 100).round(),
      "currency": "INR",
      "order_id": _currentOrderId,
      "name": "Pawlli",
      "description": "Donation",
      "retry": {"enabled": true, "max_count": 1},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to open Razorpay");
    }
  }

  // ================= PAYMENT SUCCESS =================
  void _handleSuccess(PaymentSuccessResponse response) async {
    try {
      final verified = await ApiService.verifyPayment(
        razorpay_order_id: response.orderId ?? "",
        razorpay_payment_id: response.paymentId ?? "",
        razorpay_signature: response.signature ?? "",
      );

      if (verified == null) {
        Fluttertoast.showToast(msg: "Payment verification failed");
        return;
      }

      Fluttertoast.showToast(msg: "Donation successful ❤️");
    } catch (_) {
      Fluttertoast.showToast(msg: "Verification error");
    } finally {
      _currentOrderId = null;
    }
  }

  // ================= PAYMENT ERROR =================
  void _handleError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment failed: ${response.message ?? "Unknown error"}",
    );
    _currentOrderId = null;
  }

  // ================= EXTERNAL WALLET =================
  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "Wallet selected: ${response.walletName}",
    );
  }
}
