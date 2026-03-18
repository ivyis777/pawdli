// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/cart%20payment/couponservice.dart';
// import 'package:http/http.dart' as http;
import 'package:pawlli/data/cart%20payment/razorpaypaymentservice.dart';
import 'package:pawlli/data/cart%20payment/razorpayverifyservice.dart';
import 'package:pawlli/data/cart%20payment/storecheckoutservice.dart';
import 'package:pawlli/data/controller/storecheckoutcontroller.dart';
import 'package:pawlli/data/model/razorpaycreateordermodel.dart';
import 'package:pawlli/data/model/storeverifypaymentmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/pet%20store/addresslistpage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:pawlli/core/storage_manager/colors.dart';
// import 'package:pawlli/data/api service.dart';
// import 'package:pawlli/data/app url.dart';
import 'package:pawlli/data/controller/addresscontroller.dart';
import 'package:pawlli/data/controller/cartviewcontroller.dart';
// import 'package:pawlli/data/controller/transactioncontroller.dart';
import 'package:pawlli/data/controller/walletbalancecontroller.dart';
import 'package:pawlli/presentation/screens/payment failure/payment_failure.dart';
import 'package:pawlli/presentation/screens/pet store/myorders.dart';

class PlaceOrderPage extends StatefulWidget {
  final List<int> selectedCartIds;

  const PlaceOrderPage({super.key, required this.selectedCartIds});
  

  @override
  State<PlaceOrderPage> createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  final CartController cartController = Get.find<CartController>();
  final AddressController addressController = Get.find();
  final WalletBalanceController walletBalanceController = Get.find();
  // final TransactionController transactionController = Get.find();
  final StoreCheckoutController checkoutController = Get.find();


    // Coupon
final TextEditingController couponController = TextEditingController();
double couponDiscount = 0.0;
String? appliedCoupon;

// Payment Method
String selectedPaymentMethod = "razorpay"; // razorpay | wallet | cod



  late Razorpay _razorpay;

  final storage = GetStorage();
  String? userId;

  double walletBalance = 0.0;
  double usedWalletAmount = 0.0;
  bool useWallet = false;
  bool couponApplied = false;
  double payableAmount = 0.0;
  String? razorpayOrderId;
  double totalSavings = 0.0;


  @override
  void initState() {
    super.initState();

    userId = storage.read('user_id')?.toString() ??
        storage.read('userid')?.toString();

    if (userId != null) {
      walletBalanceController.fetchWalletBalance(int.parse(userId!));
    }

    // Razorpay Events
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);

    _calculateTotals();
  }

  @override
  void dispose() {
    couponController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  // ------------------- Subtotal -------------------
  double _calculateSubtotal() {
    return cartController.cartItems
        .where((e) => widget.selectedCartIds.contains(e.cartId))
        .fold(
            0.0,
            (sum, item) =>
                sum +
                (double.tryParse(item.priceAtAdded ?? "0") ?? 0.0) *
                    (item.quantity ?? 1));
  }
  // ================= SELECTED ITEMS HELPERS =================
List<int> cartIdsForPayment() {
  return widget.selectedCartIds;
}

double amountForSelectedItems() {
  return cartController.cartItems
      .where((e) => widget.selectedCartIds.contains(e.cartId))
      .fold(0.0, (sum, item) {
        final price = double.tryParse(item.priceAtAdded ?? "0") ?? 0.0;
        final qty = item.quantity ?? 1;
        return sum + (price * qty);
      });
}

double _calculateItemSavings() {
  return cartController.cartItems
      .where((e) => widget.selectedCartIds.contains(e.cartId))
      .fold(0.0, (sum, item) {
        final qty = item.quantity ?? 1;

        // 🔹 Regular / MRP price from variantDetails
        final mrp = double.tryParse(
              item.variantDetails?['regular_price']?.toString() ?? '0',
            ) ??
            0.0;

        // 🔹 Selling price (already in your model)
        final selling =
            double.tryParse(item.priceAtAdded ?? '0') ?? 0.0;

        if (mrp > selling) {
          return sum + ((mrp - selling) * qty);
        }
        return sum;
      });
}


  // ------------------- Wallet + Payable Logic -------------------
 void _calculateTotals() {
  double subtotal = _calculateSubtotal();

  // 1️⃣ Item-level savings
  double itemSavings = _calculateItemSavings();

  // 2️⃣ Wallet balance
  double wallet =
      double.tryParse(walletBalanceController.walletBalanceAmount.value) ?? 0.0;

  // 3️⃣ Wallet usage
  usedWalletAmount =
      (useWallet && wallet > 0)
          ? (wallet >= subtotal ? subtotal : wallet)
          : 0;

  // 4️⃣ Payable amount
  payableAmount = subtotal - usedWalletAmount - couponDiscount;
  if (payableAmount < 0) payableAmount = 0;

  // 5️⃣ Total savings
  totalSavings = itemSavings + couponDiscount + usedWalletAmount;

  // 🔴 COD rule
  if (payableAmount > 500 && selectedPaymentMethod == "cod") {
    selectedPaymentMethod = "razorpay";
  }

  setState(() {});
}



void _applyCoupon() async {
  if (couponApplied) return;

  final code = couponController.text.trim().toUpperCase();
  if (code.isEmpty) return;

  final coupon = await CouponService.getCouponByCode(code);

  if (coupon == null) {
    Fluttertoast.showToast(msg: "Invalid coupon");
    return;
  }

  final subtotal = _calculateSubtotal();

  // 🔴 Minimum order validation
  if (coupon.minOrderAmount != null &&
      subtotal < coupon.minOrderAmount!) {
    Fluttertoast.showToast(
        msg:
            "Minimum order ₹${coupon.minOrderAmount} required");
    return;
  }

  double discount = 0.0;

  // ✅ Percentage coupon
  if (coupon.discountType == "percentage") {
    discount = subtotal * (coupon.discountValue / 100);

    if (coupon.maxDiscountAmount != null &&
        discount > coupon.maxDiscountAmount!) {
      discount = coupon.maxDiscountAmount!;
    }
  }

  // ✅ Flat coupon
  if (coupon.discountType == "flat") {
    discount = coupon.discountValue;
  }

  setState(() {
    couponApplied = true;
    appliedCoupon = coupon.code;
    couponDiscount = discount;
  });

  Fluttertoast.showToast(msg: "Coupon Applied");
  _calculateTotals();
}


void _removeCoupon() {
  setState(() {
    couponApplied = false;
    couponDiscount = 0.0;
    appliedCoupon = null;
    couponController.clear();
  });

  _calculateTotals();
}


  // // ================================================================
  // // 🔥 FULL WALLET PAYMENT
  // // ================================================================
  // Future<void> _payUsingWalletOnly() async {
  //   final uid = int.tryParse(userId ?? "0") ?? 0;
  //   final accessToken = await ApiService.getAccessToken();

  //   if (accessToken == null) {
  //     Fluttertoast.showToast(msg: "Authentication failed");
  //     return;
  //   }

  //   final selectedAmount = amountForSelectedItems();

  //   final body = {
  //     "user_id": uid,
  //     "cart_ids": cartIdsForPayment(),
  //     "wallet_amount_used": selectedAmount,
  //     "currency": "INR",
  //     "amount": selectedAmount.toStringAsFixed(2),
  //     "purpose": "PetStore",
  //     "payment_mode": "Wallet",
  //     "shipping_address": addressController.selectedAddress.value?.address ?? "",
  //     "billing_address": addressController.selectedAddress.value?.address ?? "",
  //   };

  //   final response = await http.post(
  //     Uri.parse(AppUrl.paythroughwalletUrl),
  //     headers: {
  //       "Authorization": "Bearer $accessToken",
  //       "Content-Type": "application/json",
  //     },
  //     body: jsonEncode(body),
  //   );

  //   debugPrint("💰 WALLET PAYMENT RESPONSE: ${response.body}");

  //   final data = jsonDecode(response.body);

  //   if (response.statusCode == 200 && data["status"] == "success") {
  //     Fluttertoast.showToast(msg: "Order placed successfully!");

  //     await walletBalanceController.fetchWalletBalance(uid);
  //     await cartController.loadCart();
  //     await transactionController.fetchUserTransactions(uid);

  //     Get.to(() => OrdersPage());
  //   } else {
  //     Fluttertoast.showToast(msg: "Wallet payment failed");
  //   }
  // }

  // // ================================================================
  // // 🔥 CREATE ORDER (Razorpay)
  // // ================================================================
  // Future<void> _createRazorpayOrder() async {
  //   final uid = int.tryParse(userId ?? "0") ?? 0;
  //   final accessToken = await ApiService.getAccessToken();

  //   final body = {
  //     "user_id": uid,
  //     "cart_ids": cartIdsForPayment(),
  //     "wallet_amount_used": usedWalletAmount,
  //     "amount": payableAmount.toStringAsFixed(2),
  //     "currency": "INR",
  //     "purpose": "PetStore",
  //     "payment_mode": "Razorpay",
  //     "shipping_address": addressController.selectedAddress.value?.address ?? "",
  //     "billing_address": addressController.selectedAddress.value?.address ?? "",
  //   };

  //   final response = await http.post(
  //     Uri.parse(AppUrl.OrderCreationURL),
  //     headers: {
  //       "Authorization": "Bearer $accessToken",
  //       "Content-Type": "application/json",
  //     },
  //     body: jsonEncode(body),
  //   );

  //   debugPrint("🧾 ORDER CREATE RESPONSE: ${response.body}");

  //   final data = jsonDecode(response.body);

  //   razorpayOrderId = data["razorpay_order_id"]?.toString() ?? "";

  //   if (razorpayOrderId == null || razorpayOrderId!.isEmpty) {
  //     Fluttertoast.showToast(msg: "Failed to create Razorpay order");
  //     return;
  //   }

  //   _openRazorpayCheckout(payableAmount);
  // }

  // // ================================================================
  // // 🔥 OPEN RAZORPAY CHECKOUT
  // // ================================================================
  // void _openRazorpayCheckout(double amount) {
  //   final int amountPaise = (amount * 100).round();

  //   final options = {
  //     "key": "rzp_live_hUYYZly69YfdVs",
  //     "amount": amountPaise,
  //     "currency": "INR",
  //     "order_id": razorpayOrderId,
  //     "name": "Pawlli",
  //     "description": "Pet Store Order",
  //   };

  //   debugPrint("Opening Razorpay Checkout: $options");

  //   _razorpay.open(options);
  // }

  // ================================================================
  // 🔥 PAYMENT SUCCESS
  // ================================================================
Future<void> _onPaymentSuccess(PaymentSuccessResponse res) async {
  final checkoutRes = checkoutController.checkoutResponse;

  if (checkoutRes == null) {
    Fluttertoast.showToast(msg: "Payment verification failed");
    return;
  }

  final verify = await RazorpayVerifyService.verifyPayment(
    RazorpayVerifyRequestModel(
      paymentTransactionId:
          checkoutRes.paymentTransactionId.toString(),
      razorpayOrderId: res.orderId!,
      razorpayPaymentId: res.paymentId!,
      razorpaySignature: res.signature!,
    ),
  );

  if (verify.paymentStatus == "success") {
    Fluttertoast.showToast(msg: "Order placed successfully");
    await cartController.loadCart();
    await walletBalanceController.fetchWalletBalance(int.parse(userId!));
    Get.to(() => OrdersPage());
  }
}



  // ================================================================
  // 🔥 PAYMENT FAILURE
  // ================================================================
  void _onPaymentError(PaymentFailureResponse res) async {

    final checkoutRes = checkoutController.checkoutResponse;

    if (checkoutRes != null) {
      try {
        await StoreCheckoutService.cancelOrder(
          orderId: checkoutRes.orderId.toString(),
          reason: "Payment failed",
        );
      } catch (e) {
        print("Cancel order failed: $e");
      }
    }

    Fluttertoast.showToast(msg: "Payment Failed");

    Get.to(() => Paymentfailure(
          orderId: razorpayOrderId ?? "",
          paymentId: "",
          signature: "",
          paymentVerifiedModel: null,
        ));
  }

  void _startRazorpay({
  required String transactionId,
  required double amount,
}) async {
  final razorpayOrder =
      await RazorpayPaymentService.createRazorpayOrder(
    RazorpayCreateRequestModel(
      paymentTransactionId: transactionId,
      amount: amount,
    ),
  );

  razorpayOrderId = razorpayOrder.razorpayOrderId;

  _razorpay.open({
    "key": "rzp_live_hUYYZly69YfdVs",
    "amount": (amount * 100).toInt(),
    "currency": "INR",
    "order_id": razorpayOrder.razorpayOrderId,
    "name": "Pawlli",
    "description": "Pet Store Order",
  });
}


  // ================================================================
  // 🔥 PROCEED BUTTON LOGIC
  // ================================================================
 void _onProceed() async {
  if (addressController.selectedAddress.value == null) {
    Fluttertoast.showToast(msg: "Please select address");
    return;
  }

  // 🔴 COD validation
  if (selectedPaymentMethod == "cod" && payableAmount > 1500) {
    Fluttertoast.showToast(
        msg: "Cash on Delivery available only below ₹1500");
    return;
  }

  // 🔴 COD confirmation
  if (selectedPaymentMethod == "cod") {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Cash on Delivery"),
        content: const Text(
          "You will pay cash when the order is delivered.\n\nDo you want to continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm != true) return;
  }

  // 🔥 Checkout API
  final selectedAddress = addressController.selectedAddress.value;

await checkoutController.checkout(
  cartItems: widget.selectedCartIds,
  paymentMethod: selectedPaymentMethod,
  useWallet: useWallet,
  walletAmountUsed: usedWalletAmount, 
  couponCode: appliedCoupon,
  shippingAddress: {
    "name": selectedAddress?.name,
    "phone": selectedAddress?.phone,
    "email": selectedAddress?.email,
    "address": selectedAddress?.address,
  },
);
  final res = checkoutController.checkoutResponse;
  if (res == null) return;

  // ✅ CASE 1: COD success
  if (selectedPaymentMethod == "cod") {
  Fluttertoast.showToast(msg: "Order placed (Cash on Delivery)");
  await cartController.loadCart();
  await walletBalanceController.fetchWalletBalance(int.parse(userId!)); // ⭐ ADD
  Get.offAll(() => OrdersPage());
  return;
}


  // ✅ CASE 2: Wallet + Coupon fully paid (NO Razorpay)
  if ((res.razorpayRequired ?? 0) <= 0) {
  Fluttertoast.showToast(msg: res.message ?? "Order placed");
  await cartController.loadCart();
  await walletBalanceController.fetchWalletBalance(int.parse(userId!)); // ⭐ ADD
  Get.to(() => OrdersPage());
  return;
}


  // 🟠 CASE 3: Razorpay required (> 0 only)
  _startRazorpay(
    transactionId: res.paymentTransactionId.toString(),
    amount: res.razorpayRequired!,
  );
}



  // ================================================================
  // 🔥 UI
  // ================================================================
  @override
  Widget build(BuildContext context) {
    double subtotal = _calculateSubtotal();

    return Scaffold(
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

            // ✅ APP BAR ON TOP (Back button visible)
            AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent, 
              foregroundColor: Colors.black,

              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              ),

              title: const Text(
                "Place Order",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),

      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          
        addressSection(),



// ---------------- SELECTED CART ITEMS LIST ----------------
Obx(() {
  final selectedItems = cartController.cartItems
      .where((e) => widget.selectedCartIds.contains(e.cartId))
      .toList();

  if (selectedItems.isEmpty) {
    return const SizedBox();
  }

  return Card(
    elevation: 9,
    color: const Color.fromARGB(255, 251, 236, 210),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedItems.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = selectedItems[index];
              final image = item.variantImage ?? item.productImage ?? "";
              final qty = item.quantity ?? 1;
              final price = item.priceAtAdded ?? "0";

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      image,
                      width: 70,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // NAME + VARIANT + QTY
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.storeProductName ?? "Product",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.variantName ?? "Variant",
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text("Quantity: $qty"),
                      ],
                    ),
                  ),

                  // PRICE
                  Text( 
                    "₹$price",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  )
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}),

          const SizedBox(height: 20),
          // paymentMethodSection(),
          // const SizedBox(height: 5),
          couponSection(),
          const SizedBox(height: 10),
          


          Container(
            // child: Card(
              // color: const Color.fromARGB(244, 245, 242, 233),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    _priceRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
                    _priceRow("Wallet Used", "-₹${usedWalletAmount.toStringAsFixed(2)}"),
                    _priceRow("Coupon Discount", "-₹${couponDiscount.toStringAsFixed(2)}"),
                    _priceRow("Delivery Charges", "₹0.00"),

                    // ✅ TOTAL SAVINGS
        if (totalSavings > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Savings",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "₹${totalSavings.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
                    const Divider(),
                    _priceRow("PAYABLE", "₹${payableAmount.toStringAsFixed(2)}",
                        bold: true),
                  ],
                ),
              ),
            // ),
          ),

          const SizedBox(height: 1),

         Obx(() {
  walletBalance = double.tryParse(
          walletBalanceController.walletBalanceAmount.value) ??
      0.0;

  final bool walletEnabled = selectedPaymentMethod != "cod";

  return SwitchListTile(
    value: walletEnabled ? useWallet : false,
    activeColor: Colors.blue,
    title: Text(
      "Use Wallet (₹${walletBalance.toStringAsFixed(2)})",
      style: TextStyle(
        color: walletEnabled ? Colors.black : Colors.grey,
      ),
    ),
    onChanged: walletEnabled
        ? (v) {
            setState(() {
              useWallet = v;
              _calculateTotals();
            });
          }
        : null, // 🔒 DISABLE when COD
  );
}),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: 
              Obx(() => ElevatedButton(
                onPressed: checkoutController.isLoading.value ? null : _onProceed,
                style: ElevatedButton.styleFrom(
                backgroundColor: Colours.primarycolour,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
                child: checkoutController.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        payableAmount == 0
                            ? "PAY USING WALLET"
                            : selectedPaymentMethod == "cod"
                                ? "PROCEED"
                                : "PAY ₹${payableAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                              ),
                      ),
              )),
          ),
        ]),
      ),
    );
  }

  // ---------------- ADDRESS TILE ----------------
Widget addressSection() {
  return Obx(() {
    final addr = addressController.selectedAddress.value;

    return Card(
      color: const Color.fromARGB(255, 251, 236, 210),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 9,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Deliver To",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                GestureDetector(
                  onTap: () async {
                    final result = await Get.to(() => AddressListPage());
                    if (result == true) setState(() {});
                  },
                  child: const Text(
                    "Change Delivery Address",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            addr == null
                ? const Text("No address selected",
                    style: TextStyle(color: Colors.grey))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(addr.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(addr.phone),
                      Text(addr.email),
                      const SizedBox(height: 6),
                      Text(addr.address),
                    ],
                  )
          ],
        ),
      ),
    );
  });
}



  // ---------------- PRICE ROW ----------------
  Widget _priceRow(String a, String b, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        Text(b, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
      ],
    );
  }

  // ===============================Coupon Code Widget===============================

  Widget couponSection() {
  return Container(
    padding: const EdgeInsets.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Apply Coupon",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: couponController,
          readOnly: couponApplied,
          decoration: InputDecoration(
            hintText: "Enter coupon code",
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // APPLY
                if (!couponApplied)
                  TextButton(
                    onPressed: _applyCoupon,
                    child: Text(
                      "APPLY",
                      style: TextStyle(
                        color: Colours.primarycolour,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // REMOVE
                if (couponApplied)
                  TextButton(
                    onPressed: _removeCoupon,
                    child: const Text(
                      "REMOVE",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (couponApplied)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Coupon applied: -₹${couponDiscount.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    ),
  );
}



Widget paymentMethodSection() {
  final codEnabled = payableAmount <= 500;
  
final String codTitle = codEnabled
    ? "Cash on Delivery"
    : "Cash on Delivery (upto ₹500 only)";

  return Card(
    color: const Color.fromARGB(255, 251, 236, 210),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 9,
    child: Column(
      children: [
        RadioListTile<String>(
          value: "razorpay",
          groupValue: selectedPaymentMethod,
          activeColor: Colors.blue,
          onChanged: (v) {
            if (v == null) return;
            setState(() => selectedPaymentMethod = v);
          },
          title: const Text("Payment"),
        ),
  
        RadioListTile<String>(
  value: "cod",
  groupValue: selectedPaymentMethod,
  activeColor: Colors.blue,
  toggleable: false,
  onChanged: codEnabled
      ? (v) {
          if (v == null) return;
          setState(() {
            selectedPaymentMethod = v;
            useWallet = false;
            _calculateTotals();
          });
        }
      : null,
  title: Text(
    codTitle,
    style: TextStyle(
      color: codEnabled ? Colors.black : Colors.grey,
    ),
  ),
  ),
  
      ],
    ),
  );
}

}
