import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/getpetprofile.dart';



class PetProfileController extends GetxController {
  var PetProfile = Rxn<GetPetProfileModel>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }
  Future<void> loadPetProfile(int? petId) async {
    if (petId == null) {
      errorMessage.value = "User ID is required.";
      return;
    }

    isLoading.value = true;
    errorMessage.value = ''; 

    try {
      final petData = await ApiService.fetchPetProfile(petId);
      if (petData != null) {
        PetProfile.value = petData;
      } else {
        errorMessage.value = "Failed to load profile data.";
      }
    } catch (e) {
      errorMessage.value = "An error occurred: $e";
      print("Error loading user profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
