import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

Future<void> setupFCM() async {
  debugPrint('================ FCM SETUP START ================');
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  

  // iOS: Request permission before getting token
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint('🔔 Authorization status: ${settings.authorizationStatus}');

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('🔔 Notification permission granted.');

    // ✅ Get APNs Token (important for iOS)
    String? apnsToken = await messaging.getAPNSToken();
    debugPrint('🍎 APNs Token (iOS): $apnsToken');

    if (defaultTargetPlatform == TargetPlatform.iOS && apnsToken == null) {
      debugPrint('❌ ERROR: APNs token is NULL (iOS will NOT receive notifications)');
    }

    // ✅ Get FCM Token
    String? fcmToken = await messaging.getToken();
    debugPrint("🚀 FCM Token: $fcmToken");

    if (fcmToken == null) {
      debugPrint('❌ ERROR: FCM Token is NULL');
    }

    // ✅ STORE TOKENS LOCALLY FOR LOGIN / SIGNUP
    final box = GetStorage();

    // Save APNs token (iOS only)
    if (apnsToken != null && apnsToken.isNotEmpty) {
      box.write('apns_token', apnsToken);
    }

    // Save FCM token (Android + iOS)
    if (fcmToken != null && fcmToken.isNotEmpty) {
      box.write('fcm_token', fcmToken);
    }


    // Optional: Listen to token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 Token refreshed: $newToken');
      box.write('fcm_token', newToken);
    });
  } else {
    debugPrint('🚫 Notification permission denied.');
  }

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📥 FOREGROUND MESSAGE RECEIVED');
    debugPrint('📩 Title: ${message.notification?.title}');
    debugPrint('📩 Body: ${message.notification?.body}');
    debugPrint('📦 Data: ${message.data}');
  });

  // Handle background/terminated message opened
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📨 APP OPENED FROM NOTIFICATION');
    debugPrint('📩 Title: ${message.notification?.title}');
    debugPrint('📦 Data: ${message.data}');
  });

  debugPrint('================ FCM SETUP END ================');

}
