import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/slotcreationmodel.dart';

class SlotController extends GetxController {
  var isLoading = false.obs;
  var slotList = <Data>[].obs;

  Future<void> fetchSlots(int radioId, String day, String date) async {
    try {
      isLoading(true);

      // Fetch data from API with date parameter
      SlotPageModel? slots = await ApiService.fetchSlots(radioId, day, date);

      if (slots != null && slots.data != null) {
        slotList.assignAll(slots.data!);

        // 🔥 ADD THIS PRINT HERE
        for (var slot in slotList) {
          // print("BACKEND SLOT → ${slot.startTime} - ${slot.endTime}");
        }

      } else {
        slotList.clear();
      }
    } catch (e) {
      print("Error fetching slots: $e");
    } finally {
      isLoading(false);
    }
  }
}
