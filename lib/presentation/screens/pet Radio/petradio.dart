import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/allpetradiocontroller.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/pawlli%20radio/pawlli_radio.dart';


class Petradio extends StatefulWidget {
  const Petradio({super.key});

  @override
  State<Petradio> createState() => _PetradioState();
}

class _PetradioState extends State<Petradio> {
  final AllPetRadioController _petRadioController = Get.put(AllPetRadioController());
  final TextEditingController _searchController = TextEditingController();
  bool isBrownBackground = true; 
  bool isBrownRadio = true; 
 
  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
    _petRadioController.fetchRadioStations(); 
  });}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                    'PAWdLI Radio Stations',
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
              Expanded(
                child: Obx(() {
                  if (_petRadioController.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (_petRadioController.petRadioList.isEmpty) {
                    return Center(
                      child: Text(
                        "No Pet Radios Available",
                        style: TextStyle(
                          fontSize: screenHeight * 0.02,
                          fontFamily: FontFamily.Cairo,
                          color: Colours.black,
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _petRadioController.petRadioList.length,
    itemBuilder: (context, index) {
      final radioData = _petRadioController.petRadioList[index];
                            String backgroundImage = isBrownBackground
                                ? 'assets/images/browncard.png'
                                : 'assets/images/yellowcard.png';

                            String radioImage = isBrownRadio
                                ? 'assets/images/radio.png'
                                : 'assets/images/brownradio.png';

                            isBrownBackground = !isBrownBackground;
                            isBrownRadio = !isBrownRadio;

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.001,
                                vertical: screenHeight * 0.01,
                              ),
                              child: GestureDetector(
                                onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PawlliRadio(
            radioid: radioData.radiostationId,
            radioname: radioData.name.toString(),
                    
          ),
        ),
      );
    },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: screenWidth * 1.6,
                                      height: screenHeight * 0.20,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(backgroundImage),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: screenWidth * 0.65,
                                      bottom: screenHeight * 0.01,
                                      child: Image.asset(
                                        radioImage,
                                        width: screenWidth * 0.3,
                                        height: screenHeight * 0.2,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Positioned(
                                      left: screenWidth * 0.4,
                                      top: screenHeight * 0.025,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          
                                        SizedBox(
                                          
  width: screenWidth * 0.5, 
 
  child: Text(
    radioData.name ?? "Default Name",
    style: TextStyle(
      color: Colors.white,
      fontFamily: FontFamily.Cairo,
      fontSize: screenWidth * 0.06,
      fontWeight: FontWeight.w600,
    ),
    maxLines: null, // ✅ Allows unlimited lines if necessary
    overflow: TextOverflow.visible, // ✅ Prevents text from being cut off
    softWrap: true, // ✅ Ensures text wraps
  ),
),
SizedBox(height: 5),
SizedBox(
  width: screenWidth * 0.5, 
  child: Text(
    radioData.description ?? "Default Description",
    style: TextStyle(
      color: Colors.white,
      fontFamily: FontFamily.Cairo,
      fontSize: screenWidth * 0.04,
      fontWeight: FontWeight.w400,
    ),
    maxLines: null, 
    overflow: TextOverflow.visible, 
    softWrap: true, 
  ),
),SizedBox(height: 5),
                                          // Row(
                                          //   children: [
                                          //     Icon(Icons.public, color: Colors.white, size: screenWidth * 0.05),
                                          //     SizedBox(width: 5),
                                          //     Text(
                                          //      radioData.language ?? "Default Laugauage" ,
                                          //       style: TextStyle(
                                          //         color: Colors.white,
                                          //         fontFamily: FontFamily.Cairo,
                                          //         fontSize: screenWidth * 0.04,
                                          //         fontWeight: FontWeight.w500,
                                          //       ),
                                          //     ),
                                          
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: screenHeight * 0.2),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
     
    );
  }
}
