import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

Future<void> setupFCM() async {
  try {
    debugPrint('================ FCM SETUP START ================');

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('🔔 Authorization status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('🚫 Notification permission denied.');
      return;
    }

    debugPrint('🔔 Notification permission granted.');

    // ✅ Get APNS Token
    String? apnsToken = await messaging.getAPNSToken();
    debugPrint('🍎 APNs Token (iOS): $apnsToken');

    // 🔥 CRITICAL FIX (NO CRASH)
    if (defaultTargetPlatform == TargetPlatform.iOS && apnsToken == null) {
      debugPrint('⚠️ APNS not ready → skipping FCM for now');
      return;
    }

    // ✅ Safe now
    String? fcmToken = await messaging.getToken();
    debugPrint("🚀 FCM Token: $fcmToken");

    final box = GetStorage();

    if (apnsToken != null) {
      box.write('apns_token', apnsToken);
    }

    if (fcmToken != null) {
      box.write('fcm_token', fcmToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 Token refreshed: $newToken');
      box.write('fcm_token', newToken);
    });

  } catch (e) {
    debugPrint('❌ FCM ERROR (handled safely): $e');
  }

  // Listeners (safe)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📥 FOREGROUND MESSAGE RECEIVED');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📨 APP OPENED FROM NOTIFICATION');
  });

  debugPrint('================ FCM SETUP END ================');
}