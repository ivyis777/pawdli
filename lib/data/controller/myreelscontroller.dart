import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/reelitemmodel.dart';

class MyReelsController extends GetxController {
  var myReels = <ReelItem>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyReels();
  }

  Future<void> fetchMyReels() async {
    try {
      isLoading(true);
      final result = await ApiService.fetchMyReels();
      myReels.assignAll(result);
    } catch (e) {
      print("❌ Error loading reels: $e");
    } finally {
      isLoading(false);
    }
  }

  // ------------------------------------------------------------------
  // 🔴 DELETE REEL
  // ------------------------------------------------------------------
Future<void> deleteReel(String videoId) async {
  try {
    isLoading(true);

    final success = await ApiService.deleteReel(videoId);

    if (success) {
      // 🔥 remove from list → auto refresh UI
      myReels.removeWhere((e) => e.id == videoId);

      Get.snackbar("Deleted", "Video deleted successfully");
    } else {
      Get.snackbar("Error", "Delete failed");
    }
  } catch (e) {
    print("DELETE CONTROLLER ERROR: $e");
    Get.snackbar("Error", "Something went wrong");
  } finally {
    isLoading(false);
  }
}

}
