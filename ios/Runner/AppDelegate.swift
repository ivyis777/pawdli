import UIKit
import Flutter
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 🔥 Initialize Firebase
    FirebaseApp.configure()

    // 🔔 Notification delegate (IMPORTANT)
    UNUserNotificationCenter.current().delegate = self

    // // 🔔 Request notification permission
    // UNUserNotificationCenter.current().requestAuthorization(
    //   options: [.alert, .badge, .sound]
    // ) { granted, error in
    //   if let error = error {
    //     print("Notification permission error: \(error)")
    //   }
    // }

    // application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ✅ Required for iOS 10+
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound, .badge])
  }
}
