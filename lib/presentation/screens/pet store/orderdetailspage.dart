import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/cart%20payment/storecheckoutservice.dart';
import 'package:pawlli/data/model/ordermodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/pet%20store/pet_storemain.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {

  final TextEditingController _reasonController = TextEditingController();
  bool isLoading = false;
  late String currentStatus;

    @override
  void initState() {
    super.initState();
    currentStatus = widget.order.orderStatus;
  }
  Future<void> _downloadInvoice() async {
  try {
    Get.snackbar("Please wait", "Downloading invoice...");

    await StoreCheckoutService.downloadInvoice(
      orderId: widget.order.orderId.toString(),
    );

    Get.snackbar("Success", "Invoice downloaded");

  } catch (e) {
    Get.snackbar("Error", "Failed to download invoice");
  }
}



void _showCancelDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Cancel Order"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please provide reason for cancellation"),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Enter reason",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_reasonController.text.trim().isEmpty) {
                Get.snackbar("Error", "Reason is required");
                return;
              }

              setState(() => isLoading = true);

              bool success = await StoreCheckoutService.cancelOrder(
                orderId: widget.order.orderId.toString(),
                reason: _reasonController.text.trim(),
              );


              setState(() => isLoading = false);

              if (success) {
                Navigator.pop(context);

                setState(() {
                  currentStatus = "Order Cancelled";
                });

                Get.snackbar("Success", "Order cancelled successfully");
              } else {
                Get.snackbar("Error", "Failed to cancel order");
              }
            },
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Confirm"),
          ),
        ],
      );
    },
  );
}


  Map<String, dynamic>? _parseAddress(String? rawAddress) {
  if (rawAddress == null || rawAddress.isEmpty) return null;

  try {
    final fixed = rawAddress.replaceAll("'", "\"");
    return jsonDecode(fixed);
  } catch (e) {
    return null;
  }
}

Widget _addressCard(String title, String? addressString) {
    final address = _parseAddress(addressString);

    if (address == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("No address provided"),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              address['name'] ?? "",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(address['phone'] ?? ""),
            // Text(address['email'] ?? ""),
            const SizedBox(height: 6),
            Text(address['address'] ?? ""),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final item = widget.order.items.first;

    return Scaffold(
      backgroundColor: Colors.white,
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(80),
  child: Stack(
    children: [
      // ✅ BACKGROUND IMAGE
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

      // ✅ APP BAR ON TOP
      AppBar(
        centerTitle: true,
        title: const Text("Order Details"),
        backgroundColor: Colors.transparent, // important
        foregroundColor: Colours.brownColour,
        elevation: 0,

        actions: [
  PopupMenuButton<String>(
    color: const Color.fromARGB(255, 251, 236, 210),

    onSelected: (value) {
      if (value == "cancel") {
        _showCancelDialog();
      } else if (value == "invoice") {
        _downloadInvoice();
      }
    },

    itemBuilder: (context) => [
      // ⭐ ALWAYS SHOW INVOICE
      const PopupMenuItem(
        value: "invoice",
        child: Text("Download Invoice"),
      ),

      // ⭐ SHOW CANCEL ONLY WHEN ALLOWED
      if (currentStatus.toLowerCase() != "order cancelled" &&
          currentStatus.toLowerCase() != "cancelled" &&
          currentStatus.toLowerCase() != "delivered")
        const PopupMenuItem(
          value: "cancel",
          child: Text("Cancel Order"),
        ),
    ],
  ),
],


      ),
    ],
  ),
),



      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info
            Column(
              children: widget.order.items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [

                      // ⭐ Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.productImages.first,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 40),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ⭐ Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Product Name
                            Text(
                              item.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Variant + Quantity in same row
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${item.variantName}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                Text(
                                  "Qty: ${item.quantity}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Divider(),

            // Payment and Order Info
            _infoRow("Order Status", currentStatus),
            _infoRow("Amount Paid", "₹${widget.order.finalAmount}"),
            _infoRow("Order Date", widget.order.createdAt.toString()),
            const SizedBox(height: 20),

            Divider(),

            // Shipping Address
            _addressCard("Shipping Address", widget.order.shippingAddress),
            Divider(),

            // Billing Address
            // _addressCard("Billing Address", widget.order.billingAddress),
            // const SizedBox(height: 100), // space for bottom button
          ],
        ),
      ),

      // BOTTOM BUTTON
            bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PetstorePage()),
                      
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colours.primarycolour,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Continue shopping...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
