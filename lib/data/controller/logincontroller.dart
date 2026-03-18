import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/reelitemcontroller.dart';

class LoginController extends GetxController {
  final box = GetStorage();
  var isLoading = false.obs;
  var isNavigating = false.obs;

  Future<({bool success, String message})> loginWithOtp({
    required String email,
    required String otp,
  }) async {
    if (isLoading.value) {
      return (success: false, message: "Login already in progress");
    }

    try {
      isLoading.value = true;
      final fcmToken = box.read('fcm_token') ?? "";
      final apnsToken = box.read('apns_token') ?? "";

      print("📤 Sending FCM Token: $fcmToken");
      print("📤 Sending APNs Token: $apnsToken");
            
      final response = await ApiService.loginAPI(
        email: email,
        otp: otp,
        through_google: false,
        fcm_token: fcmToken, 
        apns_token: apnsToken, 
      );
      print("LOGIN API RESPONSE: ${response.data}");

      if (response.status == true &&
          response.data != null &&
          response.data!.tokens?.access != null) {

        final user = response.data!;

        print("USER ID: ${user.userId}");
        print("EMAIL: ${user.email}");
        print("IS SUPER USER: ${user.isSuperuser}");
        print("IS STAFF: ${user.isStaff}");

        // ✅ SAVE SESSION
        box.write(LocalStorageConstants.sessionManager, true);
        box.write(LocalStorageConstants.userId, user.userId);
        box.write(LocalStorageConstants.userEmail, user.email);
        box.write(LocalStorageConstants.username, user.username);
        box.write(LocalStorageConstants.access, user.tokens!.access);
        box.write(LocalStorageConstants.refresh, user.tokens!.refresh);
        box.write(LocalStorageConstants.name, user.name ?? '');
        box.write(LocalStorageConstants.isSuperUser, user.isSuperuser);

        // 🔔 ✅ SUBSCRIBE TO ALL USERS TOPIC
        try {
          await FirebaseMessaging.instance.subscribeToTopic("all_users");
          print("✅ Subscribed to topic: all_users");
        } catch (e) {
          print("❌ Topic subscription failed: $e");
        }

        // ✅ LOAD DATA AFTER LOGIN
        if (Get.isRegistered<ReelsController>()) {
          Get.find<ReelsController>().fetchReels();
        }

        return (
          success: true,
          message: response.message ?? 'Login successful',
        );
      }

      // ❌ API FAILED
      return (
        success: false,
        message: _handleLoginError(
          response.code ?? 'LOGIN_FAILED',
          serverMessage: response.message,
        ),
      );
    } catch (e) {
      return (
        success: false,
        message: _handleLoginError(
          'NETWORK_ERROR',
          serverMessage: e.toString(),
        ),
      );
    } finally {
      isLoading.value = false;
      isNavigating.value = false;
    }
  }

  /// ❌ ERROR HANDLING (LOGIC KEPT)
  String _handleLoginError(String code, {String? serverMessage}) {
    final msg = (serverMessage ?? '').toLowerCase();

    // ✅ PRIORITY: CHECK SERVER MESSAGE FIRST
    if (msg.contains('otp')) {
      return 'Entered wrong OTP.';
    }

    if (msg.contains('not registered') || msg.contains('not found')) {
      return 'This email is not registered. Please sign up first.';
    }

    if (msg.contains('invalid')) {
      return 'Invalid details.';
    }

    // ✅ FALLBACK USING CODE
    switch (code) {
      case "EMAIL_NOT_FOUND":
      case "404":
        return 'This email is not registered. Please sign up first.';

      case "402":
      case "INVALID_OTP":
      case "OTP_INVALID":
        return 'Entered wrong OTP.';

      case "403":
        return 'Invalid details.';

      case "500":
        return 'Server error. Please try again later.';

      case "NETWORK_ERROR":
        return 'Network error. Please check your connection.';

      default:
        return serverMessage ?? 'Login failed. Please try again.';
    }
  }
}
