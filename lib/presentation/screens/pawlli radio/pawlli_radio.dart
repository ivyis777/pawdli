import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/data/controller/listernerpaythroughwallet.dart';
import 'package:pawlli/data/controller/programlistcontroller.dart';
import 'package:pawlli/data/controller/walletbalancecontroller.dart';
import 'package:pawlli/data/model/ordercraetionmodel.dart';
import 'package:pawlli/data/model/paymentverificationmodel.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/agora/videocallpage.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:pawlli/presentation/screens/pawlli%20radio/streamvideopage.dart';
import 'package:pawlli/presentation/screens/slots/slots_and_time.dart';
import 'package:pawlli/presentation/slotpaymentverificationpage/paymentfailure.dart';
import 'package:pawlli/presentation/slotpaymentverificationpage/paymentsuccess.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' hide Data;

class PawlliRadio extends StatefulWidget {
  final int? radioid;
   final bool fromPaymentFlow;
   final String radioname;
  const PawlliRadio({super.key, required this.radioid,required this.radioname, this.fromPaymentFlow = false});

  @override
  State<PawlliRadio> createState() => _PawlliRadioState();
}

class _PawlliRadioState extends State<PawlliRadio> {
  
   final ProgramController programController = Get.put( ProgramController ());
    PaymentVerificationModel paymentVerifiedModel = PaymentVerificationModel();
      final WalletBalanceController walletBalanceController = Get.put(WalletBalanceController());
      final ListenerPaythroghwalletController walletController = Get.put(ListenerPaythroghwalletController());
        
  late Razorpay _razorpay;
   String? user_id; 
    int?userId;
    
    bool _isLoading = false;
    int? _sessionId;
 Map<int, DateTime> _programStartTimes = {};
   Map<int, bool> _hostHasJoined = {};
    String currentOrderId = "";
  String? _orderId; // Store Order ID
   DateTime _selectedDate = DateTime.now();
   Timer? _hostStatusTimer; 
  @override
  void initState() {
    super.initState();
    Get.put(ProgramController());
  Get.put(WalletBalanceController());
  Get.put(ListenerPaythroghwalletController());
  WidgetsBinding.instance.addPostFrameCallback((_) {
      String todayDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
        final storage = GetStorage();
  userId= storage.read(LocalStorageConstants.userId); 
      programController.loadProgramList(  userId! ,widget.radioid!, todayDate);

    _startPollingHostStatus();
    });
    _razorpay = Razorpay();

    // Register event handlers
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  final storage = GetStorage();
  user_id = storage.read(LocalStorageConstants.userId)?.toString(); 

  if (user_id == null || user_id!.isEmpty) {
    print("⚠️ Error: user_id is null or empty!");
  } else {
    print("User ID Retrieved: $user_id");
  }
}


void _startPollingHostStatus() {
  _hostStatusTimer = null;
  _hostStatusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
    if (!mounted) {
      timer.cancel();
      return;
    }
    _checkAllHostStatuses();
  });
}



Future<void> _checkAllHostStatuses() async {
    if (!mounted) return;  // prevent crash
  final programController = Get.find<ProgramController>();

  for (var program in programController.programDataList) {
    if (program.bookingId == null) continue;
    if (program.isHost != true) continue; // only consider host programs

    final bookingId = program.bookingId!;
    final programDate = program.date ?? '';
    final programSlotTime = program.slotTime ?? '';

    final startParsed = _parseStartTime(programDate, programSlotTime);
    if (startParsed != null) {
      _programStartTimes[bookingId] = startParsed;
    }

    final started = isProgramStarted(programDate, programSlotTime, bookingId);

        if (!mounted) return; // prevent calling setState after dispose


        setState(() {
      _hostHasJoined[bookingId] = started;
    });
    
  }
}


DateTime? _parseStartTime(String date, String timeRange) {
  try {
    if (date.trim().isEmpty || timeRange.trim().isEmpty) throw FormatException('Empty date or timeRange');
    final startTimeStr = timeRange.split('-').first.trim(); // e.g. "15:00"
    final combined = "$date $startTimeStr"; // e.g. "2025-06-04 15:00"
    final format = DateFormat("yyyy-MM-dd HH:mm");
    final parsed = format.parseStrict(combined).toLocal();
    // debugPrint("✅ Parsed local start time: $parsed");
    return parsed;
  } catch (e) {
    debugPrint("❌ Failed to parse start time ($date, $timeRange): $e");
    return null;
  }
}

DateTime? _parseEndTime(String date, String timeRange) {
  try {
    if (date.trim().isEmpty || timeRange.trim().isEmpty) throw FormatException('Empty date or timeRange');
    final endTimeStr = timeRange.split('-').last.trim();
    final combined = "$date $endTimeStr";
    final format = DateFormat("yyyy-MM-dd HH:mm");
    final parsed = format.parseStrict(combined).toLocal();
    // debugPrint("✅ Parsed local end time: $parsed");
    return parsed;
  } catch (e) {
    debugPrint("❌ Failed to parse end time ($date, $timeRange): $e");
    return null;
  }
}



bool isProgramExpired(String date, String timeRange) {
  try {
    final end = _parseEndTime(date, timeRange);
    if (end == null) return true; // if can't parse, consider expired
    return DateTime.now().isAfter(end);
  } catch (e) {
    debugPrint("isProgramExpired error: $e");
    return true;
  }
}

bool isProgramStarted(String date, String timeRange, int bookingId) {
  final start = _programStartTimes[bookingId] ?? _parseStartTime(date, timeRange);
  final end = _parseEndTime(date, timeRange);
  final now = DateTime.now();

  // debugPrint("⏰ Now: $now, Start: $start, End: $end for bookingId $bookingId");

  if (start == null || end == null) {
    return false;
  }

  // inclusive check: started if now >= start and now <= end
  return !now.isBefore(start) && !now.isAfter(end);
}



void showStartTimePopup(String startTime, String date) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismiss on outside tap or back button
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Session Not Started",
          style: TextStyle(
            fontSize: 22,         // Bigger font for title
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "The session starts at $startTime on $date.",
          style: TextStyle(
            fontSize: 18,        // Bigger font for content
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Only closes dialog on OK tap
            child: Text(
              "OK",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      );
    },
  );
}
    @override
  void dispose() {
    _razorpay.clear(); // Cleanup
    super.dispose();
    _hostStatusTimer?.cancel();
  }
Future<void> createOrder(
  String programName, 
  String programDescription, 
  String amount, 
  dynamic languages, 
  String date,
  String programType, 
  String? bookingId,
) async {
  // Validate user ID
  if (user_id == null) {
    Fluttertoast.showToast(msg: "User ID not found! Please login again.");
    return;
  }

  // Handle free slots (amount = 0)
  if (amount == "0" || amount == "0.0" || amount == "0.00" || amount == "₹0.00") {
    Get.snackbar(
      "Success",
      "🎉 Slot booked successfully!",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colours.primarycolour,
      colorText: Colours.brownColour,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );

    Map<String, dynamic> freeOrderData = {
      "amount": amount,
      "currency": "INR",
      "booking_id": bookingId,
      "purpose": "Listener",
      "receipt": "receipt_${DateTime.now().millisecondsSinceEpoch}",
      "program_name": programName,
      "program_description": programDescription,
      "language": languages is List<String> ? languages : [languages],
      "date": date,
      "program_type": programType,
      "user_id": user_id,
      "is_free": true,
    };

    try {
      var response = await http.post(
        Uri.parse(AppUrl.OrderCreationURL),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(freeOrderData),
      );

      print("📩 Free slot booking response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PawlliRadio(
              radioid: widget.radioid,
              radioname: widget.radioname,
              fromPaymentFlow: true,
            ),
          ),
        );
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['error'] ?? responseData['message'] ?? "Something went wrong.";
        Fluttertoast.showToast(msg: "Error: $errorMessage");
      }
    } catch (e) {
      print("❌ Exception booking free slot: $e");
      Fluttertoast.showToast(msg: "Failed to book slot. Please try again.");
    }
    return; // Exit for free slots
  }

  Map<String, dynamic> orderData = {
    "amount": amount,
    "currency": "INR",
    "booking_id": bookingId,
    "purpose": "Listener",
    "receipt": "receipt_${DateTime.now().millisecondsSinceEpoch}",
    "program_name": programName,
    "program_description": programDescription,
    "language": languages is List<String> ? languages : [languages],
    "date": date,  // Pass the date parameter here
    "program_type": programType,  // Pass the programType parameter here
    "user_id": user_id,

  };
String requestUrl = AppUrl.OrderCreationURL;
try {
  print("📌 Sending request to: $requestUrl");
  print("📤 Request Body: ${jsonEncode(orderData)}");

  var response = await http.post(
    Uri.parse(requestUrl),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: jsonEncode(orderData),
  );
  print("📩 Response Status Code: ${response.statusCode}");
  print("📩 Response Body: ${response.body}");

  final responseData = json.decode(response.body);

  // ✅ Deserialize into your model
  final order = OrderCreationModel.fromJson(responseData);
  _orderId = order.razorpayOrderId ?? "";
  currentOrderId = order.razorpayOrderId.toString();

  if (_orderId!.isNotEmpty) {
    print("📦 Razorpay Order ID: $_orderId");
  }

  // ✅ Handle response success
  if (response.statusCode == 200 || response.statusCode == 201) {
    if (_orderId!.isNotEmpty) {
      print("✅ Order created successfully: $_orderId");
      openCheckout();
    } else {
      Fluttertoast.showToast(msg: "Order ID missing. Try again.");
    }
  } else {
    // ⚠️ Use fallback message handling
    final errorMessage = responseData['error'] ?? responseData['message'] ?? "Unknown error occurred.";
    print("⚠️ API Error: $errorMessage");

    Fluttertoast.showToast(msg: "Error: $errorMessage");

    // Optional: store order ID for later reference
    if (_orderId!.isNotEmpty) {
      print("💾 Saving failed order ID: $_orderId");
      // GetStorage().write('lastFailedOrderId', _orderId);
    }
  }
} catch (e) {
  print("🚨 Exception during order creation: $e");
  Fluttertoast.showToast(msg: "Failed to create order. Check internet.");
}

  }
void openCheckout() {
  if (_orderId == null || _orderId!.isEmpty) {
    Fluttertoast.showToast(msg: "Order ID is missing. Please try again.");
    return;
  }

  String generatedReceipt = "receipt_${DateTime.now().millisecondsSinceEpoch}";
 

  var options = {
    'key': 'rzp_live_hUYYZly69YfdVs',
    'amount': 0.1,
    'currency': 'INR',
    'purpose': 'Listener',
    'order_id': _orderId,
    'name': 'Pawlli',
    'description': "",
    'prefill': {
      'contact': '1234567890',
      'email': 'user@example.com',
    },
  };

  try {
    _razorpay.open(options);
  } catch (e) {
    debugPrint(' Razorpay open error: $e');
    Fluttertoast.showToast(msg: "Payment failed. Please try again.");
  }
}



void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  try {
    debugPrint(" Payment Successful:");
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

    debugPrint(" Sending payment verification request to backend...");

    // Verify the payment with your backend
    var verification = await ApiService.verifyPayment(
     razorpay_order_id: response.orderId ?? "",
      razorpay_payment_id: response.paymentId ?? "",
     razorpay_signature: response.signature ?? "",
    );

    debugPrint(" Payment verification response: $verification");

    if (verification != null) {
      debugPrint(" Payment verification successful, navigating to success page.");
      debugPrint(" Final Verified Details:");
      debugPrint("  Payment ID: ${response.paymentId ?? 'N/A'}");
      debugPrint("  Order ID: ${response.orderId ?? 'N/A'}");
      debugPrint("  Signature: ${response.signature ?? 'N/A'}");

      currentOrderId = ""; // Clear stored order ID after successful payment

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlotPaymentsuccess(
            orderId: response.orderId ?? "",
            paymentId: response.paymentId ?? "",
            signature: response.signature ?? "",
                   radioid: widget.radioid,
                   radioname: widget.radioname,
          ),
        ),
      );
    } else {
      debugPrint("❌ Payment verification failed, navigating to failure page.");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlotPaymentfailure(
            orderId: response.orderId ?? "",
            paymentId: response.paymentId ?? "",
            signature: response.signature ?? "",
            paymentVerifiedModel: null,
                   radioid: widget.radioid,
                     radioname: widget.radioname,
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
      colorText: Colours.seachbarcolour,
    );
  }
}


void _handlePaymentError(PaymentFailureResponse response) async {
  debugPrint("❌ Payment Failed: Code: ${response.code}, Message: ${response.message}");

  String orderId = currentOrderId.isNotEmpty ? currentOrderId : "N/A";
  String paymentId = "";
  String signature = "";

  try {
    final errorData = _parseJsonSafely(response.message);
    orderId = errorData?['razorpay_order_id'] ?? currentOrderId;
    paymentId = errorData?['payment_id'] ?? "";
  } catch (e) {
    debugPrint("Error decoding response message: $e");
  }
  print("Order ID: $currentOrderId");
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
          builder: (context) => SlotPaymentfailure(
    orderId: orderId,
    paymentId: paymentId,
    signature: signature,
    paymentVerifiedModel: verification,
    radioid: widget.radioid,
    radioname:widget.radioname
  )));
}

void _handleExternalWallet(ExternalWalletResponse response) {
  Fluttertoast.showToast(msg: "💳 External Wallet Selected: ${response.walletName}");
}




Map<String, dynamic>? _parseJsonSafely(String? jsonString) {
  try {
    if (jsonString != null && jsonString.trim().startsWith('{')) {
      return jsonDecode(jsonString);
    }
  } catch (e) {
    debugPrint("JSON parsing error: $e");
  }
  return null;
}

DateTime _parseProgramTime(String date, String timeStr) {
  if (date.isEmpty || timeStr.isEmpty) {
    throw FormatException("Date or time cannot be empty: $date $timeStr");
  }

  try {
    // Trim and normalize the time string to ensure no leading/trailing spaces
    final normalizedTime = timeStr.trim();
    if (normalizedTime.length < 5) {
      throw FormatException("Invalid time format: $normalizedTime");
    }

    // Combine date and time into a single string
    final combined = "$date ${normalizedTime}";
    print("🔧 Parsing: $combined");

    // Use 24-hour format (HH:mm) for time parsing
    final format = DateFormat("yyyy-MM-dd HH:mm");
    return format.parseStrict(combined);
  } catch (e) {
    print("❌ Failed parsing: $e");
    throw FormatException("Invalid date/time: $date $timeStr");
  }
}







   Future<void> _fetchSlotsForSelectedDay() async {
    String selectedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final storage = GetStorage();
  userId= storage.read(LocalStorageConstants.userId); 
  
    programController.loadProgramList(userId!,  widget.radioid!, selectedDate);
  }

  // Date picker method
  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Show current selected date
      firstDate: DateTime.now(), // Allow selecting today and onwards
      lastDate: DateTime(2100), // Set a far future year for "infinite"
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _fetchSlotsForSelectedDay(); // Fetch slots for selected date
      });
    }
  }
  Future<void> createOrderThroughWallet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String amount,
  required dynamic languages,
  required String date,
  required String programType,
  required String bookingId,
}) async {
  await Get.find<ListenerPaythroghwalletController>().initiatelisternerPayment(
    amount: amount,
    currency: "INR",
    bookingId: bookingId,
    purpose: "Listener",
    receipt: "receipt_${DateTime.now().millisecondsSinceEpoch}",
    programName: title,
    programDescription: subtitle,
    language: languages is List<String> ? languages : [languages],
    date: date,
    programType: programType,
    userId: userId.toString(),
  );

  final result = Get.find<ListenerPaythroghwalletController>().paymentResult.value;

   if (result?.message == "Insufficient wallet balance.") {
    Get.snackbar(
      "Insufficient Balance",
      "You don’t have enough wallet balance to complete this transaction.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
    return;
  }

  if (result != null && result.status == "success") {
    Get.snackbar(
      "Success",
      "Thanks for booking the slot!",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
 Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PawlliRadio(radioid: widget.radioid,radioname: widget.radioname,fromPaymentFlow: true,),
        ),
      );
  } else {
    Get.showSnackbar(
    GetSnackBar(
    title: "Error",
    message: result?.message ?? "Payment failed",
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 3),
  ),
);

  }
}


TimeOfDay _parseTimeFromSlot(String slotTime) {
  try {
    final timePart = slotTime.split('-').first.trim();
    final cleanedTime = timePart.replaceAll('.', ':').replaceAll(' ', '');
    final parts = cleanedTime.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts.length > 1 ? parts[1] : '0'),
    );
  } catch (e) {
    return TimeOfDay.now(); // fallback if parsing fails
  }
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
      
      backgroundColor: Colours.primarycolour,
      appBar: AppBar(
        backgroundColor: Colours.primarycolour,
        title: Text(
          "Pawlli Radio",
          style: TextStyle(
            color: Colours.brownColour,
            fontSize: screenHeight * 0.027,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.Cairo,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: EdgeInsets.all(screenWidth * 0.04),
                height: screenHeight * 0.20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/heartimage.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: screenHeight * 0.20),
                  Padding(
                    padding: EdgeInsets.only(left: 10,right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TimeSlotPage(radioid: widget.radioid,radioname:widget.radioname)),
                            );
                          },
                          child: Text(
                            "Book A Slot",
                            style: TextStyle(
                              color: Colours.seachbarcolour,
                              fontSize: screenHeight * 0.02,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontFamily.Cairo,
                            ),
                          ),
                        ),
                       
                    Row(
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                            style: TextStyle(
                              color: Colours.brownColour,
                              fontSize: screenHeight * 0.022,
                              fontWeight: FontWeight.w600,
                              fontFamily: FontFamily.Cairo,
                            ),
                          ),
                          SizedBox(width: 10), // Space between date and icon
                          CircleAvatar(
                            backgroundColor: Colours.brownColour,
                            child: IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                color: Colours.secondarycolour,
                              ),
                              onPressed: () {
                                _selectDate(context); // Show date picker when clicked
                              },
                            ),
                    
                     )  ],
                    ),
                 ] ),
               ) ],
              ),
            ],
          ),
    SizedBox(height: screenHeight * 0.01),

          // Song List Section
    Expanded(
  child: Container(
    padding: EdgeInsets.all(screenWidth * 0.04),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: Obx(() {
      if (programController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Check for null or empty program list
      final programList = programController.programList.value?.data;
      if (programList == null || programList.isEmpty) {
        return Center(
          child: Text(
            "No programs available for selected date",
            style: TextStyle(
              color: Colours.black,
              fontSize: screenHeight * 0.02,
              fontWeight: FontWeight.w500,
              fontFamily: FontFamily.Cairo,
            ),
          ),
        );
      }

      // Filter out expired programs and sort by date/time
      final activePrograms = programList
          .where((program) =>
              program.date != null &&
              program.slotTime != null &&
              !isProgramExpired(program.date ?? "", program.slotTime ?? ""))
          .toList();

      // Sort programs by date and time (upcoming first)
      activePrograms.sort((a, b) {
        try {
          // Parse dates and times to DateTime objects for comparison
          final aDate = DateTime.parse(a.date ?? "");
          final bDate = DateTime.parse(b.date ?? "");
          
          // If dates are different, sort by date
          if (aDate != bDate) {
            return aDate.compareTo(bDate);
          }
          
          // If dates are same, sort by time
          final aTime = _parseTimeFromSlot(a.slotTime ?? "");
          final bTime = _parseTimeFromSlot(b.slotTime ?? "");
          return aTime.compareTo(bTime);
        } catch (e) {
          return 0; // If parsing fails, maintain original order
        }
      });


return ListView.separated(
  itemCount: activePrograms.length,
  separatorBuilder: (context, index) => Divider(
    color: Colors.grey,
    thickness: 0.4,
    height: screenHeight * 0.005,
  ),
  itemBuilder: (context, index) {
    var program = activePrograms[index];

    print("Program Slot ID: ${program.slotId}");
    print("Program Data: ${program.toJson()}");


    return songTile(
      "assets/images/heartimage.png",
      program.slotTime ?? "N/A",
      program.amount ?? "null",
      program.username ?? "Unknown",
      program.programName ?? "Untitled",
      program.programDescription ?? "No Description",
      program.programType == "Audio" ? Icons.mic : Icons.videocam,
      screenWidth,
      context,
      program.language != null
          ? program.language!.join(", ")
          : "N/A",
      program.date.toString(),
      program.programType ?? "Unknown Program Type",
      program.bookingId?.toString() ?? "",
      program,
    );
  },
);

    }),
  ),
)

        ],
      ),
    ));
  }

songTile(
  image, // String
  time,  // String
  amount,  // String
  username,  // String
  title,  // String
  subtitle,  // String
  icon,  // IconData
  screenWidth,  // double
  context,  // BuildContext
  languages,  // dynamic (likely List<String> or String)
  String date,  // ✅ corrected to String
  programType,
  String bookingId,
  dynamic program,
) {
  print("Languages Passed: $languages");

  String formattedLanguages = (languages is List<String>) ? languages.join(", ") : languages.toString();

  return GestureDetector(
onTap: () async {
  debugPrint("🎯 SLOT CLICKED");
  debugPrint("📌 Program Type: ${program.type}");
  debugPrint("📌 Booking ID: ${program.bookingId}");
  debugPrint("📌 Session ID: ${program.sessionId}");
  debugPrint("📌 Is Host: ${program.isHost}");

  if (program.type == "recorded") {
    await _openRecordedProgram(program);
  } else if (program.type == "live") {
    await _handleLiveProgram(program);
  } else {
    Fluttertoast.showToast(msg: "Invalid program type");
  }
},




    child: Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: screenWidth * 0.06, backgroundImage: AssetImage(image)),
          SizedBox(width: screenWidth * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.030),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: screenWidth * 0.005),
              Text(
                amount,
                style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.035),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username, // Username displayed
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: screenWidth * 0.005),
                Text(
                  title, // Title displayed
                  style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(icon, color: Colors.black, size: screenWidth * 0.06),
              SizedBox(height: 5),
              Text(
                formattedLanguages.length > 15
                    ? "${formattedLanguages.substring(0, 15)}..."
                    : formattedLanguages,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          SizedBox(width: screenWidth * 0.04),
        ],
      ),
    ),
  );
}



Future<Map<String, dynamic>?> showSongDetailsDialog(
  
  BuildContext context,
  String image,
  String username,
  String title,
  String subtitle,
  String amount,
  dynamic languages,
  String date,
  String programType,
  String booking_id
  
) {
  return showDialog<Map<String, dynamic>>(
    
    context: context,
    builder: (context) {
      bool isChecked = false;

      return StatefulBuilder(
        
        builder: (context, setState) {
            double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(image, width: 120, height: 120, fit: BoxFit.cover),
                ),
                SizedBox(height: 10),
                Text(username, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 15),
                if (languages.isNotEmpty)
                  Text(
                    "Languages: $languages",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? newValue) {
                        setState(() {
                          isChecked = newValue ?? false;
                        });
                      },
                    ),
       Obx(() {
  print("UI Wallet Balance: ${walletBalanceController.walletBalanceAmount.value}"); 
  return Text(
    'Wallet Balance: ₹ ${walletBalanceController.walletBalanceAmount.value }',
    style: TextStyle(
      fontSize: screenHeight * 0.015,
      fontWeight: FontWeight.w400,
      color: Colours.black,
    ),
  );
})
         
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
onPressed: () async {
  if (isChecked) {
    await createOrderThroughWallet(
      context: context,
      title: title,
      subtitle: subtitle,
      amount: amount,
      languages: languages,
      date: date,
      programType: programType,
      bookingId: booking_id,
    );
  } else {
    Navigator.pop(context, {
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'languages': languages,
      'date': date,
      'program_type': programType,
      "booking_id": booking_id
    });
  }
},

                   style: ElevatedButton.styleFrom(
                      fixedSize: Size(screenWidth * 0.5, screenHeight * 0.05),
                      backgroundColor: Colours.primarycolour,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      amount,
                      style: TextStyle(
                        fontSize: screenHeight * 0.025,
                        fontWeight: FontWeight.w600,
                        color: Colours.secondarycolour,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}
bool _isRejoinInProgress = false;
bool _isDialogShowing = false;
Map<String, dynamic>? _cachedRestartResult; 



void showRejoinDialog(
  int userId,
  int bookingId,
  String programTime,
  String programDate,
  String programType,
) {
  if (_isDialogShowing || _cachedRestartResult == null) return;

  final data = _cachedRestartResult!['response'];
  if (data == null) return;

  // Log the response data to debug
  print('Dialog Data: $data');

  _isDialogShowing = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Session Failed'),
        content: Text('Would you like to rejoin the session?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              setState(() {
                _isDialogShowing = false; 
              });
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Rejoin'),
            onPressed: () async {
              setState(() {
                _isDialogShowing = false; 
              });
              Navigator.of(context).pop();

              if (!mounted) return;

              await Future.delayed(Duration(milliseconds: 300));

 Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoCallPage(
          userId: userId,
          channelName: data['channel_name'],
          token: data['token'],
          uid: data['agora_uid'],
          appId: "daed82b7feea4990bf7fb43d9addd091",
          programType: programType,
          isCaller: true,
          sessionId: data['new_session_id'] ?? _sessionId!,
          
        ),
      ),
    );
  },
),
        ],
      );
    },
  ).then((_) {
    setState(() {
      _isDialogShowing = false; 
    });
  });
}
String formatDate(String rawDate) {
    try {
      final parsed = DateFormat('yyyy-MM-dd').parse(rawDate);
      return DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }
Future<void> handleProgramStart(
  int userId,
  int bookingId,
  String programTime,
  String programDate,
  String programType,
) async {
  if (_isRejoinInProgress) return;

  try {
    _isRejoinInProgress = true;
    setState(() => _isLoading = true);

    // Time validation
    final parts = programTime.split('-');
    if (parts.length != 2) throw FormatException("Invalid time range format");
    
    final startTimeStr = parts[0].trim();
    final startDateTime = _parseProgramTime(programDate, startTimeStr);
    final now = DateTime.now();

    if (now.isBefore(startDateTime)) {
   showStartTimePopup(startTimeStr, formatDate(programDate));

      return;
    }

    // Try to rejoin existing session first
    if (_sessionId != null) {
      print('Attempting to rejoin session $_sessionId');
      final restartResult = await ApiService.restartCall(userId, _sessionId!);
      print('Rejoin API Result: $restartResult');

      if (restartResult != null) {
        // Handle both direct response and wrapped response
        final responseData = restartResult['response'] ?? restartResult;
        
        if (restartResult['status_code'] == 200 || 
            (restartResult['status_code'] == null && responseData['channel_name'] != null)) {
          // Successful rejoin - navigate directly to call
         
 Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoCallPage(
                     userId :userId,
                channelName: responseData['channel_name'],
                token: responseData['token'],
                uid: responseData['agora_uid'],
                appId: "daed82b7feea4990bf7fb43d9addd091",
                programType: programType,
                isCaller: true,
                sessionId: responseData['new_session_id'] ?? _sessionId!,
             
              
            ),
          ));
          return;
        }
      }
    }

    // Start new call if rejoin failed or no sessionId exists
    print('Starting new call...');
    final result = await ApiService.startCall(
      userId: userId,
      bookingId: bookingId,
      callType: programType,
    );
    print('Start Call API Result: $result');
    

    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start session. Please try again.')),
      );
      return;
    }

    // Handle both response structures
    final responseData = result['response'] ?? result;
    final statusCode = result['status_code'] ?? 200;

    if (statusCode != 200 || responseData['channel_name'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 
                          responseData['error'] ?? 
                          'Failed to start session')),
      );
      return;
    }

    _sessionId = responseData['session_id'] ?? responseData['new_session_id'];

    await Future.delayed(Duration(milliseconds: 300));

    if (!mounted) return;


 Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoCallPage(
               userId :userId,
          channelName: responseData['channel_name'],
          token: responseData['token'],
          uid: responseData['agora_uid'],
          appId: "daed82b7feea4990bf7fb43d9addd091",
          programType: programType,
          isCaller: true,
          sessionId: _sessionId!,
       
        ),
      
    ));
  } catch (e) {
    print('Error in handleProgramStart: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  } finally {
    _isRejoinInProgress = false;
    if (mounted) setState(() => _isLoading = false);
  }
}

Future<void> handleJoinCall(int userId, int? sessionId) async {
  if (sessionId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session ID not available. Please wait.')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final data = await ApiService.joinCall(
      userId: userId,
      sessionId: sessionId,
    );

    if (!mounted) return;

    print('Join Call Response: $data');

    if (data == null || data['status_code'] != 200 || data['response'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data?['error'] ?? 'Host have not joined yet.Please wait.'),
        ),
      );
      return;
    }

    // Extract the nested response object
      final response = data['response'];
      final channelName = response?['channel_name'] as String?;
      final token = response?['token'] as String?;
      final agoraUidStr = response?['agora_uid']?.toString();
      final uid = int.tryParse(agoraUidStr ?? '') ?? 0; // Agora allows 0 as a valid uid (SDK assigns)
      final callType = response?['call_type'] as String?;


    print('Debug => Channel: $channelName, Token: $token, UID: $uid');

    if (channelName == null || token == null ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing call details from server.')),
      );
      return;
    }

 Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoCallPage(
               userId :userId,
          channelName: channelName,
          token: token,
          uid: uid,

          appId: "daed82b7feea4990bf7fb43d9addd091",
          programType: callType,
          isCaller: false,
          sessionId: sessionId,
     
        ),
      ),
    );
  } catch (e) {
    debugPrint('Error joining call: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
} 
Future<void> _openRecordedProgram(dynamic program) async {
  debugPrint("📼 RECORDED PROGRAM FLOW");

  final url = program.recordedUrl;

  if (url == null || url.isEmpty) {
    Fluttertoast.showToast(msg: "Recorded content not available");
    return;
  }

  debugPrint("🎬 Opening recorded stream: $url");

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StreamVideoPage(streamUrl: url),
    ),
  );
}


Future<void> _handleLiveProgram(dynamic program) async {
  final int uid = userId ?? 0;
  final int bookingId = program.bookingId;
  final int? sessionId = program.sessionId;

  debugPrint("🟢 LIVE PROGRAM FLOW");
  debugPrint("👤 User ID: $uid");
  debugPrint("📘 Booking ID: $bookingId");
  debugPrint("🎥 Session ID: $sessionId");

  // ---------------- HOST ----------------
  if (program.isHost == true) {
    debugPrint("🎙 HOST STARTING SESSION");

    await handleProgramStart(
      uid,
      bookingId,
      program.slotTime,
      program.date,
      program.programType,
    );
    return;
  }

  // ---------------- LISTENER ----------------
  if (sessionId == null) {
    Fluttertoast.showToast(
      msg: "Host has not started the session yet",
    );
    return;
  }

  debugPrint("🎧 LISTENER JOINING SESSION");

  await handleJoinCall(uid, sessionId);
}


}