import 'package:get/get.dart';
import 'package:pawlli/core/auth/authservice.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/model/reelitemmodel.dart';

class ReelsController extends GetxController {
  // ---------------------- STATE ----------------------
  var reels = <ReelItem>[].obs;
  var isLoading = false.obs;
  var page = 1;
  var hasMore = true.obs;

  // ---------------------- LIFECYCLE ----------------------
  @override
  void onReady() {
    super.onReady();
    fetchReels();
  }

  // ---------------------- FETCH REELS ----------------------
  Future<void> fetchReels({bool loadMore = false}) async {
  if (isLoading.value || !hasMore.value) return;

  try {
    isLoading.value = true;

    // 🔐 Ensure token is valid / refreshed
    final ok = await AuthService.refreshTokenIfNeeded();
    if (!ok) return;

    final newReels = await ApiService.fetchReels(
      limit: 100,
      page: page,
    );

    if (newReels.isEmpty) {
      hasMore.value = false;
    } else {
      if (loadMore) {
        reels.addAll(newReels);
      } else {
        reels.assignAll(newReels);
      }
      print("🎥 FETCHED REELS COUNT: ${newReels.length}");
      page++;
    }
  } catch (e) {
    print("❌ FETCH REELS ERROR: $e");
  } finally {
    isLoading.value = false;
  }
}


  // ------------------------------------------------------------------
  // 🔴 REMOVE REEL LOCALLY (USED AFTER DELETE)
  // ------------------------------------------------------------------
  void removeReelById(String videoId) {
    reels.removeWhere((e) => e.id == videoId);
  }

  // ------------------------------------------------------------------
  // 🔄 RESET & REFRESH (OPTIONAL USE)
  // ------------------------------------------------------------------
  Future<void> refreshReels() async {
    page = 1;
    hasMore.value = true;
    reels.clear();
    await fetchReels();
  }
}
