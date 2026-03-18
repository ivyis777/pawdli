import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' as storage;
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/model/WalletBalancemodel.dart';

class WalletBalanceController extends GetxController {
  final isLoading = false.obs;

  final walletBalance = Rxn<WalletBalanceModel>();
  final walletBalanceAmount = "0.00".obs;

  @override
  void onInit() {
    super.onInit();

    final box = storage.GetStorage();
    final int? userId = box.read(LocalStorageConstants.userId);

    if (userId != null) {
      fetchWalletBalance(userId);
    } else {
      walletBalanceAmount.value = "0.00";
    }
  }

  Future<void> fetchWalletBalance(int userId) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;

      final balance = await ApiService.fetchWalletBalance(userId);

      // 🛡️ SAFETY: API may return null (HTML / error / token issue)
      if (balance == null) {
        walletBalance.value = null;
        walletBalanceAmount.value = "0.00";
        return;
      }

      walletBalance.value = balance;
      walletBalanceAmount.value =
          balance.data?.walletBalance ?? "0.00";
    } catch (e) {
      // ❌ NEVER crash UI
      print("❌ WalletBalanceController error: $e");
      walletBalance.value = null;
      walletBalanceAmount.value = "0.00";
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔄 Optional helper if you update wallet locally
  void updateWalletBalance(String amount) {
    final current = double.tryParse(walletBalanceAmount.value) ?? 0.0;
    final add = double.tryParse(amount) ?? 0.0;
    walletBalanceAmount.value =
        (current + add).toStringAsFixed(2);
  }

  /// 🚪 Call this on logout if needed
  void clearWallet() {
    walletBalance.value = null;
    walletBalanceAmount.value = "0.00";
  }
}
