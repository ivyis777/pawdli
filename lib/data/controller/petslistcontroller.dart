import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/petslistmodel.dart';

class Petslistcontroller extends GetxController {
  var userPets = <Data>[].obs; // Storing `Data` objects, not `PetsListModel`
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadUserPets(int? userId) async {
    if (userId == null) {
      errorMessage.value = "User ID is required.";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final petsResponse = await ApiService.fetchUserPets(userId);
      if (petsResponse != null && petsResponse.data != null) {
        userPets.assignAll(petsResponse.data!); // ✅ Extract and assign `data`
      } else {
        errorMessage.value = "Failed to load pet data.";
      }
    } catch (e) {
      errorMessage.value = "An error occurred: $e";
      print("Error loading user pets: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
