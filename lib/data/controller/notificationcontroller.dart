import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/notificationmodel.dart';


class Notificationcontroller extends GetxController {
  RxBool isLoading = false.obs;
  RxList<NoticationModel> payments = <NoticationModel>[].obs;

  Future<void> fetchNotifications(int userId) async {
    try {
      isLoading.value = true;
      update(); // ✅ Notify GetBuilder to show loading

      final result = await ApiService.fetchnotifications(userId: userId);
      if (result != null) {
        payments.assignAll(result);
      } else {
        payments.clear();
        Get.snackbar("Error", "Failed to load notifications.");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    } finally {
      isLoading.value = false;
      update(); 
    }
  }
}
