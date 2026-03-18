import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/data/cart%20payment/storecheckoutservice.dart';
import 'package:pawlli/data/controller/walletbalancecontroller.dart';
import 'package:pawlli/data/model/storecheckoutmodel.dart';

class StoreCheckoutController extends GetxController {
  var isLoading = false.obs;
  StoreCheckoutResponseModel? checkoutResponse;

  Future<void> checkout({
  required List<int> cartItems,
  required String paymentMethod,
  bool useWallet = false,
  String? couponCode,
  required double walletAmountUsed,
  Map<String, dynamic>? shippingAddress,
}) async {
  try {
    isLoading.value = true;
    checkoutResponse = null;

    final request = StoreCheckoutRequestModel(
      cartItems: cartItems,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
      useWallet: useWallet,
      walletAmountUsed: walletAmountUsed,
      shippingAddress: shippingAddress,
    );

    print("CHECKOUT REQUEST = ${request.toJson()}");

    // 🔥 CREATE ORDER
    checkoutResponse =
        await StoreCheckoutService.createOrder(request);

    // ⭐ NEW CODE START
    if (checkoutResponse != null) {
      final userId = LocalStorage.getUserId();

      if (userId != null) {
        final walletController =
            Get.find<WalletBalanceController>();

        print("💰 BEFORE refresh: ${walletController.walletBalanceAmount.value}");

        await walletController.fetchWalletBalance(userId);

        print("💰 AFTER refresh: ${walletController.walletBalanceAmount.value}");
      }
    }
    // ⭐ NEW CODE END

  } finally {
    isLoading.value = false;
  }
}

}


  // void handleNextStep() {
  //   if (checkoutResponse == null) return;

  //   // Wallet only
  //   if (checkoutResponse?.paymentStatus == "success") {
  //     Get.snackbar("Success", checkoutResponse!.message ?? "");
  //     // Navigate to success screen
  //   }

  //   // COD
  //   else if (checkoutResponse?.paymentStatus == "pending") {
  //     Get.snackbar("Order Placed", "Cash on Delivery");
  //     // Navigate to order placed screen
  //   }

  //   // Razorpay
  //   else if (checkoutResponse?.razorpayRequired != null) {
  //     // Open Razorpay payment
  //     print("Razorpay Amount: ${checkoutResponse!.razorpayRequired}");
  //     print("Transaction ID: ${checkoutResponse!.paymentTransactionId}");
  //   }
  // }
// }
