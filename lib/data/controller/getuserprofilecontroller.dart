import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';

import 'package:pawlli/data/model/getuserprofilemodel.dart';

class UserProfileController extends GetxController {
  var userProfile = Rxn<GetUserProfileModel>();
  var isLoading = false.obs;
  var errorMessage = ''.obs; // Added for error messages

  @override
  void onInit() {
    super.onInit();
  }
  Future<void> loadUserProfile(int? userId) async {
    
    if (userId == null) {
      
      errorMessage.value = "User ID is required.";
      return;
    }

    isLoading.value = true;
    errorMessage.value = ''; // Reset error message

    try {
      final profileData = await ApiService.fetchUserProfile(userId);
      print("PROFILE PICTURE RAW => ${profileData?.profilePicture}");

      if (profileData != null) {
        userProfile.value = profileData;
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
