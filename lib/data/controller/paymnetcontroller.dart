import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/paymentmodel.dart';

class PaymentTransactionController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<PaymentModel> payments = <PaymentModel>[].obs;

  Future<void> fetchUserPayments(int userId) async {
    try {
      isLoading.value = true;
      update(); 

      final result = await ApiService.fetchpayments(userId: userId);
      if (result != null) {
        payments.assignAll(result);
      } else {
        payments.clear();
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
