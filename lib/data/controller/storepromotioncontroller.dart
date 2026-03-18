import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/promotionmodel.dart';

class Storepromotioncontroller extends GetxController {
  var promotion = <PromotionModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Auto-fetch when controller is initialized
    fetchPromotions();
  }

  /// Backwards-compatible method name retained
  Future<void> StorePromotions() async => fetchPromotions();

  /// Preferred clearer name
  Future<void> fetchPromotions() async {
    isLoading.value = true;
    try {
      print("🔎 Fetching store promotions...");
      List<PromotionModel>? response = await ApiService.StorePromotions();

      if (response != null && response.isNotEmpty) {
        promotion.assignAll(response);
        print("✅ Fetched ${response.length} promotions.");
      } else {
        promotion.clear();
        print("⚠️ No promotions returned from API.");
      }
    } catch (e, st) {
      print("❌ Error fetching promotions: $e\n$st");
      promotion.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
