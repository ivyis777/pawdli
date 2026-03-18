import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' hide Data;
import 'package:pawlli/core/auth/authservice.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/model/cartviewmodel.dart' show Data;

class CartController extends GetxController {
  var cartItems = <Data>[].obs;
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var showCartBadge = true.obs;

  var walletBalance = 0.0.obs;

  // Used in payment page
  var subtotal = 0.0.obs;
  var tax = 0.0.obs;
  var walletApplied = 0.0.obs;

  double taxPercent = 0.0;

  @override
  void onInit() {
    super.onInit();

    // ⭐ FIX: Do NOT call loadCart() before first frame is ready
    Future.microtask(() => loadCart());
  }

  /// Alias used by payment page
  Future<void> fetchCartItems() async {
    await loadCart();
  }

  /// Fetch cart items from backend
  Future<List<Data>> loadCart() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      print("🛒 Loading cart items...");

      final items = await ApiService.fetchCart();
      cartItems.assignAll(items);

      // ⭐ FIX: Correct subtotal update
      subtotal.value = calculateSubtotal();

      // await fetchWalletBalance();

      print("📦 Cart items loaded: ${items.length}");
      return items;
    } catch (e) {
      errorMessage.value = e.toString();
      print("❌ Error in loadCart: $e");
      return [];
    } finally {
      isLoading.value = false;
      print("🔚 Done loading cart → isLoading = false");
    }
  }

  /// Calculate subtotal price
  double calculateSubtotal() {
    double total = 0.0;

    for (var item in cartItems) {
      double price = double.tryParse(item.priceAtAdded ?? "0") ?? 0.0;
      int qty = item.quantity ?? 1;
      total += price * qty;
    }

    return total;
  }

  /// Fetch wallet balance
// Future<void> fetchWalletBalance() async {
//   try {
//     final ok = await AuthService.refreshTokenIfNeeded();
//     if (!ok) return;

//     final userId = LocalStorage.getUserId();
//     if (userId == null) return;

//     final response = await ApiService.get(
//       "https://app.pawdli.com/user/wallet/$userId",
//     );

//     final body = jsonDecode(response.body);

//     walletBalance.value =
//         double.tryParse(body['remaining_wallet_amount'].toString()) ?? 0.0;

//     print("💵 Wallet Balance: ${walletBalance.value}");
//   } catch (e) {
//     print("❌ Error fetching wallet balance: $e");
//   }
// }

  /// Call when cart icon is tapped
void hideCartBadge() {
  showCartBadge.value = false;
}

/// Call when item is added to cart
void showBadgeAgain() {
  showCartBadge.value = true;
}

}
