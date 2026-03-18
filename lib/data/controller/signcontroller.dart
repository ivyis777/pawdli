import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/presentation/widgets/bottom%20bar/bottombar.dart';

class SignupController extends GetxController {
  final box = GetStorage();
  var isLoading = false.obs;

  Future<void> getSignupUser({
    required String username,
    required String mobile,
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      final fcmToken = box.read('fcm_token') ?? "";
      final apnsToken = box.read('apns_token') ?? "";


      final response = await ApiService.signupApi(
        username: username,
        mobile: mobile,
        email: email,
        otp: otp,
        fcm_token: fcmToken,
        apns_token: apnsToken,
      );

      print("✅ Parsed signup status: ${response.status}");

      if (response.status == true &&
          response.data != null &&
          response.data!.tokens?.access != null) {

        // ✅ SAVE TOKENS
        box.write(LocalStorageConstants.sessionManager, true);
        box.write(LocalStorageConstants.access, response.data!.tokens!.access);
        box.write(LocalStorageConstants.refresh, response.data!.tokens!.refresh);
        box.write(LocalStorageConstants.userId, response.data!.userId);
        box.write(LocalStorageConstants.userEmail, response.data!.email);
        box.write(LocalStorageConstants.username, response.data!.username);
        box.write(LocalStorageConstants.name, response.data!.name ?? '');

        print("✅ Tokens saved correctly");

        // 🔔 ✅ SUBSCRIBE TO ALL USERS TOPIC
        try {
          await FirebaseMessaging.instance.subscribeToTopic("all_users");
          print("✅ Subscribed to topic: all_users");
        } catch (e) {
          print("❌ Topic subscription failed: $e");
        }

        // ⏳ Small delay
        await Future.delayed(const Duration(milliseconds: 300));

        print("🚀 Navigating to MainLayout");
        Get.offAll(() => MainLayout());
      } else {
        Get.snackbar(
          "Signup Failed",
          response.message ?? "Invalid OTP",
        );
      }
    } catch (e) {
      print("❌ Signup error: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
