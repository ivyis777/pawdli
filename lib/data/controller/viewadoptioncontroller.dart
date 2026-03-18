import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/viewadpotionmodel.dart';

class AdoptionPetController extends GetxController {
  var isLoading = false.obs;
  var adoptionPets = <ViewAdoptionPet>[].obs;
  var petProfile = Rxn<ViewAdoptionPet>(); 

  @override
  void onInit() {
    super.onInit();
    fetchAdoptionPetList();
  }

  void fetchAdoptionPetList() async {
    try {
      isLoading.value = true;
      final pets = await ApiService.fetchAdoptionPets();
      adoptionPets.assignAll(pets);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAdoptionPetById(int id) async {
    try {
      isLoading.value = true;
      final pets = await ApiService.fetchAdoptionPets(); 
      final pet = pets.firstWhere((p) => p.id == id, orElse: () => throw Exception("Pet not found"));
      petProfile.value = pet;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
