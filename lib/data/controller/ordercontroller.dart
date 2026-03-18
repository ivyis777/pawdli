// ordercontroller.dart
import 'package:get/get.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/model/ordermodel.dart';

class OrderController extends GetxController {
  Future<Order?> getOrderDetails(int id) async {
    try {
      return await ApiService.getOrderDetails(id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelOrder(int id) async {
    try {
      return await ApiService.cancelOrder(id);
    } catch (e) {
      return false;
    }
  }

  Future<bool> reorder(int id) async {
    try {
      return await ApiService.reorder(id);
    } catch (e) {
      return false;
    }
  }
}
