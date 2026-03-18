import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/cart%20payment/paymentservice.dart';
import 'package:pawlli/data/controller/cartviewcontroller.dart';
import 'package:pawlli/data/controller/competition_controller.dart';
import 'package:pawlli/data/controller/getuserprofilecontroller.dart';
import 'package:pawlli/data/controller/myordercontroller.dart';
import 'package:pawlli/data/controller/myreelscontroller.dart';
import 'package:pawlli/data/controller/mysubscriptioncontroller.dart';
import 'package:pawlli/data/controller/otpcontroller.dart';
import 'package:pawlli/data/controller/petslistcontroller.dart';
import 'package:pawlli/data/controller/reelitemcontroller.dart';
import 'package:pawlli/data/controller/signcontroller.dart';
import 'package:pawlli/data/controller/storecheckoutcontroller.dart';

import 'package:pawlli/data/controller/walletbalancecontroller.dart';
import 'package:pawlli/data/controller/transactioncontroller.dart';
import 'package:pawlli/data/controller/addresscontroller.dart';
import 'package:pawlli/data/notification_service.dart';

import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';
import 'package:pawlli/presentation/screens/splashcreen/splashscreen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/presentation/widgets/bottom%20bar/bottombar.dart';
import 'package:pawlli/presentation/widgets/fcm.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📦 BACKGROUND MESSAGE RECEIVED');
  debugPrint('📩 Title: ${message.notification?.title}');
  debugPrint('📦 Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  await NotificationService.init();


  setupFCM();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 🟢 Your existing controllers
  Get.put(SubscriptionController(), permanent: true);
  Get.put(OtpController(), permanent: true);
  Get.put(UserProfileController(), permanent: true);
    // ✅ LOAD USER PROFILE AT APP START
  final userProfileController = Get.find<UserProfileController>();

  final userId = int.tryParse(
    GetStorage().read(LocalStorageConstants.userId)?.toString() ?? '',
  );

  if (userId != null) {
    userProfileController.loadUserProfile(userId);
  }

  Get.put(Petslistcontroller(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(MyReelsController(), permanent: true);
  Get.put(ReelsController(), permanent: true);
  Get.lazyPut<MyOrdersController>(() => MyOrdersController(), fenix: true);

  // 🟢 REQUIRED for wallet + payment + address + orders
  Get.put(WalletBalanceController(), permanent: true);
  Get.put(TransactionController(), permanent: true);
  Get.put(SignupController(), permanent: true);
  Get.put(AddressController(), permanent: true);

  // This must come AFTER all the controllers above
  Get.putAsync(() => PaymentService().init(), permanent: true);
  Get.put(CompetitionController(), permanent: true);
  Get.put(StoreCheckoutController(), permanent: true);



  final token = await FirebaseMessaging.instance.getToken();
  print("🔥 FCM TOKEN: $token");

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  debugPrint('📲 OPENED FROM NOTIFICATION');
  debugPrint('🧾 message.data = ${message.data}');
  debugPrint('🧾 message.notification = ${message.notification}');
});


FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  debugPrint('🔔 ON MESSAGE (FOREGROUND)');
  debugPrint('🧾 message.data = ${message.data}');
  debugPrint('🧾 message.notification = ${message.notification}');
  debugPrint('🧾 title = ${message.notification?.title}');
  debugPrint('🧾 body = ${message.notification?.body}');
});

  FirebaseMessaging.onBackgroundMessage(
firebaseMessagingBackgroundHandler,
);


  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkUserLoggedIn() async {
    final box = GetStorage();
    final token = box.read(LocalStorageConstants.sessionManager); 
    return token != null && token != "";
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: _checkUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data == true) {
            return MainLayout();
          }
          return LoginPage();
        },
      ),
      routes: {
        '/splash': (context) => const SplashPage(),
      },
    );
  }
}
