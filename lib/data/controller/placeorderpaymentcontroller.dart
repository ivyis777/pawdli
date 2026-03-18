import 'package:get/get.dart';
import 'package:pawlli/data/cart%20payment/razorpaypaymentservice.dart';
import 'package:pawlli/data/model/razorpaycreateordermodel.dart';
import 'package:pawlli/data/model/storeverifypaymentmodel.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../cart payment/razorpayverifyservice.dart';

class PlaceOrderPaymentController extends GetxController {
  late Razorpay _razorpay;

  String? paymentTransactionId;

  @override
  void onInit() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    super.onInit();
  }

  Future<void> startRazorpayPayment({
    required String transactionId,
    required double amount,
    required String razorpayKey,
  }) async {
    paymentTransactionId = transactionId;

    final razorpayOrder =
        await RazorpayPaymentService.createRazorpayOrder(
      RazorpayCreateRequestModel(
        paymentTransactionId: transactionId,
        amount: amount,
      ),
    );

    _razorpay.open({
      "key": razorpayKey,
      "amount": (amount * 100).toInt(),
      "currency": "INR",
      "order_id": razorpayOrder.razorpayOrderId,
      "name": "Store Order",
      "description": "Online Payment",
    });
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    final verifyResponse = await RazorpayVerifyService.verifyPayment(
      RazorpayVerifyRequestModel(
        paymentTransactionId: paymentTransactionId!,
        razorpayOrderId: response.orderId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
      ),
    );

    if (verifyResponse.paymentStatus == "success") {
      Get.snackbar("Success", "Order placed successfully");
      // Navigate to success page
    }
  }

  void _handleError(PaymentFailureResponse response) {
    Get.snackbar("Payment Failed", response.message ?? "");
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
