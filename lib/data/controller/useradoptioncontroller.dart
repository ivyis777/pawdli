import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/useradoptionmodel.dart';

class UserAdoptionController extends GetxController {
  var isLoading = false.obs;
  var adoptionPets = <UserAdoptionModel>[].obs;
  var petProfile = Rxn<UserAdoptionModel>(); // Rxn allows null values

  @override
  void onInit() {
    super.onInit();
    fetchUserAdoptionPetList();
  }

  Future<void> fetchUserAdoptionPetList({int? userId}) async {
    try {
      isLoading.value = true;
      final pets = await ApiService.fetchUserAdoptionPets(userId);
      adoptionPets.assignAll(pets);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserAdoptionPetById(int id) async {
    try {
      isLoading.value = true;

      if (adoptionPets.isEmpty) {
        await fetchUserAdoptionPetList();
      }

      final pet = adoptionPets.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception("Pet not found"),
      );

      petProfile.value = pet;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

