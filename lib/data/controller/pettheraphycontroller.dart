import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/pettheraphymodel.dart';

class PetTherapyController extends GetxController {
  var pets = <PetTherapy>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPetTherapies(); // ✅ default call for today
  }
void fetchPetTherapies({String? date}) async {
  try {
    isLoading(true);

    // ✅ If no date passed, use today's date in DD-MM-YYYY
    final selectedDate = date ?? DateFormat('dd-MM-yyyy').format(DateTime.now());

    final model = await ApiService.fetchAllPetTherapies(date: selectedDate);

    if (model != null && model.data != null) {
      pets.assignAll(model.data!);
    } else {
      pets.clear();
    }
  } catch (e) {
    print('Failed to fetch therapies: $e');
    pets.clear();
  } finally {
    isLoading(false);
  }
}

}