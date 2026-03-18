import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/updatepetmodel.dart';
import 'package:pawlli/core/storage_manager/colors.dart';

class UpdatePetController extends GetxController {
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("UpdatePetController initialized");
  }

  Future<UpdatePetModel?> updatePet(UpdatePetModel model, String petId) async {
    if (petId.isEmpty) {
      Get.snackbar("Error", "Pet ID is missing. Please try again.",
        backgroundColor: Colours.primarycolour,
        colorText: Colours.brownColour,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return null;
    }

    try {
      isLoading.value = true;
      final result = await ApiService.updatePetProfile(model, petId);

      if (result != null) {
        Get.snackbar("Success", "Pet profile updated successfully",
          backgroundColor: Colours.primarycolour,
          colorText: Colours.brownColour,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar("Error", "Failed to update pet profile",
          backgroundColor: Colours.primarycolour,
          colorText: Colours.brownColour,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
      }

      return result;
    } catch (e) {
      Get.snackbar("Error", "An error occurred. Please try again.",
        backgroundColor: Colours.primarycolour,
        colorText: Colours.brownColour,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      debugPrint("UpdatePet Error: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
