import 'dart:convert' show jsonDecode;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart' ;
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/topupcontroller.dart';
import 'package:pawlli/data/controller/transactioncontroller.dart';
import 'package:pawlli/data/controller/walletbalancecontroller.dart';
import 'package:pawlli/data/model/topupmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:get/get.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:pawlli/presentation/screens/payment%20failure/payment_failure.dart';
import 'package:pawlli/presentation/screens/payment%20success/paymentsuccess.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class MyWalletPage extends StatefulWidget {
     final bool fromPaymentFlow;
       const  MyWalletPage({super.key, this.fromPaymentFlow = false});
  @override
  _MyWalletPageState createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage> {
   final WalletBalanceController walletController = Get.put(WalletBalanceController());
   final TransactionController transactionController = Get.put(TransactionController());
final TopUpController topUpController = Get.put(TopUpController());
 int? userId;
  String? user_id;
  int _selectedIndex = 0;
    String currentOrderId = "";
  late FocusNode myFocusNode;
  int? _selectedAmount;
 late Razorpay _razorpay;
  TextEditingController myController = TextEditingController();
  var isLoading = false.obs;
  var topUpResponse = Rxn<TopUPModel>();
  @override
  void initState() {
    super.initState();
     _razorpay = Razorpay();
    
    // Attach event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    myController = TextEditingController();
    myFocusNode = FocusNode();
    final storage = GetStorage();
    
    // Read user_id and ensure it's converted properly
    var storedUserId = storage.read(LocalStorageConstants.userId);

  if (storedUserId != null) {
      user_id = storedUserId.toString();  
      userId = int.tryParse(user_id!) ?? 0; // Convert to int safely
      print("✅ User ID Retrieved: $userId");
    } else {
      print("⚠️ Error: user_id is null or empty!");
    }

  if (userId != null) {
      walletController.fetchWalletBalance(userId!);
      transactionController.fetchUserTransactions(userId!);
    }
  }

  void _onAmountSelected(int amount) {
    setState(() {
      _selectedAmount = (_selectedAmount == amount) ? null : amount;
      myController.text = amount.toString();
    });
  }

  void _startRazorpayPayment(int amount) async {
  try {
    // Call backend via controller to create Razorpay order
    await topUpController.topUpWallet(
       userId: userId!,// Replace with actual userId (maybe from local storage)
      amount: amount.toDouble(),
      purpose: "Wallet",
    );

    final topUpData = topUpController.topUpResponse.value;

    if (topUpData == null || topUpData.orderId == null) {
      Get.snackbar("Error", "Failed to create order from server.");
      return;
    }

    currentOrderId = topUpData.orderId!;

    // Open Razorpay checkout
    var options = {
      'key':'rzp_live_hUYYZly69YfdVs',
      'amount': (amount * 100).toInt(), // Razorpay expects amount in paisa
      'currency': 'INR',
      'name': 'MyApp Wallet',
      'description': 'Wallet Top-up',
      'order_id': currentOrderId,
      'prefill': {
        'contact': '9876543210',
        'email': 'user@example.com'
      },
    };

    _razorpay.open(options);

  } catch (e) {
    debugPrint("❗ Error in _startRazorpayPayment: $e");
    Get.snackbar("Error", "Something went wrong while initiating payment.");
  }
}

void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  try {
    debugPrint("✅ Payment Successful:");
    debugPrint("  Payment ID: ${response.paymentId ?? 'N/A'}");
    debugPrint("  Order ID: ${response.orderId ?? 'N/A'}");
    debugPrint("  Signature: ${response.signature ?? 'N/A'}");

    Get.snackbar(
      "Success",
      "Payment Successful!",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colours.primarycolour,
      colorText: Colours.secondarycolour,
    );

    var verification = await ApiService.verifyPayment(
      razorpay_order_id: response.orderId ?? "",
      razorpay_payment_id: response.paymentId ?? "",
      razorpay_signature: response.signature ?? "",
    );

    debugPrint("🔄 Payment verification response: $verification");

    if (verification != null) {
      debugPrint("✅ Payment verification successful, refreshing wallet and transactions.");

      // ✅ Refresh wallet balance
      await walletController.fetchWalletBalance(userId!);

      // ✅ Refresh transaction history
      await transactionController.fetchUserTransactions(userId!);

      currentOrderId = "";

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Paymentsuccess(
            orderId: response.orderId ?? "",
            paymentId: response.paymentId ?? "",
            signature: response.signature ?? "",
          ),
        ),
      );
    } else {
      debugPrint("❌ Payment verification failed, navigating to failure page.");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Paymentfailure(
            orderId: response.orderId ?? "",
            paymentId: response.paymentId ?? "",
            signature: response.signature ?? "",
            paymentVerifiedModel: null,
          ),
        ),
      );
    }

  } catch (e) {
    debugPrint("❗ Error handling payment success: $e");
    Get.snackbar(
      "Error",
      "Payment processing error: $e",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colours.primarycolour,
      colorText: Colours.secondarycolour,
    );
  }
}

void _handlePaymentError(PaymentFailureResponse response) async {
  debugPrint("❌ Payment Failed: Code: ${response.code}, Message: ${response.message}");

  String orderId = currentOrderId.isNotEmpty ? currentOrderId : "N/A";
  String paymentId = "";
  String signature = "";

 try {
  if (response.message != null && response.message!.startsWith('{')) {
    Map<String, dynamic> errorData = jsonDecode(response.message!);
    orderId = errorData['razorpay_order_id'] ?? currentOrderId;
    paymentId = errorData['payment_id'] ?? "";
  }
} catch (e) {
  debugPrint("Error decoding response message: $e");
}


  debugPrint("❌ Payment Failure Details:");
  debugPrint("Order ID: $orderId");
  debugPrint("Payment ID: $paymentId");
  debugPrint("Signature: $signature");

  var verification = await ApiService.verifyPayment(
     razorpay_order_id: orderId,
   razorpay_payment_id: paymentId,
   razorpay_signature: signature,
  );

  debugPrint("🔄 Verification result: $verification");


  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Paymentfailure(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
        paymentVerifiedModel: verification, 
      ),
    ),
  );
}

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "💳 External Wallet Selected: ${response.walletName}");
  }
  @override
  Widget build(BuildContext context) {
   
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
return WillPopScope(
      onWillPop: () async {
        if (widget.fromPaymentFlow) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
            (route) => false,
          );
          return false;
        }
        return true;
      },
child:  Scaffold(
      body: SingleChildScrollView(
        child: Stack(
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
                AppBar(
                  title: Text(
                    'My Wallet',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.w600,
                      color: Colours.brownColour,
                    ),
                    
                  ),
                  foregroundColor: Colours.brownColour,
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
               SizedBox(height: screenHeight * 0.02),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
Obx(() {
  print("UI Wallet Balance: ${walletController.walletBalanceAmount.value}"); 

  String balance = walletController.walletBalanceAmount.value;
  double textWidth = (balance.length * 12).toDouble();

  return Align(
    alignment: Alignment.centerRight,
    child: Container(
  width: 250, 
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colours.primarycolour,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Balance:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colours.secondarycolour,
            ),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.currency_rupee,
            color: Colours.secondarycolour,
            size: 20,
          ),
          Flexible(
            child: Text(
              walletController.walletBalanceAmount.value, 
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colours.secondarycolour,
              ),
            ),
          ),
        ],
      ),
    ),
  );
})

,
           
            SizedBox(height: screenHeight * 0.02),
         SizedBox(height: screenHeight * 0.02),

// ✅ Top Up Section (removed Platform.isAndroid)
Text(
  'Top Up',
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
),
SizedBox(height: screenHeight * 0.02),
TextField(
  controller: myController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    hintText: 'Enter amount',
    border: OutlineInputBorder(),
  ),
),
SizedBox(height: screenHeight * 0.02),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [100, 500, 1000].map((amount) {
    return GestureDetector(
      onTap: () => _onAmountSelected(amount),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _selectedAmount == amount ? Colours.primarycolour : Colors.brown,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '₹$amount',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }).toList(),
),
SizedBox(height: 30),
Center(
  child: ElevatedButton(
    onPressed: () {
      int? amount = int.tryParse(myController.text);
      if (amount != null && amount > 0) {
        _startRazorpayPayment(amount);
      } else {
        Get.snackbar(
          "Error",
          "",
          backgroundColor: Colours.primarycolour,
          colorText: Colors.white,
          snackStyle: SnackStyle.FLOATING,
          messageText: Text(
            "Enter a valid amount",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    },
    child: Text(
      "Top Up",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colours.secondarycolour,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colours.primarycolour,
      fixedSize: Size(screenWidth * 0.8, screenHeight * 0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  ),
),


                SizedBox(height: screenHeight * 0.05),
                      Text(
                        'Transaction History',
                          style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Obx(() {
  if (transactionController.isLoading.value) {
    return Center(child: CircularProgressIndicator());
  }

  var transactions = transactionController.transactionData.value?.data ?? [];

  if (transactions.isEmpty) {
    return Center(child: Text("No transactions found"));
  }

return Card(
  color: Colours.seachbarcolour,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(10), 
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), 
        border: Border.all(color: Colors.black, width: 1), 
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide.none,
          outside: BorderSide(color: Colors.black, width: 1), 
        ),
    columnWidths: {
      0: FlexColumnWidth(2),
      1: FlexColumnWidth(2),
      2: FlexColumnWidth(2),
    },
    children: [
      TableRow(
        decoration: BoxDecoration(color: Colours.primarycolour),
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Date',
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  fontWeight: FontWeight.bold,
                  color: Colours.black,
                )),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Type',
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  fontWeight: FontWeight.bold,
                  color: Colours.black,
                )),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Amount',
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  fontWeight: FontWeight.bold,
                  color: Colours.black,
                )),
          ),
        ],
      ),
      ...transactions.map((transaction) {
        return TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 0.5), // Only horizontal lines
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                transaction.createdAt != null
                    ? DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.createdAt!)
                    : 'N/A',
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  fontWeight: FontWeight.w400,
                  color: Colours.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                transaction.transactionType ?? 'N/A',
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  fontWeight: FontWeight.w400,
                  color: (transaction.transactionType == "Credit") ? Colours.black : Colours.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("₹${transaction.amount ?? '0'}",
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.w400,
                    color: (transaction.transactionType == "deposit") ? Colors.green : Colors.red
                  )),
            ),
          ],
        );
      }).toList(),
    ],
  ))),
);

}),

                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
));
  }
}
