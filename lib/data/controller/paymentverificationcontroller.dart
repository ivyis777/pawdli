import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/paymentverificationmodel.dart';

class PaymentController extends GetxController {
  var isLoading = false.obs;
  var paymentVerifiedData = Rxn<PaymentVerificationModel?>();

  Future<PaymentVerificationModel?> verifyPayment({
    required String razorpay_order_id,
    required String razorpay_payment_id,
    required String razorpay_signature,
  }) async {
    try {
      isLoading.value = true;

      var result = await ApiService.verifyPayment(
        razorpay_order_id: razorpay_order_id,
        razorpay_payment_id: razorpay_payment_id,
       razorpay_signature: razorpay_signature,
      );

      if (result != null) {
        paymentVerifiedData.value = result;
        return result;
      } else {
        Fluttertoast.showToast(msg: "Payment verification failed. Please try again.");
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error verifying payment: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
