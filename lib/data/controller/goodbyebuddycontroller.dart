import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';

class GoodByeBuddyController extends GetxController {
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> uploadGoodByeBuddyData({
    required String location,
    double? latitude,   
    double? longitude,   
    required String landmark,
    required String description,
    required List<File> imageFiles,
  }) async {
    // ================= DEBUG START =================
    print("========== GOODBYE BUDDY UPLOAD ==========");
    print("📍 Location        : $location");
    print("📍 Latitude        : $latitude");
    print("📍 Longitude       : $longitude");
    print("🏷️ Landmark        : $landmark");
    print("📝 Description     : $description");
    print("🖼️ Images count    : ${imageFiles.length}");
    for (int i = 0; i < imageFiles.length; i++) {
      print("   Image[$i] path : ${imageFiles[i].path}");
    }
    print("==========================================");
    // ================= DEBUG END ===================

    isLoading.value = true;
    errorMessage.value = '';

    try {
      bool success = await ApiService.uploadGoodByeBuddy(
        location: location,
        latitude: latitude,      // ✅ ADD
        longitude: longitude,    
        landmark: landmark,
        description: description,
        imageFiles: imageFiles,
      );

      print("✅ API RESPONSE SUCCESS: $success");

     if (success) {
  // 🔹 Stop loader
  isLoading.value = false;

  // 🔹 Show success popup
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          "Thank You 🙏",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Thank for your concern.\nOur team will reach out soon.",
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // 🔹 Close popup
              Get.back();

              // 🔹 Navigate to Home page
              Get.offAll(() => const HomePage());
            },
            child: const Text("OK"),
          ),
        ],
      ),
      barrierDismissible: false, // user must tap OK
    );
  });
} else {
  errorMessage.value = "Failed to upload data.";
}

    } catch (e, st) {
      errorMessage.value = e.toString();
      print("❌ EXCEPTION OCCURRED:");
      print(e);
      print(st);
    } finally {
      isLoading.value = false;
      print("🔁 Loading stopped");
    }
  }
}

