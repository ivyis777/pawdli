import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/updateprofilemodel.dart';

class UpdateProfileController extends GetxController {
  RxBool isLoading = false.obs;
  Rxn<UpdateProfileModel> updatedProfile = Rxn<UpdateProfileModel>();

 late String userId;

@override
void onInit() {
  super.onInit();
  final box = GetStorage();

  userId = box.read(LocalStorageConstants.userId)?.toString() ?? '';

  print("USER ID FROM STORAGE: $userId");
}


  Future<void> updateUserProfile(UpdateProfileModel model) async {
    try {
      isLoading.value = true;
      final result = await ApiService.updateUserProfile(model, userId);

      if (result != null) {
        updatedProfile.value = result;
        Get.snackbar("Success", "Profile updated successfully", backgroundColor:Colours.primarycolour,
        colorText: Colours.brownColour,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),);
      } else {
        Get.snackbar("Error", "Something went wrong while updating profile", backgroundColor:Colours.primarycolour,
        colorText: Colours.brownColour,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
