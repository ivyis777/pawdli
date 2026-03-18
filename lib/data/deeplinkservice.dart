import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import '../../presentation/screens/pet store/pet_storeproduct.dart';
import '../../data/model/storeprocductmodel.dart';

class DeepLinkHandler {
  static Future<void> init() async {
    // 🔹 App opened from terminated state
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      _handleLink(initialLink.link);
    }

    // 🔹 App opened from background
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      _handleLink(dynamicLinkData.link);
    });
  }

  static void _handleLink(Uri uri) {
    if (uri.pathSegments.contains('product')) {
      final productId = uri.queryParameters['pid'];
      if (productId != null) {
        Get.to(() => ProductDetailsScreen(
              product: Data(storeproductId: int.parse(productId)),
            ));
      }
    }
  }
}
