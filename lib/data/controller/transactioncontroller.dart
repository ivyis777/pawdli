import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/TransactionnsModel.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';

class TransactionController extends GetxController {
  var isLoading = false.obs;
  var transactionData = Rxn<TransactionsModel>();

  @override
  void onInit() {
    super.onInit();

    final userId = LocalStorage.getUserId();
    if (userId != null) {
      fetchUserTransactions(userId);
    }
  }

  Future<void> fetchUserTransactions(int userId) async {
    try {
      isLoading.value = true;

      final data = await ApiService.fetchtransaction(userId: userId);
      transactionData.value = data;
    } catch (e) {
      // ❌ NO snackbar
      // ❌ NO logout
      // just log
      print("❌ Transaction fetch failed: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
