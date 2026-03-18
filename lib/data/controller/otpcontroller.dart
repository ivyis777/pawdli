import 'dart:async';
import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';

class OtpController extends GetxController {
  var isLoading = false.obs;
  var cooldownSeconds = 0.obs;
  Timer? _cooldownTimer;

  bool get isCooldownActive => cooldownSeconds.value > 0;

  void updateLoading(bool load) {
    isLoading.value = load;
  }

  // ---------------- OTP REQUEST ----------------
  Future<({bool success, String message})> getOtpUser({
    required String email,
    String? username,
    String? mobile,
    required String purpose,
    required bool isResend,
  }) async {
    // Cooldown check
    if (isCooldownActive) {
      return (
        success: false,
        message:
            'Please wait ${cooldownSeconds.value} seconds before requesting OTP again.'
      );
    }

    updateLoading(true);

    try {
      final response = await ApiService.OtpApi(
        email: email,
        username: username,
        mobile: mobile,
        purpose: purpose,
        isResend: isResend,
      );

      if (response.status == true) {
        return (
          success: true,
          message: response.message ??
              'OTP sent successfully. Please check your email.'
        );
      } else {
        return (
          success: false,
          message: response.message ?? 'Something went wrong'
        );
      }
    } catch (e) {
        final error = e.toString();

        print("🔥 RAW ERROR: $error");

        String code = '';
        String message = '';

        // ✅ Extract "CODE: message"
        if (error.contains(':')) {
          final parts = error.split(':');

          code = parts[0]
              .replaceAll('Exception', '')
              .replaceAll('(', '')
              .replaceAll(')', '')
              .trim();

          message = parts.sublist(1).join(':').trim();
        }

        print("✅ PARSED CODE: $code");
        print("✅ PARSED MESSAGE: $message");

        switch (code) {
          case 'EMAIL_EXISTS':
            return (
              success: false,
              message: 'Email already registered. Please login.'
            );

          case 'USERID_EXISTS':
            return (
              success: false,
              message: 'UserId already exists. Try different Id.'
            );

          case 'MOBILE_EXISTS':
            return (
              success: false,
              message: 'Mobile number already registered.'
            );

          case 'EMAIL_NOT_FOUND':
            return (
              success: false,
              message: 'Email not found. Please sign up first.'
            );

          case 'ACCOUNT_TEMPORARILY_LOCKED':
            final wait = _extractSecondsFromError(error);
            _startCooldown(wait);
            return (
              success: false,
              message: 'Too many attempts. Wait $wait seconds.'
            );

          case 'TIMEOUT':
            return (
              success: false,
              message: 'Request timed out. Try again.'
            );

          case 'FORMAT_ERROR':
            return (
              success: false,
              message: 'Invalid server response. Try again!'
            );

          default:
            return (
              success: false,
              message: message.isNotEmpty
                  ? message
                  : 'Something went wrong. Please try again.'
            );
        }
      } finally {
      updateLoading(false);
    }
  }

  // ---------------- COOLDOWN ----------------
  int _extractSecondsFromError(String error) {
    final regex = RegExp(r'wait (\d+) seconds');
    final match = regex.firstMatch(error);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }

  void _startCooldown(int seconds) {
    cooldownSeconds.value = seconds;

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cooldownSeconds.value > 0) {
        cooldownSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    super.onClose();
  }
}
