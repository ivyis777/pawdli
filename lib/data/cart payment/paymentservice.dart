// payment_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pawlli/presentation/screens/payment%20failure/payment_failure.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/app url.dart';
import 'package:pawlli/data/controller/cartviewcontroller.dart';
import 'package:pawlli/data/controller/walletbalancecontroller.dart';
import 'package:pawlli/data/controller/transactioncontroller.dart';
import 'package:pawlli/presentation/screens/pet store/myorders.dart';

class PaymentService extends GetxService {
  late Razorpay _razorpay;

  final CartController cartController = Get.find<CartController>();
  final WalletBalanceController walletBalanceController = Get.find<WalletBalanceController>();
  final TransactionController transactionController = Get.find<TransactionController>();

  RxBool isProcessing = false.obs;

  String? _currentRazorpayOrderId;
  String? get currentRazorpayOrderId => _currentRazorpayOrderId;

  Future<PaymentService> init() async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRzpSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRzpError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    return this;
  }

  void disposeService() {
    _razorpay.clear();
  }

  Future<bool> payThroughWallet({
    required int userId,
    required List<int> cartIds,
    required double walletAmount,
    required String shippingAddress,
    required String billingAddress,
  }) async {
    isProcessing.value = true;
    try {
      final token = await ApiService.getAccessToken();
      if (token == null) throw Exception("Not authenticated");

      final body = {
        "user_id": userId,
        "cart_ids": cartIds,
        "wallet_amount_used": walletAmount,
        "currency": "INR",
        "amount": walletAmount.toStringAsFixed(2),
        "purpose": "PetStore",
        "payment_mode": "Wallet",
        "shipping_address": shippingAddress,
        "billing_address": billingAddress,
      };

      final res = await http.post(
        Uri.parse(AppUrl.paythroughwalletUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["status"] == "success") {
          // refresh wallet, cart, transactions
          await walletBalanceController.fetchWalletBalance(userId);
          await cartController.loadCart();
          await transactionController.fetchUserTransactions(userId);
          return true;
        }
      }
      return false;
    } catch (e, st) {
      debugPrint("payThroughWallet error: $e\n$st");
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Creates order on backend. Returns map of parsed response or null
  Future<Map<String, dynamic>?> createOrderOnServer({
    required int userId,
    required List<int> cartIds,
    required double walletAmountUsed,
    required double amountToPay,
    required String shippingAddress,
    required String billingAddress,
  }) async {
    try {
      final token = await ApiService.getAccessToken();
      final body = {
        "user_id": userId,
        "cart_ids": cartIds,
        "wallet_amount_used": walletAmountUsed,
        "amount": amountToPay.toStringAsFixed(2),
        "currency": "INR",
        "purpose": "PetStore",
        "payment_mode": "Razorpay",
        "shipping_address": shippingAddress,
        "billing_address": billingAddress,
      };

      final res = await http.post(
        Uri.parse(AppUrl.OrderCreationURL),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        debugPrint("createOrderOnServer failed: ${res.statusCode} ${res.body}");
        return null;
      }
    } catch (e, st) {
      debugPrint("createOrderOnServer error: $e\n$st");
      return null;
    }
  }

  Future<bool> verifyPaymentWithServer({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final result = await ApiService.verifyPayment(
        razorpay_order_id: razorpayOrderId,
        razorpay_payment_id: razorpayPaymentId,
        razorpay_signature: razorpaySignature,
      );

      // ApiService.verifyPayment should return something truthy on success (your existing behavior)
      return result != null;
    } catch (e) {
      debugPrint("verifyPaymentWithServer error: $e");
      return false;
    }
  }

  // ---------------- RAZORPAY ----------------
  void openRazorpayCheckout({required String orderId, required double amountInRupees}) {
    _currentRazorpayOrderId = orderId;

    final int paise = (amountInRupees * 100).round();
    final options = {
      "key": "rzp_live_hUYYZly69YfdVs",
      "amount": paise,
      "currency": "INR",
      "order_id": orderId,
      "name": "Pawlli",
      "description": "Pet Store Order",
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay open error: $e");
      Fluttertoast.showToast(msg: "Failed to open payment gateway");
    }
  }

  // ---------------- RAZORPAY HANDLERS ----------------
  void _handleRzpSuccess(PaymentSuccessResponse response) async {
    final rOrderId = response.orderId ?? _currentRazorpayOrderId ?? "";
    final rPaymentId = response.paymentId ?? "";
    final rSignature = response.signature ?? "";

    final ok = await verifyPaymentWithServer(
      razorpayOrderId: rOrderId,
      razorpayPaymentId: rPaymentId,
      razorpaySignature: rSignature,
    );

    if (ok) {
      // refresh everything
      try {
        final uid = int.tryParse(await ApiService.getStoredUserId() ?? "0") ?? 0;
        if (uid > 0) {
          await walletBalanceController.fetchWalletBalance(uid);
          await cartController.loadCart();
          await transactionController.fetchUserTransactions(uid);
        }
      } catch (_) {}
      Fluttertoast.showToast(msg: "Payment verified");
      Get.offAll(() => OrdersPage());
    } else {
      Fluttertoast.showToast(msg: "Payment verification failed");
      // navigate to failure screen if needed
    }
  }

  void _handleRzpError(PaymentFailureResponse response) async {
    debugPrint("Razorpay Error: ${response.code} ${response.message}");
    Fluttertoast.showToast(msg: "Payment failed");
    // Optionally attempt verification with parsed info
    Get.to(() => Paymentfailure(orderId: _currentRazorpayOrderId ?? "", paymentId: "", signature: "", paymentVerifiedModel: null));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External wallet selected: ${response.walletName}");
  }
}
