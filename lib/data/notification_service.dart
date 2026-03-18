import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notification init
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _local.initialize(settings);

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotification(message);
      }
    });
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _local.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      details,
    );
  }

  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}


class NotificationTopicService {

  static Future<void> subscribeAllUsers() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic("all_users");
      print("✅ Subscribed to topic: all_users");
    } catch (e) {
      print("❌ Topic subscription failed: $e");
    }
  }

}
