import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/therapyslot.dart';

class TherapySlotController extends GetxController {
  var isLoading = false.obs;
  var therapySlots = <TherapySlot>[].obs;
  var errorMessage = ''.obs;

  List<TherapySlot> get slotList => therapySlots;

  Future<void> loadTherapySlots({
    required int therapyId,
    required String day,
    required String date,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      therapySlots.clear();

      final result = await ApiService.fetchtherapySlots(
        therapyId,
        day,
        date,
      );

      if (result != null && result.data.isNotEmpty) {
        therapySlots.value = result.data;
      } else {
        errorMessage.value = 'No slots available.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load slots: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
