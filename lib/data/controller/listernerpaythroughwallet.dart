import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/paythroughwallet.dart';


class ListenerPaythroghwalletController extends GetxController {
  // Observable to manage the payment result
  var paymentResult = Rx<PayThroughWalletModel?>(null);
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Method to initiate payment
  Future<void> initiatelisternerPayment({
    required String amount,
    required String currency,
    required String bookingId,
    required String purpose,
    required String receipt,
    required String programName,
    required String programDescription,
    required List<String> language,
    required String date,
    required String programType,
    required String userId,
  }) async {
    try {
      isLoading(true);
      // Call the Payment API service to initiate the payment
      paymentResult.value = await ApiService.initiatelisternerPayment(
        amount: amount,
        currency: currency,
        bookingId: bookingId,
        purpose: purpose,
        receipt: receipt,
        programName: programName,
        programDescription: programDescription,
        language: language,
        date: date,
        programType: programType,
        userId: userId,
      );
      isLoading(false);
    } catch (e) {
      isLoading(false);
      errorMessage.value = 'Error: $e'; // Update error message
    }
  }
}
