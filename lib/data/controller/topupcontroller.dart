import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/topupmodel.dart';


class TopUpController extends GetxController {
  var isLoading = false.obs;
  var topUpResponse = Rxn<TopUPModel>();

  Future<void> topUpWallet({
    required int userId,
    required double amount,
    required String purpose,
  }) async {
    try {
      isLoading.value = true;
      var response = await ApiService.topUpWallet(
        userId: userId,
        amount: amount,
        purpose: purpose,
      );
      if (response != null) {
        topUpResponse.value = response;
      } else {
        print("Top-up failed");
      }
    } catch (e) {
      print("Error in TopUpController: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
