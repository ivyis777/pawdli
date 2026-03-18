import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/adoptioncreation.dart';
import 'package:pawlli/presentation/screens/Pet%20Adoption/pet_adt_list.dart';




class CreateAdoptionController extends GetxController {
  var isLoading = false.obs;
  Rx<AdoptionCreationResponse?> adoptionData = Rx<AdoptionCreationResponse?>(null);

  Future<void> createAdoptionRequest(Map<String, dynamic> adoptionForm, BuildContext context) async {
    try {
      isLoading.value = true;

      final response = await ApiService.createAdoptionRequest(adoptionForm); 
      adoptionData.value = response;

      Get.snackbar(
        'Success',
        response.message.toString(),
        backgroundColor: Colours.primarycolour,
        colorText: Colours.brownColour,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdoptionPets()),
        );
      });
    } on ApiException catch (e) {
      String errorMessage = e.message;
      try {
        final errorJson = jsonDecode(e.message);
        if (errorJson is Map && errorJson['message'] != null) {
          errorMessage = errorJson['message'];
        }
      } catch (_) {}

      Get.snackbar(
        'Failed',
        errorMessage,
        backgroundColor: Colours.primarycolour,
        colorText: Colours.brownColour,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
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
