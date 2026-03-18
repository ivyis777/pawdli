import 'dart:async' show StreamTransformer;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/data/controller/languagecontroller.dart';
import 'package:pawlli/data/controller/paythroughwalletcontroller.dart';
import 'package:pawlli/data/controller/walletbalancecontroller.dart';
import 'package:pawlli/data/model/ordercraetionmodel.dart';
import 'package:pawlli/data/model/paymentverificationmodel.dart';
import 'package:pawlli/data/model/paythroughwallet.dart';
import 'package:pawlli/data/model/slotcreationmodel.dart' as slot_model;
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:pawlli/presentation/screens/pawlli%20radio/pawlli_radio.dart';
import 'package:pawlli/presentation/screens/slots/slots_and_time.dart';
import 'package:pawlli/presentation/slotpaymentverificationpage/paymentfailure.dart';
import 'package:pawlli/presentation/slotpaymentverificationpage/paymentsuccess.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:get/get.dart';

// NEW import for file picker
import 'package:file_picker/file_picker.dart';

class RadioProgramPage extends StatefulWidget {
  final List selectedSlots;
  final double totalAmount;
  final String radioname;
  final List<String> selectedDate;
  final List<int> selectedSlotIds;
  final int? radioid;

  const RadioProgramPage({
    required this.selectedSlots,
    required this.totalAmount,
    required this.radioname,
    required this.selectedDate,
    required this.selectedSlotIds,
    required this.radioid,
    Key? key,
  }) : super(key: key);

  @override
  _RadioProgramPageState createState() => _RadioProgramPageState();
}

class _RadioProgramPageState extends State<RadioProgramPage> {
  int selectedIndex = 1;
  int? userId;
  String currentOrderId = "";
  List<Map<String, String>> parsedSlots = [];

  TextEditingController programNameController = TextEditingController();
  TextEditingController programDescriptionController = TextEditingController();
  final LanguageController languageController = Get.put(LanguageController());
  PaymentVerificationModel paymentVerifiedModel = PaymentVerificationModel();
  final PayThroughWalletController walletController = Get.put(PayThroughWalletController());
  final WalletBalanceController walletBalanceController = Get.put(WalletBalanceController());

  PayThroughWalletModel? walletModel;

  late Razorpay _razorpay;
  String? _orderId;
  String? user_id;
  bool _isChecked = false;
  FocusNode _programNameFocus = FocusNode();
  FocusNode _programDescriptionFocus = FocusNode();
  final box = GetStorage();
  String selectedProgramType = 'Video';

  // NEW state for file picking/upload
  PlatformFile? selectedFile;
  String? selectedFileType; // 'Audio' or 'Video'
  bool isUploading = false;
  String uploadStatus = "";
  double uploadProgress = 0.0;

  // 🆕 Added state variables
  String selectedLanguage = 'English';
  String programMode = 'Live';
  String repeatType = 'Single';
  String repeatInterval = '';
  
  

  @override
  void initState() {
    super.initState();

    parsedSlots = widget.selectedSlots.map<Map<String, String>>((slot) {
      String startTime = (slot is Map && slot['startTime'] != null)
          ? slot['startTime'].toString()
          : (slot?.startTime?.toString() ?? "N/A");

      String endTime = (slot is Map && slot['endTime'] != null)
          ? slot['endTime'].toString()
          : (slot?.endTime?.toString() ?? "N/A");

      return {
        "start": startTime,
        "end": endTime,
      };
    }).toList();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    final storage = GetStorage();
    var storedUserId = storage.read(LocalStorageConstants.userId);

    if (storedUserId != null) {
      user_id = storedUserId.toString();
      userId = int.tryParse(user_id!) ?? 0;
      print("User ID Retrieved: $userId");
    } else {
      print("⚠️ Error: user_id is null or empty!");
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    programNameController.dispose();
    programDescriptionController.dispose();
    _programNameFocus.dispose();
    _programDescriptionFocus.dispose();
    super.dispose();
  }

  // --- Existing createOrder, openCheckout, payment handlers unchanged ---
  Future<void> createOrder() async {
    if (userId == null || userId == 0) {
      Fluttertoast.showToast(msg: "User ID not found! Please login again.");
      return;
    }

    if (widget.selectedSlotIds.isEmpty) {
      Fluttertoast.showToast(msg: "No slots selected. Please choose at least one slot.");
      return;
    }

    if (widget.totalAmount == 0.00) {
WidgetsBinding.instance.addPostFrameCallback((_) {
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
});


      Map<String, dynamic> orderData = {
        "user_id": userId,
        "slots": widget.selectedSlots
            .expand((slot) {
              if (slot is Map<String, dynamic>) {
                return (slot["slotIds"] ?? []) as List;
              } else if (slot is slot_model.SlotPageModel &&
                  slot.data != null &&
                  slot.data!.isNotEmpty) {
                return slot.data!.map((s) => s.slotId).whereType<int>();
              } else if (slot is slot_model.Data) {
                return [slot.slotId];
              } else {
                return [];
              }
            })
            .where((id) => id != null)
            .toSet()
            .toList(),
        "program_name": programNameController.text,
        "program_description": programDescriptionController.text,
        "language": languageController.selectedLanguages.isNotEmpty
            ? languageController.selectedLanguages
            : ["English"],
        "program_type": selectedProgramType,
        "program_mode": programMode.toLowerCase(),
        "amount": "0.00",
        "currency": "INR",
        "purpose": "Host"
      };

      try {
        var response = await http.post(
          Uri.parse(AppUrl.OrderCreationURL),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode(orderData),
        );

        print("📩 Free slot booking response: ${response.statusCode} - ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          Fluttertoast.showToast(msg: "Slot booked successfully!");
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

      return; // Don't call Razorpay if amount is 0
    }

    Map<String, dynamic> orderData = {
      "user_id": userId,
      "slots": widget.selectedSlots
          .expand((slot) {
            if (slot is Map<String, dynamic>) {
              print("✅ Mapping from Map: $slot");
              return (slot["slotIds"] ?? []) as List;
            } else if (slot is slot_model.SlotPageModel &&
                slot.data != null &&
                slot.data!.isNotEmpty) {
              print("✅ Mapping from SlotPageModel: ${slot.toJson()}");
              return slot.data!.map((s) => s.slotId).whereType<int>();
            } else if (slot is slot_model.Data) {
              print("✅ Mapping from slot_model.Data: ${slot.toJson()}");
              return [slot.slotId];
            } else {
              print("❌ Invalid slot format: $slot");
              return [];
            }
          })
          .where((id) => id != null)
          .toSet()
          .toList(),
      "program_name": programNameController.text,
      "program_description": programDescriptionController.text,
      "language": languageController.selectedLanguages.isNotEmpty
          ? languageController.selectedLanguages
          : ["English"],
      "program_type": selectedProgramType,
      "amount": widget.totalAmount.toStringAsFixed(2),
      "currency": "INR",
      "purpose": "Host"
    };

    print(orderData);
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

      // Deserialize into your model
      final order = OrderCreationModel.fromJson(responseData);
      _orderId = order.razorpayOrderId ?? "";
      currentOrderId = order.razorpayOrderId.toString();

      if (_orderId!.isNotEmpty) {
        print("📦 Razorpay Order ID: $_orderId");
      }

      // Handle response success
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (_orderId!.isNotEmpty) {
          print("✅ Order created successfully: $_orderId");
          openCheckout();
        } else {
          Fluttertoast.showToast(msg: "Order ID missing. Try again.");
        }
      } else {
        final errorMessage = responseData['error'] ?? responseData['message'] ?? "Unknown error occurred.";
        print("⚠️ API Error: $errorMessage");
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
    var amountInPaise = (widget.totalAmount * 100).toInt(); // Use actual amount

    var options = {
      'key': 'rzp_live_hUYYZly69YfdVs',
      'amount': amountInPaise,
      'currency': 'INR',
      'purpose': 'Host',
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
      debugPrint('Razorpay open error: $e');
      Fluttertoast.showToast(msg: "Payment failed. Please try again.");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      debugPrint("Payment Successful:");
      debugPrint("Payment ID: ${response.paymentId ?? 'N/A'}");
      debugPrint("Order ID: ${response.orderId ?? 'N/A'}");
      debugPrint("Signature: ${response.signature ?? 'N/A'}");

      Get.snackbar(
        "Success",
        "Payment Successful!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colours.primarycolour,
        colorText: Colours.secondarycolour,
      );

      debugPrint("Sending payment verification request to backend...");

      // Verify the payment with your backend
      var verification = await ApiService.verifyPayment(
        razorpay_order_id: response.orderId ?? "",
        razorpay_payment_id: response.paymentId ?? "",
        razorpay_signature: response.signature ?? "",
      );

      debugPrint("Payment verification response: $verification");

      if (verification != null) {
        debugPrint("Payment verification successful, navigating to success page.");
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
        builder: (context) => SlotPaymentfailure(
          orderId: orderId,
          paymentId: paymentId,
          signature: signature,
          paymentVerifiedModel: verification,
          radioid: widget.radioid,
          radioname: widget.radioname,
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

  void createOrderThroughWallet() async {
    await Get.find<PayThroughWalletController>().initiatePayment(
      amount: widget.totalAmount.toString(),
      currency: "INR",
      bookingId: widget.selectedSlotIds,
      purpose: "Host",
      receipt: "",
      programName: programNameController.text,
      programDescription: programDescriptionController.text,
      language: languageController.selectedLanguages,
      date: "", // Replace with actual date logic if needed
      programType: selectedProgramType,
      userId: userId.toString(),
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
        "Booking completed successfully!",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );

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

  // ------------------ NEW: File pick + upload helpers ------------------

  /// Pick a file based on the selected index:
  /// index == 0 -> Audio (.mp3)
  /// index == 1 -> Video (.mp4)
  Future<void> pickFileForType(int index) async {
    // Map index to type
    final wantAudio = index == 0;
    final allowedExt = wantAudio ? ['mp3'] : ['mp4'];

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExt,
        withData: false, // important to get bytes for upload
        allowMultiple: false,
      );

      if (result == null) {
        // user cancelled
        setState(() {
          uploadStatus = "File selection cancelled.";
          // Do not clear previously selected file (so user doesn't lose it)
        });
        return;
      }

      setState(() {
        selectedFile = result.files.first;
        selectedFileType = wantAudio ? 'Audio' : 'Video';
        uploadStatus = "Selected ${selectedFile!.name}";
      });

      // Optionally start upload immediately:
      // await uploadSelectedFile(); // comment this line if you want manual upload only
    } catch (e) {
      setState(() {
        uploadStatus = "Error picking file: $e";
      });
      print("Error picking file: $e");
    }
  }

  /// Upload the currently selected file to backend.
  /// Uses AppUrl.FileUploadURL (please ensure it's defined in your AppUrl).
Future<void> uploadSelectedFile() async {


    if (programNameController.text.isEmpty) {
    Fluttertoast.showToast(msg: "Please enter program name");
    return;
  }

  if (programDescriptionController.text.isEmpty) {
    Fluttertoast.showToast(msg: "Please enter program description");
    return;
  }

  if (selectedLanguage == null || selectedLanguage!.isEmpty) {
    Fluttertoast.showToast(msg: "Please select language");
    return;
  }

  if (selectedFileType == null && selectedProgramType.isEmpty) {
    Fluttertoast.showToast(msg: "Please select program type");
    return;
  }

  if (widget.selectedSlots.isEmpty) {
    Fluttertoast.showToast(msg: "Please select a slot");
    return;
  }

  if (selectedFile == null || selectedFile!.path == null) {
    Fluttertoast.showToast(msg: "No file selected to upload.");
    return;
  }

  setState(() {
    isUploading = true;
    uploadStatus = "Uploading ...";
    uploadProgress = 0.0; // ⬅️ ADDED
  });

  try {
    final file = File(selectedFile!.path!);
    final uri = Uri.parse(AppUrl.FileuploadUrl);
    final request = http.MultipartRequest('POST', uri);

    // Existing Fields (NOT Removed)
    request.fields['user_id'] = userId.toString();
    request.fields['program_name'] = programNameController.text;
    request.fields['program_description'] = programDescriptionController.text;
    request.fields['language'] = selectedLanguage ?? "English";
    request.fields['program_type'] = selectedFileType ?? selectedProgramType;
    request.fields['program_mode'] = programMode.toLowerCase();
    request.fields['payment_id'] =
        "wallet_${userId}_${DateTime.now().millisecondsSinceEpoch}";
    request.fields['slots'] = jsonEncode(widget.selectedSlots.map((slot) {
      if (slot is Map<String, dynamic>) {
        return {
          "slot_id": slot["slotId"] ?? slot["slot_id"],
          "date": slot["date"] ?? widget.selectedDate[0],
        };
      } else if (slot is slot_model.Data) {
        return {
          "slot_id": slot.slotId,
          "date": slot.date ?? widget.selectedDate[0],
        };
      } else {
        return {};
      }
    }).toList());

    // 🔥 Streaming Upload (Progress Enabled)
    final totalBytes = await file.length(); // ⬅️ ADDED
    int sentBytes = 0; // ⬅️ ADDED

    final stream = file.openRead().transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (data, sink) {
          sentBytes += data.length;
          setState(() {
           uploadProgress = sentBytes / totalBytes;
          });
          sink.add(data);
        },
      ),
    ); // ⬅️ ADDED

    final multipartFile = http.MultipartFile(
      'file',
      stream,
      totalBytes,
      filename: selectedFile!.name,
    ); // ⬅️ ADDED

    request.files.add(multipartFile); // ✔️ Your original logic

    // Sending request
    final streamedResponse = await request.send();
    final resp = await http.Response.fromStream(streamedResponse);

    if (streamedResponse.statusCode == 200 ||
    streamedResponse.statusCode == 201) {
  setState(() {
    uploadStatus = "Upload successful: ${selectedFile!.name}";
    uploadProgress = 1.0;
  });

  Fluttertoast.showToast(msg: "Slot booked successfully.");

  // ⬇⬇⬇ Correct: Navigation after success
  Future.delayed(Duration(milliseconds: 500), () {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    }
  });
}

  } catch (e) {
    setState(() {
      uploadStatus = "Upload error: $e";
    });
    Fluttertoast.showToast(msg: "Upload failed: $e");
  } finally {
    setState(() {
      isUploading = false;
    });
  }
}




  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Top decorative image
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

          // Main content
          GestureDetector(
             onTap: () {
                FocusScope.of(context).unfocus(); // Hide keyboard
              },
            child: SingleChildScrollView(
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
                    SizedBox(height: 20),
            
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Slot Details Card
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
                                      Text('Radio: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Radio: ${widget.radioname}', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  ...parsedSlots.asMap().entries.map((entry) {
                                    int index = entry.key + 1;
                                    String start = entry.value["start"]!;
                                    String end = entry.value["end"]!;
            
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Text('Slot $index: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text("$start - $end"),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
            
                          SizedBox(height: 16),
                          Text('Program Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Material(
                            child: TextField(
                              controller: programNameController,
                              focusNode: _programNameFocus,
                              decoration: InputDecoration(
                                hintText: 'Enter program name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colours.textColour),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colours.primarycolour),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Program Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Material(
                            child: TextField(
                              focusNode: _programDescriptionFocus,
                              maxLines: 3,
                              controller: programDescriptionController,
                              decoration: InputDecoration(
                                hintText: 'Enter Description',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colours.textColour),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colours.primarycolour),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Language:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
            
                          Obx(() {
                            if (languageController.isLoading.value) {
                              return Center(child: CircularProgressIndicator());
                            }
            
                            if (languageController.allLanguages.isEmpty) {
                              return Center(child: Text("No languages available"));
                            }
            
                            return MultiSelectDialogField(
                              items: languageController.allLanguages.map((lang) => MultiSelectItem(lang, lang)).toList(),
                              title: Text("Select Languages", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
                              searchable: true,
                              searchHint: "Search languages...",
                              selectedColor: Colours.primarycolour,
                              dialogHeight: languageController.allLanguages.length > 6 ? 400 : null,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colours.textColour),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              buttonIcon: Icon(Icons.arrow_drop_down, color: Colours.primarycolour),
                              buttonText: Text("Select Languages", style: TextStyle(color: Colours.textColour)),
                              onConfirm: (results) {
                                languageController.selectedLanguages.assignAll(results.cast<String>());
                              },
                              chipDisplay: MultiSelectChipDisplay(
                                onTap: (value) {
                                  languageController.selectedLanguages.remove(value);
                                },
                              ),
                            );
                          }),
            
                          SizedBox(height: 20),
            
                          /// 🆕 Program Mode Section
                          Text('Program Mode:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text('Live', style: TextStyle(fontSize: 13)),
                                  value: 'Live',
                                  groupValue: programMode,
                                 onChanged: (value) {
  setState(() {
    programMode = value!;
    if (programMode == 'Live') {
      selectedFile = null;
      uploadStatus = "";
      uploadProgress = 0.0;
    }
  });

  print("🔁 PROGRAM MODE CHANGED: $programMode");
},

                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text('Recorded', style: TextStyle(fontSize: 13)),
                                  value: 'Recorded',
                                  groupValue: programMode,
                                  onChanged: (value) {
                                    setState(() {
                                      programMode = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
            
                          if (programMode == 'Recorded') ...[
                            SizedBox(height: 8),
                            Text('Recorded Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text('Single Time', style: TextStyle(fontSize: 13)),
                                    value: 'Single',
                                    groupValue: repeatType,
                                    onChanged: (value) {
                                      setState(() {
                                        repeatType = value!;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text('Repeat', style: TextStyle(fontSize: 13)),
                                    value: 'Repeated',
                                    groupValue: repeatType,
                                    onChanged: (value) {
                                      setState(() {
                                        repeatType = value!;
                                        // Navigate if user chooses repeat — keep behavior
                                        if (repeatType == 'Repeated') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => TimeSlotPage(radioid: widget.radioid, radioname: widget.radioname)),
                                          );
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
            
                          SizedBox(height: 16),
            
                          /// Existing Program Type (Audio/Video)
                          Text('Program Type :', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 15),
                          Center(
                            child: ToggleSwitch(
                              minWidth: 100.0,
                              initialLabelIndex: selectedIndex,
                              cornerRadius: 20.0,
                              activeFgColor: Colors.white,
                              inactiveBgColor: Colours.brownColour,
                              inactiveFgColor: Colors.white,
                              totalSwitches: 2,
                              labels: ['Audio', 'Video'],
                              icons: [Icons.mic, Icons.videocam],
                              activeBgColors: [
                                [Colours.primarycolour],
                                [Colours.primarycolour]
                              ],
                      onToggle: (index) async {
  if (index == null) return;

  setState(() {
    selectedIndex = index;
    selectedProgramType = index == 0 ? 'Audio' : 'Video';
  });

  print("🎥 PROGRAM TYPE CHANGED: $selectedProgramType");
  print("🎭 PROGRAM MODE (Live/Recorded): $programMode");

  // ✅ File picker ONLY for RECORDED
  if (programMode == 'Recorded') {
    print("📼 RECORDED → OPEN FILE PICKER");
    await pickFileForType(index);
  } else {
    print("🟢 LIVE → FILE PICKER BLOCKED");
  }
},

                            ),
                          ),
            
                          // ----------------- Display selected file info and upload -----------------
                          SizedBox(height: 12),
                          if (selectedFile != null) ...[
                            // Text('Selected ${selectedFileType ?? selectedProgramType}:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        selectedFile!.name,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      selectedFile!.size != null
                                          ? '${(selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB'
                                          : '',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                    ),
            
                                    // ⬇️ ADDED — Show progress %
                                    if (isUploading) ...[
                                      SizedBox(height: 6),
                                      LinearProgressIndicator(
                                        value: uploadProgress, // ← Controlled from upload function
                                        minHeight: 6,
                                        backgroundColor: Colors.grey[300],
                                        color: Colors.blue,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${(uploadProgress * 100).toStringAsFixed(0)}%", // 0% → 100%
                                        style: TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // SizedBox(width: 8),
            
                              // // ⬇️ Modified — Circular loader replaced by progress %
                              // if (isUploading)
                              //   SizedBox(
                              //     width: 36,
                              //     height: 36,
                              //     child: CircularProgressIndicator(
                              //       value: uploadProgress,
                              //       strokeWidth: 3,
                              //     ),
                              //   )
                              // else
                                
                            ],
                          ),
            
                            // SizedBox(height: 6),
                            // Text(uploadStatus, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                          ],
                          // else ...[
                            // Text('No file selected yet.', style: TextStyle(color: Colors.grey[700])),
                          // ],
                                  SizedBox(height: 40),
            
                                ElevatedButton(
  onPressed: () {
    print("🚀 BOOK SLOT CLICKED");
    print("🎭 PROGRAM MODE: $programMode");
    print("🎥 PROGRAM TYPE: $selectedProgramType");

    if (programMode == 'Live') {
      print("🟢 LIVE FLOW → CALL createOrder()");
      createOrder(); // ✅ LIVE booking
    } else {
      print("📼 RECORDED FLOW → CALL uploadSelectedFile()");
      uploadSelectedFile(); // ✅ RECORDED booking
    }
  },
  style: ElevatedButton.styleFrom(
    fixedSize: Size(screenWidth * 0.8, screenHeight * 0.06),
    backgroundColor: Colours.primarycolour,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
  child: Text(
    'Book slot',
    style: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
  ),
),

                          
            
                          // /// Wallet checkbox and payment button
                          // Row(
                          //   children: [
                          //     Checkbox(
                          //       value: _isChecked,
                          //       onChanged: (bool? value) {
                          //         setState(() {
                          //           _isChecked = value ?? false;
                          //         });
                          //       },
                          //     ),
                          //     Obx(() {
                          //       return Text(
                          //         'Wallet Balance: ₹ ${walletBalanceController.walletBalanceAmount.value}',
                          //         style: TextStyle(
                          //           fontSize: screenHeight * 0.02,
                          //           fontWeight: FontWeight.w500,
                          //           color: Colours.black,
                          //         ),
                          //       );
                          //     })
                          //   ],
                          // ),
            
                          // SizedBox(height: 20),
                          // Center(
                          //   child: ElevatedButton(
                          //     onPressed: () {
                          //       if (_isChecked) {
                          //         createOrderThroughWallet();
                          //       } else {
                          //         createOrder();
                          //       }
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //       fixedSize: Size(screenWidth * 0.8, screenHeight * 0.07),
                          //       backgroundColor: Colours.primarycolour,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(15),
                          //       ),
                          //     ),
                          //     child: Text(
                          //       "Pay ₹${widget.totalAmount}",
                          //       style: TextStyle(
                          //         fontSize: screenHeight * 0.025,
                          //         fontWeight: FontWeight.w600,
                          //         color: Colours.secondarycolour,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
