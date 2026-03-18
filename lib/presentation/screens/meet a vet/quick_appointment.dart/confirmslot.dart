import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/reviewpage.dart';



class ReviewandpayPage extends StatefulWidget {
  const ReviewandpayPage({super.key});
  @override
  State<ReviewandpayPage> createState() => _ReviewandpayPageState();
}
class _ReviewandpayPageState extends State<ReviewandpayPage> {
  TextEditingController _couponController = TextEditingController();
  bool _useWallet = false; // State for checkbox

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Review & Pay",
          style: TextStyle(
            fontSize: 20,
           
            fontWeight: FontWeight.w500,
             fontFamily: FontFamily.Cairo,
            color: Colours.brownColour,
          ),
        ),
        backgroundColor: Colours.primarycolour,
        centerTitle: true,
        foregroundColor: Colours.brownColour,
      ),
      backgroundColor: Colours.secondarycolour,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenWidth * 1.0,
                child: Card(
                  color: Colours.secondarycolour,
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Name: Rakesh Kumar K',
                          style: TextStyle(
                            fontSize: 16,
                    
                            fontWeight: FontWeight.w500,
                            fontFamily: FontFamily.Cairo,
            color: Colours.black,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Age: 24 Years',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          fontFamily: FontFamily.Cairo,
            color: Colours.black,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Doctor: Dr. Chomon Aktar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                      fontFamily: FontFamily.Cairo,
            color: Colours.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
             
       
              
              SizedBox(height: 16.0),
              Text(
                'Images',
                style: TextStyle(
                  fontSize: 20,
        
                  fontWeight: FontWeight.w500,
            fontFamily: FontFamily.Cairo,
            color: Colours.black,
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: screenWidth,
                height: 150,
                color: Colours.secondarycolour,
              ),
              SizedBox(height: 16.0),
              Text(
                'Issue Description:',
                style: TextStyle(
                  fontSize: 20,
     
                  fontWeight: FontWeight.w500,
                 fontFamily: FontFamily.Cairo,
            color: Colours.black,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'I Have Problem in My Hair. I Have Problem in My Hair. I Have Problem in My Hair.',
                style: TextStyle(
                  fontSize: 17,
        
                  fontWeight: FontWeight.w400,
                 fontFamily: FontFamily.Cairo,
            color: Colours.black,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Symptoms',
                style: TextStyle(
                  fontSize: 20,
      
                  fontWeight: FontWeight.w500,
                 fontFamily: FontFamily.Cairo,
            color: Colours.black,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Pimples ,Rashes,Pimples,Rashes',
                style: TextStyle(
                  fontSize: 17,
   
                  fontWeight: FontWeight.w400,
               fontFamily: FontFamily.Cairo,
            color: Colours.black,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  SizedBox(width: 4.0),
                  Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                  
            color: Colours.black,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                 
            color: Colours.black,
                      thickness: 2.0,
                    ),
                  ),
                  Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colours.black
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Cost',
                    style: TextStyle(
                      fontSize: 18,
           
                      fontWeight: FontWeight.w500,
                       fontFamily: FontFamily.Cairo,
            color: Colours.black,
                    ),
                  ),
                  Text(
                    '\$367.65',
                    style: TextStyle(
                      fontSize: 18,
             
                      fontWeight: FontWeight.w500,
                           fontFamily: FontFamily.Cairo,
            color: Colours.primarycolour,
             
                    ),
                  ),
                ],
              ),
              ListTile(
                leading: Text(
                  'Coupon ',
                  style: TextStyle(
                
                    fontWeight: FontWeight.w500,
                     fontFamily: FontFamily.Cairo,
            color: Colours.black,
                  ),
                ),
                title: Container(
                  width: screenWidth,
                  height: 40,
                  color: Colours.textColour,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _couponController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                trailing: Text(
                  '\$0.00',
                  style: TextStyle(
                    fontSize: 18,
             
                    fontWeight: FontWeight.w500,
                      fontFamily: FontFamily.Cairo,
            color: Colours.primarycolour,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ListTile(
                leading: Checkbox(
                  value: _useWallet,
                  onChanged: (bool? value) {
                    setState(() {
                      _useWallet = value ?? false; 
                    });
                  },
                ),
                title: Text(
                  'Use Wallet - \$1200',
                  style: TextStyle(
                    fontSize: 18,
                
                    fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.Cairo,
            color: Colours.black,
                  ),
                ),
                trailing: Text(
                  '\$0.00',
                  style: TextStyle(
                    fontSize: 18,
                   
                    fontWeight: FontWeight.w500,
                         fontFamily: FontFamily.Cairo,
            color: Colours.black,
             
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Payable',
                    style: TextStyle(
                      fontSize: 20,
                      
                      fontWeight: FontWeight.w500,
                         fontFamily: FontFamily.Cairo,
            color: Colours.black,
                    ),
                  ),
                  Text(
                    '\$367.65',
                    style: TextStyle(
                      fontSize: 20,
               
                      fontWeight: FontWeight.w500,
      fontFamily: FontFamily.Cairo,
            color: Colours.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: screenWidth,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Colours.primarycolour,
                    ),
                    onPressed: () {
                        _showPaymentSuccessDialog(context);
                    },
                    child: Text(
                      'Payment now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                           fontFamily: FontFamily.Cairo,
            color: Colours.secondarycolour,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
   void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                CircleAvatar(
                      radius: 60,
                      backgroundColor: Colours.primarycolour,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      Assets.images.dogcat.path,
                      height: 100,
                      width: 100,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Your Payment \n  Is Successful!',
                  style: TextStyle(
                    fontSize: 20,
                  
                    fontWeight: FontWeight.w600,
                     fontFamily: FontFamily.Cairo,
            color: Colours.black,
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Colours.primarycolour,
                    ),
                    onPressed: () {
                      Get.to(Appointmentreviewpage());
                    },
                    child: Text(
                      'okay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                          fontFamily: FontFamily.Cairo,
            color: Colours.secondarycolour,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

