import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';

import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';

class AuthService {
  static bool _isRefreshing = false;
  static Completer<void>? _refreshCompleter;
  static bool _isLoggingOut = false;

  static Future<bool> refreshTokenIfNeeded() async {
    final access = LocalStorage.getAccessToken();

    // ✅ Access token valid
    if (access != null && !JwtDecoder.isExpired(access)) {
      return true;
    }

    // ✅ Wait if refresh already running
    if (_isRefreshing) {
      await _refreshCompleter?.future;
      return LocalStorage.getAccessToken() != null;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer();

    try {
      final refresh = LocalStorage.getRefreshToken();
      if (refresh == null) {
        logoutDueToAuthFailure(reason: 'refresh token missing');
        return false;
      }

      // 🔥 Make sure this method EXISTS
      final response = await ApiService.refreshToken();

      if (response != null) {
        LocalStorage.saveTokens(
          response,
          refresh,
        );
        _refreshCompleter!.complete();
        return true;
      } else {
        logoutDueToAuthFailure();
        _refreshCompleter!.complete();
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ Refresh token failed: $e');
      logoutDueToAuthFailure(reason: 'refresh api failed');
      _refreshCompleter!.complete();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  static void logoutDueToAuthFailure({String reason = 'unknown'}) {
  if (_isLoggingOut) return;
  _isLoggingOut = true;

  debugPrint('🚨 AUTH LOGOUT | reason=$reason');

  LocalStorage.clearAll();

  // 🔥 SAFE NAVIGATION (VERY IMPORTANT)
  if (Get.context != null) {
    Get.offAll(() => const LoginPage());
  } else {
    debugPrint("⚠️ Skip navigation — GetMaterialApp not ready");
  }

  _isLoggingOut = false;
}

}
