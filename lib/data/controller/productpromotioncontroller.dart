import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/productpromotionmodel.dart';

class Productpromotioncontroller extends GetxController {
  var promotions = <Productpromotionmodel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPromotions();
  }

  Future<void> fetchPromotions() async {
    isLoading.value = true;

    try {
      print("🔍 Fetching PRODUCT promotions...");
      final result = await ApiService.fetchProductPromotions();  // ✅ NEW API

      if (result.isNotEmpty) {
        promotions.assignAll(result);
        print("✅ Loaded ${promotions.length} product promotions.");
      } else {
        promotions.clear();
        print("⚠️ No product promotions found.");
      }
    } catch (e) {
      promotions.clear();
      print("❌ ERROR loading product promotions: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
