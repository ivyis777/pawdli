import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/viewadoptioncontroller.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:get/get.dart';
import 'package:pawlli/presentation/screens/commonfullimage/fullimageview.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';

class AdoptionDescriptionPage extends StatefulWidget {
    final int Id;
  final String petProfileImage;
  const AdoptionDescriptionPage({super.key,required this.Id, required this.petProfileImage});

  @override
  State<AdoptionDescriptionPage> createState() => _AdoptionDescriptionPageState();
}

class _AdoptionDescriptionPageState extends State<AdoptionDescriptionPage> {
    final AdoptionPetController _controller = Get.put(AdoptionPetController());
  String? userId;

  @override
  void initState() {
    super.initState();
    final box = GetStorage();
    final storedUserId = box.read(LocalStorageConstants.userId);
    if (storedUserId != null) {
      userId = storedUserId.toString();
    }
  }
String getPetAgeText() {
  final pet = _controller.adoptionPets
      .firstWhereOrNull((p) => p.id == widget.Id);

  if (pet == null) return "N/A";

  // ✅ AGE FROM API OBJECT
  if (pet.ageDetails != null) {
    final y = pet.ageDetails!.years ?? 0;
    final m = pet.ageDetails!.months ?? 0;
    final d = pet.ageDetails!.days ?? 0;

    if (y == 0 && m == 0 && d == 0) return "N/A";

    return "${y}y ${m}m ${d}d";
  }

  // ✅ FALLBACK TO DOB
  if (pet.dateOfBirth != null && pet.dateOfBirth!.isNotEmpty) {
    try {
      final dob = DateTime.parse(pet.dateOfBirth!);
      final now = DateTime.now();

      int years = now.year - dob.year;
      int months = now.month - dob.month;

      if (now.day < dob.day) months--;
      if (months < 0) {
        years--;
        months += 12;
      }

      return "${years}y ${months}m";
    } catch (_) {
      return "N/A";
    }
  }

  return "N/A";
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colours.primarycolour,
        foregroundColor: Colours.secondarycolour,
      ),
      backgroundColor: Colours.primarycolour,
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

    
final pet = _controller.adoptionPets
    .firstWhereOrNull((p) => p.id == widget.Id);

        if (pet == null) {
          return const Center(
            child: Text(
              "No pet data available",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          );
        }
         String imageUrl = widget.petProfileImage;

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: screenWidth,
                height: screenHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 280,
                      left: 0,
                      right: 0,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: screenWidth,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // **Title**
                              Center(
                                child: Text(
                                  pet.name ?? "No Name",
                                  style: TextStyle(
                                    color: Colours.brownColour,
                                    fontFamily: FontFamily.Cairo,
                                    fontSize: screenWidth * 0.15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              // **Location**
                             Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colours.black,
                                  size: screenWidth * 0.07,
                                ),
                                const SizedBox(width: 9),

                                Expanded(
                                  child: Text(
                                    pet.location ?? "No Location",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colours.brownColour,
                                      fontFamily: FontFamily.Cairo,
                                      fontSize: screenWidth * 0.045, // slightly smaller for safety
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                              const SizedBox(height: 20),
                              // **Description**
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                child: Text(
                                  pet.description ?? "No Description",
                                  style: TextStyle(
                                    fontFamily: FontFamily.Cairo,
                                    fontSize: screenWidth * 0.05,
                                    color: Colours.textColour,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // **3 Cards in a Row**
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Age Card
                                Card(
                                  elevation: 3,
                                  child: Container(
                                    width: (screenWidth - 90) / 3,
                                    height: 100, // fixed height for the card content
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center, // center vertically
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Age',
                                          style: TextStyle(
                                            color: Colours.black,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8), // spacing between label and value
                                        Text(
                                          getPetAgeText(),
                                          style: TextStyle(
                                            color: Colours.brownColour,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Gender Card
                                Card(
                                  elevation: 3,
                                  child: Container(
                                    width: (screenWidth - 90) / 3,
                                    height: 100,
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Gender',
                                          style: TextStyle(
                                            color: Colours.black,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          pet.gender ?? "Unknown",
                                          style: TextStyle(
                                            color: Colours.brownColour,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Weight Card
                                Card(
                                  elevation: 3,
                                  child: Container(
                                    width: (screenWidth - 90) / 3,
                                    height: 100,
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Weight',
                                          style: TextStyle(
                                            color: Colours.black,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '${pet.weight ?? 0} kg',
                                          style: TextStyle(
                                            color: Colours.brownColour,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),                           
                              const SizedBox(height: 30),
                              // **Connect Button**
                              Center(
                                child: ElevatedButton(
                             onPressed: () async { Navigator.push(
                                        context,
                                  MaterialPageRoute(builder: (context) => HomePage(), // Replace with your HomePage widget
                                ));},
                                  
                                  child: Text(
                                    '${pet.mobileNumber ?? 0}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.Ubantu,
                                      color: Colours.secondarycolour,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(350, 60),
                                    backgroundColor: Colours.primarycolour,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // **Pet Image**
                  Positioned(
                  top: screenHeight * 0.06, // adjust as needed
                  left: 0,
                  right: 0,
                  child: Center(
                child: GestureDetector(
                          onTap: () {
                            if (imageUrl.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullImageView(imageUrl: imageUrl),
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: screenWidth * 0.30,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                imageUrl.isNotEmpty ? CachedNetworkImageProvider(imageUrl) : null,
                            child: imageUrl.isEmpty
                                ? Icon(
                                    Icons.pets,
                                    size: screenWidth * 0.20,
                                    color: Colors.brown,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.25),
            ],
          ),
        );
      }),
    );
  }
}
