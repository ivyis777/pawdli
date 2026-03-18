import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/createpetmodel.dart';
import 'package:pawlli/presentation/screens/my%20pets/my%20pets.dart';



class CreatePetController extends GetxController {
  var isLoading = false.obs;
  Rx<CreatePetModel?> createdPetModel = Rx<CreatePetModel?>(null);

  Future<void> createPet(Map<String, dynamic> petData, BuildContext context) async {
  try {
    isLoading.value = true;

    final response = await ApiService.createPet(petData);
    createdPetModel.value = response;

    Get.snackbar(
      'Success',
      response.message ?? 'Pet created successfully',
      backgroundColor: Colours.primarycolour,
      colorText: Colours.brownColour,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );

  
    WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyPets(fromUpdateFlow: true,)),
        );
      });
    

  } on ApiException catch (e) {
    // Show validation or other API error
    String errorMessage = e.message;
    try {
      final errorJson = jsonDecode(e.message);
      if (errorJson is Map && errorJson['message'] != null) {
        errorMessage = errorJson['message'];
      }
    } catch (_) {}

    Get.snackbar(
      'Update Failed',
      errorMessage,
        backgroundColor: Colours.primarycolour,
      colorText: Colours.brownColour,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );

  } catch (e) {
    // Other unexpected errors
    Get.snackbar(
      'Error',
         'Server Issue',
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  } finally {
    isLoading.value = false;
  }
}
}