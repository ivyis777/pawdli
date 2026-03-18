import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/paymnetcontroller.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class MypaymentsPage extends StatefulWidget {
  @override
  _MypaymentsPageState createState() => _MypaymentsPageState();
}

class _MypaymentsPageState extends State<MypaymentsPage> {
  final PaymentTransactionController paymentController = Get.put(PaymentTransactionController());
  String? selectedPaymentType = 'All';
  String? selectedPaymentDate;

  @override
  void initState() {
    super.initState();

    tz.initializeTimeZones(); // ✅ Initialize timezone
    final box = GetStorage();
    final userId = box.read(LocalStorageConstants.userId);

    paymentController.fetchUserPayments(userId);
  }

  String formatToIST(DateTime utcDateTime) {
    final india = tz.getLocation('Asia/Kolkata');
    final istDateTime = tz.TZDateTime.from(utcDateTime, india);
    return DateFormat('dd-MM-yyyy : HH:mm').format(istDateTime);
  }

 
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedPaymentDate = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      body: Stack(
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
              PreferredSize(
                preferredSize: Size.fromHeight(screenHeight * 0.12),
                child: AppBar(
                  title: Text(
                    ' My Payments',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                      color: Colours.black,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
              Expanded(
                child: GetBuilder<PaymentTransactionController>(
                  builder: (controller) {
                    final payments = controller.payments;

                    final filteredPayments = payments.where((payment) {
                      final paymentType = payment.purpose;
                      final paymentDateOnly = DateFormat('dd-MM-yyyy').format(payment.transactionDate);

                       bool typeFilter = selectedPaymentType == 'All' || selectedPaymentType == null || paymentType == selectedPaymentType;
                      bool dateFilter = selectedPaymentDate == null || paymentDateOnly == selectedPaymentDate;

                      return typeFilter && dateFilter;
                    }).toList();

                   final uniqueTypes = ['All', ...{...payments.map((e) => e.purpose)}];
                    final uniqueDates = payments
                        .map((e) => DateFormat('dd-MM-yyyy').format(e.transactionDate))
                        .toSet()
                        .toList();

                    if (controller.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(screenSize.width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Payment Type Dropdown
                                Container(
                                  width: screenSize.width * 0.45,
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedPaymentType,
                                    hint: Text("Payment Type"),
                                    isExpanded: true,
                                    underline: SizedBox(),
                                    items: uniqueTypes.map((String type) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedPaymentType = newValue;
                                      });
                                    },
                                  ),
                                ),
                                // Payment Date Calendar Selector
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    width: screenSize.width * 0.45,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedPaymentDate ?? "Payment Date",
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.040,
                                            fontWeight: FontWeight.bold,
                                            
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Icon(Icons.calendar_today, size: screenSize.width * 0.05),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenSize.height * 0.02),
                            if (filteredPayments.isEmpty)
                              Center(child: Text("No payments found."))
                            else
                              ...filteredPayments.map((payment) {
                                final dateStr = formatToIST(payment.transactionDate);
                                return Container(
                                  width: screenSize.width * 0.96,
                                  margin: EdgeInsets.only(bottom: screenSize.height * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(screenSize.width * 0.03),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: payment.purpose,
                                                    style: TextStyle(
                                                      fontSize: screenSize.width * 0.04,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  if (payment.programName != null)
                                                    TextSpan(
                                                      text: ' - ${payment.programName}',
                                                      style: TextStyle(
                                                        fontSize: screenSize.width * 0.035,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: screenSize.height * 0.01),
                                            Text(
                                              'Paid on: $dateStr',
                                              style: TextStyle(
                                                fontSize: screenSize.width * 0.03,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Text(
                                          '₹${payment.amount}',
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.05,
                                            fontWeight: FontWeight.bold,
                                            color: Colours.black,
                                          ),
                                        ),
                                       SizedBox(width: screenSize.width * 0.02),
GestureDetector(
  onTap: () async {
    String transactionId = payment.razorpayTransactionId;

    File? pdfFile = await ApiService.downloadPdfWithToken(transactionId);

    if (pdfFile != null) {
      await OpenFilex.open(pdfFile.path);
    } else {
      print("⚠️ Could not download or open the PDF.");
    }
  },


  child: payment.purpose != 'Wallet' 
    ? Image.asset(
        'assets/images/pdf.png',
        width: screenSize.width * 0.1,
        height: screenSize.height * 0.05,
        fit: BoxFit.cover,
      )
    : Container(),  // No image shown for wallet payments
),


                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
