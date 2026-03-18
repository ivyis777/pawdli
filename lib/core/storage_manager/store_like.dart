import 'package:get_storage/get_storage.dart';

class LikeStorage {
  static final _box = GetStorage();
  static const _key = "liked_products";

  static List<int> getLikedProducts() {
    return List<int>.from(_box.read(_key) ?? []);
  }

  static bool isLiked(int productId) {
    return getLikedProducts().contains(productId);
  }

  static void toggleLike(int productId) {
    final liked = getLikedProducts();

    if (liked.contains(productId)) {
      liked.remove(productId);
    } else {
      liked.add(productId);
    }

    _box.write(_key, liked);
  }
}
