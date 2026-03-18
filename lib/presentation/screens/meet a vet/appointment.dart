import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/meetvetdoctor.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/petdetailspage.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colours.secondarycolour,
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

          Column(
            children: [
              // AppBar
              AppBar(
                title: Text(
                  'Appointment Mode',
                  style: TextStyle(
                    fontSize: screenHeight * 0.035,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.Cairo,
                    color: Colours.brownColour,
                  ),
                ),
                foregroundColor: Colours.brownColour,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),

              const SizedBox(height: 100),

              // Buttons in column
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.primarycolour,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                           Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PetDetailsPage (
                                        
                                        ),
                                      ),
                                    );
                        },
                        child: Text(
                          "Quick Appointment",
                          style: TextStyle(
                            fontSize: screenHeight * 0.022,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontFamily.Cairo,
                            color: Colours.secondarycolour,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colours.brownColour,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                   Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>MeetVetDoctorList (
                                        
                                        ),
                                      ),
                                    );
                        },
                        child: Text(
                          "Schedule Appointment",
                          style: TextStyle(
                            fontSize: screenHeight * 0.022,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontFamily.Cairo,
                            color: Colours.secondarycolour,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
