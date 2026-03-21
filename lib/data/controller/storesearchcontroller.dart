import 'dart:async';
import 'package:get/get.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/model/storeprocductmodel.dart';

class StoreSearchController extends GetxController {
  var isLoading = false.obs;

  // ✅ SAME MODEL
  var products = <StoreProductData>[].obs;

  var recentSearches = <Map<String, String>>[].obs;

  Timer? _debounce;

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchProducts(query);
    });
  }

  // ===========================
  // ✅ FIXED SEARCH FUNCTION
  // ===========================
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      products.clear();
      return;
    }

    try {
      isLoading.value = true;

      final result = await ApiService.searchStoreProducts(query);

      // ✅ ASSIGN DATA
      products.assignAll(result);

      // 🔥 VERY IMPORTANT FIX → CHEAPEST VARIANT CALCULATION
      for (var p in products) {
        if (p.variants != null && p.variants!.isNotEmpty) {

          p.variants!.sort((a, b) =>
              (a.discountedPrice ?? a.regularPrice)
                  .compareTo(b.discountedPrice ?? b.regularPrice));

          // ✅ SET CHEAPEST VARIANT
          p.cheapestVariant = p.variants!.first;
        }
      }

      products.refresh();

      print("🔎 FINAL SEARCH RESULT: ${products.length}");

    } catch (e) {
      print("❌ Search Controller Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}