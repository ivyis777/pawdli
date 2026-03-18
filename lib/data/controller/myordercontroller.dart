// my_orders_controller.dart
import 'package:get/get.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/model/ordermodel.dart';

enum OrderFilter { all, ordered, shipping, delivered, cancelled }

class MyOrdersController extends GetxController {
  final orders = <Order>[].obs;
  final filteredOrders = <Order>[].obs;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final filter = OrderFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    ever(filter, (_) => applyFilter());
  }

  Future<void> fetchOrders() async {
    print("📦 Orders Loaded: ${orders.length}");

    try {
      isLoading.value = true;
      final list = await ApiService.getOrders();
      orders.assignAll(list);
      applyFilter();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter() {
    final f = filter.value;

    if (f == OrderFilter.all) {
      filteredOrders.assignAll(orders);
      return;
    }

    filteredOrders.assignAll(
      orders.where((o) {
        final status = o.orderStatus.toLowerCase();
        switch (f) {
          case OrderFilter.ordered:
            return status == 'paid' ||
                status == 'pending' ||
                status == 'processing';
          case OrderFilter.shipping:
            return status == 'shipped';
          case OrderFilter.delivered:
            return status == 'delivered';
          case OrderFilter.cancelled:
            return status == 'cancelled';
          default:
            return true;
        }
      }).toList(),
    );
  }

  void setFilter(OrderFilter f) {
    filter.value = f;
  }
}
