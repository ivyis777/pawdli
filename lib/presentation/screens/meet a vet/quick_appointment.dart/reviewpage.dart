import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/fonts.gen.dart';


class Appointmentreviewpage extends StatefulWidget {
  const Appointmentreviewpage({super.key});

  @override
  State<Appointmentreviewpage> createState() => _AppointmentreviewpageState();
}

class _AppointmentreviewpageState extends State<Appointmentreviewpage> {
 

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Appointment Details",
          style: TextStyle(
            fontSize: 20,
   
            fontWeight: FontWeight.w500,
         fontFamily: FontFamily.Cairo,
                                 color: Colours.black,
          ),
        ),
        backgroundColor: Colours.primarycolour,
        centerTitle: true,
        foregroundColor: Colours.black,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paid',
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
                         fontFamily: FontFamily.Cairo,
                                 color: Colours.primarycolour,
                      fontWeight: FontWeight.w500,
       
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
                      // Get.to( DoctorRatingPage());
                    },
                    child: Text(
                      'Join Now',
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
}
