import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/mysubscriptionmodel.dart'; 

class SubscriptionController extends GetxController {
  final RxInt currentSessionId = 0.obs;
  final RxBool hasActiveSession = false.obs;
  final RxInt currentBookingId = 0.obs;

  final box = GetStorage(); 

  RxList<ProgramData> programDataList = RxList<ProgramData>();
  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;


  Future<void> fetchAllSubscriptions(int userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      List<ProgramData> programs = await ApiService.fetchAllSubscription(userId);
      programDataList.assignAll(programs);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = false;
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = false;
        errorMessage.value = 'Error fetching subscriptions: ${e.toString()}';
      });

      print('Error fetching subscriptions: $e');
    }
  }

 
  // Add this to track restart status per booking
void setRestartStatus(int bookingId, bool value) {
  box.write('restart_status_$bookingId', value);
}

bool isRestarted(int bookingId) {
  return box.read('restart_status_$bookingId') ?? false;
}

void clearRestartStatus(int bookingId) {
  box.remove('restart_status_$bookingId');
}

  void clearAllHostJoinStatuses() {
    final keys = box.getKeys();
    for (var key in keys) {
      if (key.toString().startsWith('host_joined_')) {
        box.remove(key);
      }
    }
  }
}
