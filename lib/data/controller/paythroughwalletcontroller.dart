import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/paythroughwallet.dart';
import 'dart:convert'; // For jsonEncode

class PayThroughWalletController extends GetxController {
  var paymentResult = Rx<PayThroughWalletModel?>(null);
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> initiatePayment({
    required String amount,
    required String currency,
    required List<int> bookingId,
    required String purpose,
    required String receipt,
    String? programName,
    String? programDescription,
    List<String>? language,
    String? date,
    String? programType,
    required String userId,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      isLoading(true);

      // Build a raw payload map for debugging
      final rawData = {
        "amount": amount,
        "currency": currency,
        "bookingId": bookingId,
        "purpose": purpose,
        "receipt": receipt,
        "programName": programName ?? "",
        "programDescription": programDescription ?? "",
        "language": language ?? [],
        "date": date ?? "",
        "programType": programType ?? "",
        "userId": userId,
        "extraData": extraData ?? {},
      };

      // Print raw JSON payload
      print("📤 Wallet Payment Raw Data: ${jsonEncode(rawData)}");

      // Call the Payment API service
      paymentResult.value = await ApiService.initiatePayment(
        amount: amount,
        currency: currency,
        bookingId: bookingId,
        purpose: purpose,
        receipt: receipt,
        programName: programName ?? "",
        programDescription: programDescription ?? "",
        language: language ?? [],
        date: date ?? "",
        programType: programType ?? "",
        userId: userId,
      );

      isLoading(false);
    } catch (e) {
      isLoading(false);
      errorMessage.value = 'Error: $e';
    }
  }

  String get currentBalance {
    return paymentResult.value?.currentBalance ?? "0.00";
  }
}
