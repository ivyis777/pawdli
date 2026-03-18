import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/notificationcontroller.dart';
import 'package:pawlli/data/model/notificationmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';



class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Notificationcontroller controller = Get.put(Notificationcontroller());

  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    final userId = box.read(LocalStorageConstants.userId);
    controller.fetchNotifications(userId);
  }

  String convertToIst(String? utcDateString) {
    try {
      final utcDateTime = DateTime.parse(utcDateString ?? '').toUtc();
      final istDateTime = utcDateTime.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('dd MMM yyyy').format(istDateTime);
    } catch (e) {
      return 'Unknown';
    }
  }

  DateTime parseToIst(String? utcDateString) {
    try {
      final utcDateTime = DateTime.parse(utcDateString ?? '').toUtc();
      return utcDateTime.add(const Duration(hours: 5, minutes: 30));
    } catch (e) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: screenWidth * 0.55,
              height: screenHeight * 0.10,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.images.topimage.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            children: [
              PreferredSize(
                preferredSize: Size.fromHeight(screenHeight * 0.12),
                child: AppBar(
                  title: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.Cairo,
                      color: Colours.black,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.payments.isEmpty) {
                    return const Center(child: Text("No notifications available"));
                  }

                  List<NoticationModel> sortedNotifications = [...controller.payments];
                  sortedNotifications.sort((a, b) {
                    return parseToIst(b.createdAt).compareTo(parseToIst(a.createdAt));
                  });

                  Map<String, List<NoticationModel>> groupedNotifications = {};
                  for (var notification in sortedNotifications) {
                    String istDate = convertToIst(notification.createdAt);
                    groupedNotifications.putIfAbsent(istDate, () => []);
                    groupedNotifications[istDate]!.add(notification);
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: groupedNotifications.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: FontFamily.Ubantu,
                                  fontWeight: FontWeight.w700,
                                  color: Colours.primarycolour,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...entry.value.map((notification) {
                                return Card(
                                  color: Colours.secondarycolour,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                      color: Colours.primarycolour,
                                      width: 1,
                                    ),
                                  ),
                                  child: Container(
                                    width: screenWidth * 0.9,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.05,
                                      vertical: screenHeight * 0.02,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.title ?? "No Title",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colours.brownColour,
                                            fontFamilyFallback: ['NotoColorEmoji', 'sans-serif'],
                                          ),
                                       
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Text(
                                          notification.message ?? "No Description",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colours.textColour,
                                            fontFamilyFallback: ['NotoColorEmoji', 'sans-serif'],
                                          ),
                                        
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
