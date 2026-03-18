import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/data/controller/myordercontroller.dart';
import 'package:pawlli/data/model/ordermodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/pet%20store/orderdetailspage.dart';

class OrdersPage extends StatelessWidget {
  OrdersPage({super.key});

final MyOrdersController controller = Get.find<MyOrdersController>();

  final filterNames = {
    OrderFilter.all: "All",
    OrderFilter.ordered: "Ordered",
    OrderFilter.shipping: "Shipping",
    OrderFilter.delivered: "Delivered",
    OrderFilter.cancelled: "Cancelled",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Stack(
        children: [
          // ✅ BACKGROUND TOP IMAGE
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.55,
              height: 80,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.images.topimage.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // ✅ APP BAR ON TOP (Back button + title visible)
          AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent, // IMPORTANT
            foregroundColor: Colors.black,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.maybePop(context),
            ),

            title: const Text(
              "My Orders",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: _orderList(),
      ),
  );
}


  Widget _orderList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredOrders.isEmpty) {
        return const Center(child: Text("No Orders Found"));
      }

      return ListView.builder(
        itemCount: controller.filteredOrders.length,
        itemBuilder: (_, i) => _orderCard(controller.filteredOrders[i]),
      );
    });
  }

  String getDisplayStatus(Order order) {
    final status = order.orderStatus.toLowerCase();

    // 🔴 FIRST PRIORITY — Cancelled
    if (status == "cancelled" || status == "order cancelled") {
      return "Cancel";
    }

    // 🟢 Delivered
    if (status == "delivered") {
      return "Delivered";
    }

    // 🟢 Razorpay payment completed
    if (order.razorpayPaymentId != null &&
        order.razorpayPaymentId!.isNotEmpty) {
      return "Confirmed";
    }

    // 🟢 Wallet-paid orders
    if (order.finalAmount > 0 &&
        order.razorpayOrderId == null &&
        order.razorpayPaymentId == null) {
      return "Confirmed";
    }

    // 🟡 COD orders
    if (status == "pending") {
      return "Confirmed";
    }

    return order.orderStatus.capitalize ?? "Pending";
  }

Widget _orderCard(Order order) {
  final item = order.items.first;

  return GestureDetector(
    onTap: () => Get.to(() => OrderDetailsPage(order: order)),
    child: Card(
      color: const Color.fromARGB(255, 251, 236, 210),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE
            // PRODUCT IMAGE
ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: Builder(
  builder: (_) {
    String imageUrl = "";

    // ✅ 1. Variant images
    if (item.variantImages.isNotEmpty) {
      imageUrl = item.variantImages.first;
    }

    // ✅ 2. Single product image (NOW WORKS)
    else if (item.productImage != null &&
        item.productImage!.isNotEmpty) {
      imageUrl = item.productImage!;
    }

    // ✅ 3. Product images list
    else if (item.productImages.isNotEmpty) {
      imageUrl = item.productImages.first;
    }

    // ✅ 4. Safe fallback
    else {
      imageUrl = "https://picsum.photos/80";
    }

    return Image.network(
      imageUrl,
      height: 80,
      width: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          height: 80,
          width: 80,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported),
        );
      },
    );
  },
),
),

            const SizedBox(width: 12),

            // ORDER DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text("Order #${order.orderId}",
                      style: TextStyle(color: Colors.grey[700])),
                  Text("Variant: ${item.variantName}",
                      style: TextStyle(color: Colors.grey[700])),
                  Text("Amount: ₹${order.finalAmount}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),

            // STATUS BADGE
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: _statusColor(getDisplayStatus(order)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getDisplayStatus(order),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Status color helper
Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case "paid":
    case "ordered":
    case "confirmed":
      return Colors.blue;
    case "processing":
    case "shipped":
      return Colors.orange;
    case "delivered":
      return Colors.green;
    case "cancel":
      return Colors.red;
    default:
      return Colors.grey;
  }
}

}
