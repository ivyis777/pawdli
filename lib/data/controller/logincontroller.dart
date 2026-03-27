import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/reelitemcontroller.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  final box = GetStorage();
  var isLoading = false.obs;
  var isNavigating = false.obs;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


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

      if (response.status == true && response.data != null) {

        final user = response.data!;

        print("USER ID: ${user.userId}");
        print("EMAIL: ${user.email}");
        print("IS SUPER USER: ${user.isSuperuser}");
        print("IS STAFF: ${user.isStaff}");

        // ✅ SAVE SESSION
        box.write(LocalStorageConstants.sessionManager, true);
        box.write(LocalStorageConstants.userId, user.userId);
        box.write(LocalStorageConstants.userEmail, user.email);
        box.write(LocalStorageConstants.username, user.username ?? '');
        box.write(LocalStorageConstants.access, user.tokens?.access ?? '');
        box.write(LocalStorageConstants.refresh, user.tokens?.refresh ?? '');
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

    Future<({bool success, String message})> loginWithGoogle() async {
    try {
      isLoading.value = true;

      await _googleSignIn.signOut(); 
      // await _googleSignIn.disconnect();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return (success: false, message: "Google sign-in cancelled");
      }

      final email = googleUser.email;

      final fcmToken = box.read('fcm_token') ?? "";
      final apnsToken = box.read('apns_token') ?? "";

      final response = await ApiService.loginAPI(
        email: email,
        otp: "", 
        through_google: true,
        fcm_token: fcmToken,
        apns_token: apnsToken,
      );

      if (response.status == true && response.data != null) {

        final user = response.data!;

        // ✅ Save session
        box.write(LocalStorageConstants.sessionManager, true);
        box.write(LocalStorageConstants.userId, user.userId);
        box.write(LocalStorageConstants.userEmail, user.email);
        box.write(LocalStorageConstants.username, user.username ?? '');
        box.write(LocalStorageConstants.access, user.tokens?.access ?? '');
        box.write(LocalStorageConstants.refresh, user.tokens?.refresh ?? '');
        box.write(LocalStorageConstants.name, user.name ?? '');

        // try {
        //   await FirebaseMessaging.instance.subscribeToTopic("all_users");
        //   print("✅ Subscribed to topic: all_users");
        // } catch (e) {
        //   print("⚠️ FCM subscribe skipped: $e");
        // }
        print("✅ GOOGLE LOGIN SUCCESS RETURNING TRUE");
        return (success: true, message: "Login successful");
      }

      print("❌ GOOGLE LOGIN FAILED CONDITION");
      print("status: ${response.status}");
      print("data: ${response.data}");
      print("tokens: ${response.data?.tokens}");

      return (success: false, message: response.message ?? "Login failed");
    } catch (e) {
      print("❌ GOOGLE LOGIN ERROR: $e");
      return (success: false, message: "Google login failed");
    } finally {
      isLoading.value = false;
    }
  }

    // Future<({bool success, String message})> loginWithApple() async {
    //   print("🍎 Apple login started");
    //   try {
    //     isLoading.value = true;

    //     final credential = await SignInWithApple.getAppleIDCredential(
    //       scopes: [
    //         AppleIDAuthorizationScopes.email,
    //         AppleIDAuthorizationScopes.fullName,
    //       ],
    //     );

    //     print("🍎 credential.email: ${credential.email}");
    //     print("🍎 credential.userIdentifier: ${credential.userIdentifier}");
    //     print("🍎 stored email: ${box.read('apple_email')}");

    //     // ✅ Step 1: get email OR stored email
    //     String? email = credential.email ?? box.read('apple_email');

    //     // ✅ Step 2: fallback to Apple userIdentifier
    //     if (email == null || email.isEmpty) {
    //       final userId = credential.userIdentifier ?? "apple_user";

    //       // ✅ safe substring (no crash)
    //       final shortId = userId.length > 20 ? userId.substring(0, 20) : userId;

    //       email = "$shortId@apple.com";
    //     }

    //     // ✅ Save for next time
    //     box.write('apple_email', email);

    //     final fcmToken = box.read('fcm_token') ?? "";
    //     final apnsToken = box.read('apns_token') ?? "";

    //     final response = await ApiService.loginAPI(
    //       email: email,
    //       otp: "",
    //       through_google: true, 
    //       fcm_token: fcmToken,
    //       apns_token: apnsToken,
    //     );

    //     if (response.status == true && response.data != null) {

    //       final user = response.data!;

    //       box.write(LocalStorageConstants.sessionManager, true);
    //       box.write(LocalStorageConstants.userId, user.userId);
    //       box.write(LocalStorageConstants.userEmail, user.email);
    //       box.write(LocalStorageConstants.username, user.username ?? '');
    //       box.write(LocalStorageConstants.access, user.tokens?.access ?? '');
    //       box.write(LocalStorageConstants.refresh, user.tokens?.refresh ?? '');

    //       try {
    //         await FirebaseMessaging.instance.subscribeToTopic("all_users");
    //         print("✅ Subscribed to topic: all_users");
    //       } catch (e) {
    //         print("⚠️ FCM subscribe skipped: $e");
    //       }
    //       print("🍎 APPLE LOGIN SUCCESS RETURNING TRUE");
    //       return (success: true, message: "Login successful");
    //     }

    //     return (success: false, message: response.message ?? "Login failed");

    //   } catch (e) {
    //     print("❌ Apple login error: $e");
    //     return (success: false, message: "Apple login failed");
    //   } finally {
    //     isLoading.value = false;
    //   }
    // }             
}
