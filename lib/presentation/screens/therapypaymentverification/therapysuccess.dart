import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/paymentverificationcontroller.dart';
import 'package:pawlli/data/model/paymentverificationmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';

class TherapyPaymentsuccess extends StatefulWidget {
  final String orderId;
  final String? paymentId;
  final String? signature;

  const TherapyPaymentsuccess({
    super.key,
    required this.orderId,
     this.paymentId,
     this.signature,

  });

  @override
  State<TherapyPaymentsuccess> createState() => _TherapyPaymentsuccessState();
}

class _TherapyPaymentsuccessState extends State<TherapyPaymentsuccess> {
  final PaymentController paymentController = Get.put(PaymentController());
  late Future<PaymentVerificationModel?> paymentFuture;

  @override
  void initState() {
    super.initState();
     print("🔍 Therapy Payment Debug:");
  print("Order ID: ${widget.orderId}");
  print("Payment ID: ${widget.paymentId}");
  print("Signature: ${widget.signature}");
  
    paymentFuture = paymentController.verifyPayment(
    razorpay_order_id: widget.orderId,
      razorpay_payment_id: widget.paymentId.toString(),
      razorpay_signature: widget.signature.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

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
                    'Payment',
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
     FutureBuilder<PaymentVerificationModel?>(
        future: paymentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Payment verification failed."));
          }

          var paymentData = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colours.seachbarcolour,
                      borderRadius: BorderRadius.circular(36.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8.0,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Center(
                            child: Text(
                              paymentData.message ?? 'Payment Success!',
                              style: TextStyle(
                                fontSize: screenHeight * 0.02,
                                fontWeight: FontWeight.w300,
                                color: Colours.black,
                                fontFamily: FontFamily.Ubantu,
                              ),
                            ),
                          ),
                          
   SizedBox(height: screenHeight * 0.01),
Center(
  child: Text(
    '₹ ${paymentData.amount?.toString() ?? '0'}',
    style: TextStyle(
      fontSize: screenHeight * 0.025,
      fontWeight: FontWeight.bold,
      color: Colours.black,
      fontFamily: FontFamily.Ubantu,
    ),
  ),
),


                          SizedBox(height: screenHeight * 0.025),
                          Divider(
                            color: Colours.textColour,
                            thickness: 1.0,
                          ),
       SizedBox(height: screenHeight * 0.025),
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Ref Number: ',
          style: TextStyle(
            fontSize: screenHeight * 0.022,
            color: Colours.darkgreyColour,
            fontWeight: FontWeight.w400,
            fontFamily: FontFamily.Ubantu,
          ),
        ),
        Expanded(
          child: Text(
            paymentData.paymentId ?? 'N/A',
            style: TextStyle(
              fontSize: screenHeight * 0.022,
              fontWeight: FontWeight.w400,
              color: Colours.textColour,
              fontFamily: FontFamily.Ubantu,
            ),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
    SizedBox(height: screenHeight * 0.01),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Date:',
          style: TextStyle(
            fontSize: screenHeight * 0.022,
            color: Colours.darkgreyColour,
            fontWeight: FontWeight.w400,
            fontFamily: FontFamily.Ubantu,

          ),
        ),
        Text(
  paymentData.date ?? 'N/A',
  style: TextStyle(
    fontSize: screenHeight * 0.022,
    
    fontWeight: FontWeight.w400,
    color: Colours.textColour,
    fontFamily: FontFamily.Ubantu,
  ),
   softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
),

      ],
    ),
    
    SizedBox(height: screenHeight * 0.01),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Payment Method:',
          style: TextStyle(
            fontSize: screenHeight * 0.022,
            color: Colours.darkgreyColour,
            fontWeight: FontWeight.w400,
            fontFamily: FontFamily.Ubantu,
          ),
        ),
        Text(
          paymentData.paymentMethod ?? 'N/A',
          style: TextStyle(
            fontSize: screenHeight * 0.022,
            fontWeight: FontWeight.w400,
            color: Colours.textColour,
            fontFamily: FontFamily.Ubantu,
          ),
        ),
      ],
    ),
  ],
),

                             
                          SizedBox(height: screenHeight * 0.015),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()),);
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(
                                screenWidth * 0.8,
                                screenHeight * 0.07,
                              ),
                              backgroundColor: Colours.primarycolour,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Done",
                              style: TextStyle(
                                fontSize: screenHeight * 0.025,
                                fontWeight: FontWeight.w600,
                                color: Colours.secondarycolour,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
        ])]));
  }
}