// lib/data/controller/storeproductcontroller.dart

import 'package:get/get.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/model/productVariantmodel.dart';
import 'package:pawlli/data/model/storeprocductmodel.dart';


class StoreProductController extends GetxController {
  var isLoading = false.obs;

  // original full list from API
  var productList = <StoreProductData>[].obs;

  // filtered + sorted list exposed to UI
  var filteredList = <StoreProductData>[].obs;

  var variantList = <StoreProductVariant>[].obs;
  var selectedSubCategoryName = ''.obs;

  // ================================
  // LOAD PRODUCTS FROM API
  // ================================
  Future<void> loadProducts(int subCategoryId) async {
  try {
    isLoading.value = true;

    final products = await ApiService.fetchProducts(subCategoryId);

    // 🔥 CALCULATE STOCK FOR EACH PRODUCT
    await Future.wait(products.map((p) async {
      final variants = await ApiService.fetchVariantsList(p.storeproductId!);

      bool isOutOfStock = true;
      int totalStock = 0;

      for (var v in variants) {
        int available = v.availableStock;
        totalStock += available;

        if (available > 0) {
          isOutOfStock = false;
        }
      }

      // ✅ SET VALUES INTO MODEL
      p.isOutOfStock = isOutOfStock;
      // p.totalStock = totalStock; // (we add this next step)
    }));

    productList.assignAll(products);
    filteredList.assignAll(products);

  } catch (e) {
    print("Error fetching products: $e");
  } finally {
    isLoading.value = false;
  }
}

// ================================
// SEARCH FUNCTION
// ================================
void search(String query) {
  final q = query.trim().toLowerCase();

  if (q.isEmpty) {
    filteredList.assignAll(productList);
    return;
  }

  filteredList.assignAll(
    productList.where((p) =>
        (p.productName ?? '').toLowerCase().contains(q) ||
        (p.productBrand ?? '').toLowerCase().contains(q) ||
        (p.petType ?? '').toLowerCase().contains(q)),
  );
}
  // ================================
  // SORT FUNCTION
  // ================================
  void sortProducts(String type) {
    List<StoreProductData> temp = [...filteredList];

    switch (type) {
      case "Popular":
        temp.sort((a, b) =>
            (b.isFeatured == true ? 1 : 0) - (a.isFeatured == true ? 1 : 0));
        break;

      case "Newest":
        temp.sort((a, b) {
          final aTime = _parseDate(a.createdAt);
          final bTime = _parseDate(b.createdAt);
          return bTime.compareTo(aTime);
        });
        break;

      case "Customer Review":
        // No rating field in model — fallback to featured
        temp.sort((a, b) =>
            (b.isFeatured == true ? 1 : 0) - (a.isFeatured == true ? 1 : 0));
        break;

      case "Price: High to Low":
        temp.sort((a, b) => _price(b).compareTo(_price(a)));
        break;

      case "Price: Low to High":
        temp.sort((a, b) => _price(a).compareTo(_price(b)));
        break;
    }

    filteredList.assignAll(temp);
  }

  // ================================
  // LOAD VARIANTS (unchanged)
  // ================================
  Future<void> loadVariants(int productId) async {
    try {
      final variants = await ApiService.fetchVariantsList(productId);
      variantList.assignAll(variants);
    } catch (e) {
      print("Error loading variants: $e");
    }
  }

  // ================================
  // HELPERS
  // ================================
  double _price(StoreProductData p) {
    // prefer discountedPrice if present
    final raw = p.discountedPrice?.isNotEmpty == true
        ? p.discountedPrice
        : p.regularPrice;
    return double.tryParse(raw ?? "0") ?? 0.0;
  }

  DateTime _parseDate(String? s) {
    if (s == null) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      return DateTime.parse(s);
    } catch (e) {
      // fallback: try to parse common formats or return epoch
      return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}
