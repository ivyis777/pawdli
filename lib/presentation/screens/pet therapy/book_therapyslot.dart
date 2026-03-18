import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/data/controller/paythroughwalletcontroller.dart';
import 'package:pawlli/data/controller/walletbalancecontroller.dart';
import 'package:pawlli/data/model/ordercraetionmodel.dart';
import 'package:pawlli/data/model/paymentverificationmodel.dart';
import 'package:pawlli/data/model/paythroughwallet.dart';
import 'package:pawlli/data/model/therapyslot.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:pawlli/presentation/screens/therapypaymentverification/therapysuccess.dart';
import 'package:pawlli/presentation/screens/therapypaymentverification/therapyfailure.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:toggle_switch/toggle_switch.dart';
class pettherapyslotPage extends StatefulWidget {
  final List selectedSlots;
  final double totalAmount;
    final List<String>   selectedDate;
     final List<int> selectedSlotIds;
       final int? petid; 
  const pettherapyslotPage ({
    required this.selectedSlots,
    required this.totalAmount,
    required this.  selectedDate,
    required this.selectedSlotIds,
    required this.petid,
    Key? key,
  }) : super(key: key);
  @override
  _pettherapyslotPageState createState() =>_pettherapyslotPageState();
}
class _pettherapyslotPageState extends State<pettherapyslotPage> {
  int selectedIndex = 1; 
  int? userId;
  String _isOnsite = 'Onsite';
  String currentOrderId = "";
   String? _apiFormattedDate; 
  String? _selectedGender = 'Male';
  String? _isSpayed = 'No';
DateTime today = DateTime.now();
int _therapyTakenIndex = 1;     
int _groupTherapyIndex = 1;
int _studentsIndex = 1;
int _employeesIndex = 1;

final TextEditingController _therapyDetailsController = TextEditingController();
final TextEditingController _groupCountController = TextEditingController();
final TextEditingController _studentCountController = TextEditingController();
final TextEditingController _orgNameController = TextEditingController();
final TextEditingController _employeeCountController = TextEditingController();
TextEditingController _phoneController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN');
    TextEditingController   Addresscontroller = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  TextEditingController _FirstNameController = TextEditingController();
   TextEditingController _SecondNameController = TextEditingController();
  TextEditingController programDescriptionController = TextEditingController();
 
  PaymentVerificationModel paymentVerifiedModel = PaymentVerificationModel();
  final PayThroughWalletController walletController = Get.put(PayThroughWalletController());
  final WalletBalanceController walletBalanceController = Get.put(WalletBalanceController());
  TextEditingController _pincodeController = TextEditingController();
String? _pincodeError;
final _formKey = GlobalKey<FormState>();

  PayThroughWalletModel? walletModel;
  bool _isPhoneNumberValid = false;
  late Razorpay _razorpay;
  String? _orderId;
  String? user_id;
  bool _isChecked = false;
  FocusNode _programNameFocus = FocusNode();
  FocusNode _programDescriptionFocus = FocusNode();
    FocusNode _addressFocus = FocusNode();
  final box = GetStorage();
  String selectedProgramType = 'Video'; 
String sanitizePhoneNumber(String input) {
  String cleaned = input.replaceAll(RegExp(r'[^+\d]'), '');
  cleaned = cleaned.replaceAll('+', '');
  if (cleaned.startsWith('91') && cleaned.length == 12) {
    cleaned = cleaned.replaceFirst('93', '91');
  }
  return '+$cleaned';
}
@override
void initState() {
  super.initState();

  _razorpay = Razorpay();
  _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

  final storage = GetStorage();
  var storedUserId = storage.read(LocalStorageConstants.userId);

  if (storedUserId != null) {
    user_id = storedUserId.toString();
    userId = int.tryParse(user_id!) ?? 0;
    print("✅ User ID Retrieved: $userId");
    walletBalanceController.fetchWalletBalance(userId!);
  } else {
    print("⚠️ Error: user_id is null or empty!");
  }
}

bool isValidPincode(String pin) {
  if (pin.length != 6) return false;

  // Convert to int safely
  int pincode = int.tryParse(pin) ?? 0;

  // Karnataka → 560xxx - 591xxx
  if (pincode >= 560000 && pincode <= 591999) return true;

  // Andhra Pradesh → 517xxx - 535xxx
  if (pincode >= 517000 && pincode <= 535999) return true;

  // Telangana → 500xxx - 509xxx
  if (pincode >= 500000 && pincode <= 509999) return true;

  return false;
}


@override
void dispose() {
  _razorpay.clear(); 
  super.dispose();
}

Future<void> createOrder() async {
  if (userId == null || userId == 0) {
    Fluttertoast.showToast(msg: "User ID not found! Please login again.");
    return;
  }

  if (widget.selectedSlotIds == null || widget.selectedSlotIds.isEmpty) {
    Fluttertoast.showToast(msg: "No slots selected. Please choose at least one slot.");
    return;
  }

  // ✅ Flatten slot list
List<int> flattenedSlots = widget.selectedSlots
    .map((slot) => (slot as TherapySlot).slotId ?? 0)
    .where((id) => id != 0)
    .toList();


  // ✅ Request payload (Pet Therapy API format)
  Map<String, dynamic> orderData = {
    "user_id": userId,
    "slots": flattenedSlots,
    "amount": widget.totalAmount.toStringAsFixed(2),
    "currency": "INR",
    "purpose": "PetTherapy",
    "first_name": _FirstNameController.text,
    "last_name": _SecondNameController.text,
    "birthday": _birthdayController.text,
    "phone_number": _phoneController.text,
    "address": Addresscontroller.text,
    "gender": _selectedGender?.toLowerCase() ?? "male",
    "mode": _isOnsite.toLowerCase(),
    "previous_pet_therapy": _therapyTakenIndex == 0 ? "yes" : "no",
    "therapy_type": _groupTherapyIndex == 0 ? "yes" : "no",
    "for_students": _studentsIndex == 0,
    "for_employees": _employeesIndex == 0,
    "description": programDescriptionController.text
  };
// 🔹 Conditional fields
  if (_therapyTakenIndex == 0) {
    orderData["previous_pet_therapy_details"] =
        _therapyDetailsController.text.trim();
  }

  if (_groupTherapyIndex == 0) {
    orderData["group_count"] = _groupCountController.text.trim();
  }

  if (_studentsIndex == 0) {
    orderData["student_count"] = _studentCountController.text.trim();
  }

  if (_employeesIndex == 0) {
    orderData["organization_name"] = _orgNameController.text.trim();
    orderData["employee_count"] = _employeeCountController.text.trim();
  }

  String requestUrl = AppUrl.therapyCreateOrderURL;

  if (widget.totalAmount == 0.00) {
    try {
     var response = await http.post(
  Uri.parse(requestUrl),
  headers: {
    "Authorization": "Bearer ${box.read(LocalStorageConstants.access)}",
    "Content-Type": "application/json",
    "Accept": "application/json",
  },
  body: jsonEncode(orderData),
);
print("📤 API URL: $requestUrl");
print("📤 Payload: ${jsonEncode(orderData)}");
print("📤 Headers: ${{
  "Authorization": "Bearer ${box.read(LocalStorageConstants.access)}",
  "Content-Type": "application/json",
  "Accept": "application/json"
}}");

      print("📩 Free slot booking response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['error'] ?? responseData['message'] ?? "Something went wrong.";
        Fluttertoast.showToast(msg: "Error: $errorMessage");
      }
    } catch (e) {
      print("❌ Exception booking free slot: $e");
      Fluttertoast.showToast(msg: "Failed to book slot. Please try again.");
    }
    return;
  }
  try {
    print("📤 Sending request: ${jsonEncode(orderData)}");

    var response = await http.post(
      Uri.parse(requestUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(orderData),
    );

    print("📩 Response Status: ${response.statusCode} - ${response.body}");
    final responseData = json.decode(response.body);

    final order = OrderCreationModel.fromJson(responseData);
    _orderId = order.razorpayOrderId ?? "";
    currentOrderId = _orderId ?? "";

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (_orderId!.isNotEmpty) {
        print("✅ Order created successfully: $_orderId");
        openCheckout();
      } else {
        Fluttertoast.showToast(msg: "Order ID missing. Try again.");
      }
    } else {
      final errorMessage = responseData['error'] ?? responseData['message'] ?? "Unknown error occurred.";
      Fluttertoast.showToast(msg: "Error: $errorMessage");
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
  var amountInPaise = (widget.totalAmount * 100).toInt(); 

  var options = {
    'key': 'rzp_live_hUYYZly69YfdVs',
    'amount': amountInPaise,
    'currency': 'INR',
    "purpose": "PetTherapy",
    'order_id': _orderId,
    'name': 'Pawlli',
    'description': programDescriptionController?.text ?? '',
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
          builder: (context) => TherapyPaymentsuccess(
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
          builder: (context) => TherapyPaymentfailure(
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
    if (response.message != null && response.message!.startsWith('{')) {
      Map<String, dynamic> errorData = jsonDecode(response.message!);
      orderId = errorData['order_id'] ?? orderId;
      paymentId = errorData['payment_id'] ?? paymentId;
    } else {
      debugPrint("Received plain message: ${response.message}");
    }
  } catch (e) {
    debugPrint("Error decoding response message: $e");
  }

  debugPrint("❌ Payment Failure Details:");
  debugPrint("Order ID: $orderId");
  debugPrint("Payment ID: $paymentId");
  debugPrint("Signature: $signature");

  // Verify the failed payment attempt
  var verification = await ApiService.verifyPayment(
    razorpay_order_id: orderId,
   razorpay_payment_id: paymentId,
   razorpay_signature: signature,
  );

  debugPrint("🔄 Verification result: $verification");

  // Navigate to failure page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TherapyPaymentfailure(
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
Future<void> createOrderThroughWallet() async {
  if (userId == null || userId == 0) {
    Fluttertoast.showToast(msg: "User ID not found! Please login again.");
    return;
  }

  if (widget.selectedSlots == null || widget.selectedSlots.isEmpty) {
    Fluttertoast.showToast(msg: "No slots selected. Please choose at least one slot.");
    return;
  }

  // ✅ Flatten slots here also
  List<int> flattenedSlots = widget.selectedSlots
      .map((slot) => (slot as TherapySlot).slotId ?? 0)
      .where((id) => id != 0)
      .toList();

  // ✅ Build orderData
  Map<String, dynamic> orderData = {
    "user_id": userId,
    "slots": flattenedSlots,
    "amount": widget.totalAmount.toStringAsFixed(2),
    "currency": "INR",
    "purpose": "PetTherapy",
    "first_name": _FirstNameController.text.trim(),
    "last_name": _SecondNameController.text.trim(),
    "birthday": _birthdayController.text.trim(),
    "phone_number": _phoneController.text.trim(),
    "address": Addresscontroller.text.trim(),
    "gender": _selectedGender?.toLowerCase() ?? "male",
    "mode": _isOnsite.toLowerCase(),
    "previous_pet_therapy": _therapyTakenIndex == 0 ? "yes" : "no",
    "therapy_type": _groupTherapyIndex == 0 ? "yes" : "no",
    "for_students": _studentsIndex == 0,
    "for_employees": _employeesIndex == 0,
    "description": programDescriptionController.text.trim(),
  };

  // 🔹 Conditional fields
  if (_therapyTakenIndex == 0) {
    orderData["previous_pet_therapy_details"] = _therapyDetailsController.text.trim();
  }
  if (_groupTherapyIndex == 0) {
    orderData["group_count"] = _groupCountController.text.trim();
  }
  if (_studentsIndex == 0) {
    orderData["student_count"] = _studentCountController.text.trim();
  }
  if (_employeesIndex == 0) {
    orderData["organization_name"] = _orgNameController.text.trim();
    orderData["employee_count"] = _employeeCountController.text.trim();
  }

  print("📤 Wallet booking payload: ${jsonEncode(orderData)}");

  // 🏦 Call Wallet API
 await Get.find<PayThroughWalletController>().initiatePayment(
  amount: widget.totalAmount.toStringAsFixed(2),
  currency: "INR",
  bookingId: flattenedSlots,
  purpose: "PetTherapy",
  receipt: "",
  date: "",
  userId: userId.toString(),
  extraData: orderData, // ✅ Include all extra booking fields here
);


  final result = Get.find<PayThroughWalletController>().paymentResult.value;

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
      "🎉 Thanks for booking the slot with Wallet!",
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
        builder: (context) => HomePage(),
      ),
    );
  } else {
    Get.snackbar(
      "Error",
      result?.message ?? "Payment failed",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }
}


Future<void> _selectDate(BuildContext context) async {
  // Get today's date without time (00:00:00)
  DateTime today = DateTime.now();
  DateTime onlyDate = DateTime(today.year, today.month, today.day);

  // Set initial and last date to today
  DateTime initialDate = onlyDate;
  DateTime lastDate = onlyDate;
  DateTime firstDate = DateTime(1900); // or any custom minimum date

  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData(
          primaryColor: Colours.primarycolour,
          colorScheme: ColorScheme.light(
            primary: Colours.primarycolour,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colours.primarycolour,
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (pickedDate != null) {
    final formattedDate = "${pickedDate.year}-"
        "${pickedDate.month.toString().padLeft(2, '0')}-"
        "${pickedDate.day.toString().padLeft(2, '0')}";

    setState(() {
      _birthdayController.text = formattedDate;
      _apiFormattedDate = formattedDate;
    });
  }
}

Widget _buildTextField(
  String label,
  TextEditingController controller, {
  Widget? suffixIcon,
  bool requireValidation = true,
  bool readOnly = false,       
  VoidCallback? onTap,             
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: TextFormField(
      controller: controller,
      readOnly: readOnly,          
      onTap: onTap,                
      validator: (value) {
        if (requireValidation && (value == null || value.trim().isEmpty)) {
          return 'Please enter this field';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colours.brownColour,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colours.primarycolour),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
      ),
    ),
  );
}


Widget _buildModeToggle() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Mode:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ToggleSwitch(
          minWidth: 90.0,
          cornerRadius: 20.0,
          activeBgColors: [[Colours.primarycolour], [Colours.primarycolour]],
          activeFgColor: Colors.white,
          inactiveBgColor: Colors.grey,
          inactiveFgColor: Colors.white,
          initialLabelIndex: _isOnsite == 'Onsite' ? 0 : 1,
          totalSwitches: 2,
          labels: ['Onsite', 'Offsite '],
          radiusStyle: true,
          onToggle: (index) {
            setState(() {
           _isOnsite = index == 0 ? 'Onsite' : 'Offsite';
            });
            print('Is Free switched to: $_isOnsite');
          },
        ),
      ],
    ),
  );
}

  Widget _buildGenderButtons() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Gender:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ToggleSwitch(
          minWidth: 90.0,
          initialLabelIndex: _selectedGender == 'Male' ? 0 : 1,
          cornerRadius: 20.0,
          activeFgColor: Colors.white,
          inactiveBgColor: Colors.grey,
          inactiveFgColor: Colors.white,
          totalSwitches: 2,
          labels: ['Male', 'Female'],
          icons: [FontAwesomeIcons.mars, FontAwesomeIcons.venus],
          activeBgColors: [
            [Colours.primarycolour],
            [Colours.primarycolour]
          ],
          onToggle: (index) {
            setState(() {
              _selectedGender = index == 0 ? 'Male' : 'Female';
            });
            print('Gender switched to: $_selectedGender');
          },
        ),
      ],
    ),
  );
}

Widget _buildYesNoToggle({required int index, required void Function(int?) onToggle}) {
  return ToggleSwitch(
    minWidth: 90.0,
    cornerRadius: 20.0,
    activeBgColors: [[Colours.primarycolour], [Colours.primarycolour]],
    activeFgColor: Colors.white,
    inactiveBgColor: Colors.grey,
    inactiveFgColor: Colors.white,
    initialLabelIndex: index,
    totalSwitches: 2,
    labels: ['Yes', 'No'],
    radiusStyle: true,
    onToggle: onToggle, // 👈 This now matches the expected type
  );
}


   
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
     
      body: Stack(
        children: [
          Container(
            width: screenWidth * 0.55,
            height: screenHeight * 0.10,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.topimage.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PreferredSize(
                    preferredSize: Size.fromHeight(screenHeight * 0.12),
                    child: AppBar(
                      title: Text(
                        'Book Slots',
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
      SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          
          child:
           Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Radio and Slots Information
              
              /// Slot Details Card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colours.primarycolour, width: 1),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Therapy: ', style: TextStyle(fontWeight: FontWeight.bold)),
       
            ],
          ),
          SizedBox(height: 8),
          ...widget.selectedSlots.asMap().entries.map((entry) {
            int index = entry.key + 1;
            var slot = entry.value;
            String startTime = slot.startTime ?? "N/A"; // Replace with actual property name
            String endTime = slot.endTime ?? "N/A"; // Replace with actual property name
        
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text('Slot $index: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text("$startTime - $endTime", style: TextStyle(fontWeight: FontWeight.w500, fontFamily: FontFamily.Cairo)),
                ],
              ),
            );
          }).toList(),
        ],
            ),
          ),
        ),
          SizedBox(height: 16),
            Row(
                children: [
                  Expanded(
                    child: _buildTextField("Enter First Name", _FirstNameController),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField("Enter Last Name", _SecondNameController),
                  ),
                ],
              ),
                           
                              _buildTextField(
  "Enter Birthday (YYYY/MM/DD)",
  _birthdayController,
  readOnly: true, 
  onTap: () => _selectDate(context), 
  suffixIcon: IconButton(
    icon: Icon(Icons.calendar_today, color: Colors.brown),
    onPressed: () => _selectDate(context),
  ),
),
     SizedBox(height: 5),
         InternationalPhoneNumberInput(
onInputChanged: (PhoneNumber number) {
    setState(() {
      _phoneNumber = number;
    });
  },
  onInputValidated: (bool isValid) {
    setState(() {
      _isPhoneNumberValid = isValid;
    });
    print(isValid ? '✅ Valid phone number' : '❌ Invalid phone number');
  },
  selectorConfig: SelectorConfig(
    selectorType: PhoneInputSelectorType.DIALOG,
  ),
  textFieldController: _phoneController,
  formatInput: false,
  
  initialValue: _phoneNumber,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    return null;
  },
  inputDecoration: InputDecoration(
    labelText: 'Phone Number',


    labelStyle: TextStyle(color: Colors.brown[600]),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.brown),
      borderRadius: BorderRadius.circular(10),
    ),
    
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colours.primarycolour, width: 2.0),
      borderRadius: BorderRadius.circular(10),
    ),
           filled: true,
      fillColor: Colors.white,
  ),
)
,
      SizedBox(height: 8),
                            Material(
                              child: TextField(
                                focusNode: _addressFocus,
                                maxLines: 3,
                                controller:Addresscontroller ,
                                decoration: InputDecoration(
                                  
                                  labelText: 'Enter Place',
                                      labelStyle: TextStyle(color: Colors.brown[600]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colours.textColour),
                                    
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    
                                    borderSide: BorderSide(color: Colours.primarycolour),
                                  ),
                                      filled: true,
        fillColor: Colors.white,
                                ),
                                
                              ),
                              
                            ),
      SizedBox(height: 5),
       
                   _buildTextField("Enter Pincode", _pincodeController),

if (_pincodeError != null)
  Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Text(
      _pincodeError!,
      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    ),
  ),
               SizedBox(height: 5),
                      
              _buildGenderButtons(),
          
           
            
                          
                   _buildModeToggle(),
                            SizedBox(height: 16),
 /// Q1: Previous Pet Therapy
Text('Have you taken any pet therapy previously?', style: TextStyle(fontWeight: FontWeight.bold)),
SizedBox(height: 8),
_buildYesNoToggle(index: _therapyTakenIndex, onToggle: (i) {
  setState(() => _therapyTakenIndex = i??1);
}),
if (_therapyTakenIndex == 0) ...[ // Yes
  SizedBox(height: 8),
  _buildTextField("Please mention/share the details of the pet", _therapyDetailsController),
],
SizedBox(height: 16),

/// Q2: Individual/Group Therapy
Text('Is this therapy for Individual/Group?', style: TextStyle(fontWeight: FontWeight.bold)),
SizedBox(height: 8),
_buildYesNoToggle(index: _groupTherapyIndex, onToggle: (i) {
  setState(() => _groupTherapyIndex = i??1);
}),
if (_groupTherapyIndex == 0) ...[
  SizedBox(height: 8),
  _buildTextField("If Yes, how many?", _groupCountController),
],
SizedBox(height: 16),

/// Q3: Is it for Students?
Text('Is this therapy for Students?', style: TextStyle(fontWeight: FontWeight.bold)),
SizedBox(height: 8),
_buildYesNoToggle(index: _studentsIndex, onToggle: (i) {
  setState(() => _studentsIndex = i??1);
}),
if (_studentsIndex == 0) ...[
  SizedBox(height: 8),
  _buildTextField("If Yes, how many students?", _studentCountController),
],
SizedBox(height: 16),

/// Q4: Is it for Employees?
Text('Is this therapy for Employees?', style: TextStyle(fontWeight: FontWeight.bold)),
SizedBox(height: 8),
_buildYesNoToggle(index: _employeesIndex, onToggle: (i) {
  setState(() => _employeesIndex = i??1);
}),
if (_employeesIndex == 0) ...[
  SizedBox(height: 8),
  _buildTextField("Organization Name", _orgNameController),
  SizedBox(height: 8),
  _buildTextField("No. of Employees", _employeeCountController),
],

SizedBox(height: 8),

                            Material(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Description:',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      TextField(
        focusNode: _programDescriptionFocus,
        maxLines: 3,
        controller: programDescriptionController,
        decoration: InputDecoration(
          labelText: 'Description',
          labelStyle: TextStyle(color: Colors.brown[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colours.textColour),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colours.primarycolour),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ],
  ),
),
SizedBox(height: 16),


           
                Row(
  children: [
    Checkbox(
      value: _isChecked,
      onChanged: (bool? value) {
        setState(() {
          _isChecked = value!;
        });
      },
    ),
Obx(() {
  print("UI Wallet Balance: ${walletBalanceController.walletBalanceAmount.value}"); 
  return Text(
    'Wallet Balance: ₹ ${walletBalanceController.walletBalanceAmount.value }',
    style: TextStyle(
      fontSize: screenHeight * 0.02,
      fontWeight: FontWeight.w500,
      color: Colours.black,
    ),
  );
})

  ],
),

                  SizedBox(height: 20),
               Center(
  child: ElevatedButton(
    onPressed: () {
      String pin = _pincodeController.text.trim();

      // Check if pincode is valid
    
    if (pin.isEmpty) {
      setState(() {
        _pincodeError = "❌ Please enter pincode";
      });
      return;
    }

    if (!isValidPincode(pin)) {
      setState(() {
        _pincodeError = "❌ No service for this region";
      });
      return;
    }
      // Check if pet is available for this pincode
      if (widget.petid == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Not Available"),
            content: Text("Sorry, pets are not available for this pincode."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
        return; // Stop further execution
      }

      // If using wallet
      if (_isChecked) {
        createOrderThroughWallet();
      } else {
        createOrder();
      }
    },
    style: ElevatedButton.styleFrom(
      fixedSize: Size(screenWidth * 0.8, screenHeight * 0.07),
      backgroundColor: Colours.primarycolour,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    child: Text(
      "Pay ₹${widget.totalAmount}",
      style: TextStyle(
        fontSize: screenHeight * 0.025,
        fontWeight: FontWeight.w600,
        color: Colours.secondarycolour,
      ),
    ),
  ),
),

                ],
          ),
        ),
      ),
         ] )))]));
  }
}
