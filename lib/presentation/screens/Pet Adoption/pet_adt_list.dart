import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' as storage;
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/useradoptioncontroller.dart';
import 'package:pawlli/data/model/useradoptionmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/Pet%20Adoption/addpetadoption.dart';
import 'package:pawlli/presentation/screens/Pet%20Adoption/editpetadoption.dart';
import 'package:pawlli/presentation/screens/userprofile/userprofile.dart';

class AdoptionPets extends StatefulWidget {
  final bool fromUpdateFlow;
  const AdoptionPets({Key? key, this.fromUpdateFlow = false}) : super(key: key);

  @override
  _AdoptionPetsState createState() => _AdoptionPetsState();
}

class _AdoptionPetsState extends State<AdoptionPets> {
  final UserAdoptionController _controller = Get.put(UserAdoptionController ());

  @override
  void initState() {
    super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _controller.fetchUserAdoptionPetList();
  });// Fetch API on load
  }
  

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
  return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage(fromUpdateFlow: true)),
          (route) => true,
        );
        return false;
      },
 child:  Scaffold(
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
              AppBar(
                title: Text(
                  'Adoptions',
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
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_controller.adoptionPets.isEmpty) {
                    return const Center(child: Text("No pets found."));
                  }

                  final sortedPets = [..._controller.adoptionPets];
sortedPets.sort((a, b) {
  final aSold = a.isSoldout ?? false;
  final bSold = b.isSoldout ?? false;
  if (aSold == bSold) return 0;
  return aSold ? 1 : -1;
});

return ListView.builder(
  itemCount: sortedPets.length,
  itemBuilder: (context, index) {
    final pet = sortedPets[index];

                      final backgroundImage = index.isEven
                          ? Assets.images.yellowcard.path
                          : Assets.images.browncard.path;

                      return buildPetCard(
                        context,
                        screenWidth,
                        screenHeight,
                        pet,
                        backgroundImage,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPetAdoption()),
          );
        },
        backgroundColor: Colors.brown[600],
        child: Icon(Icons.add, color: Colours.secondarycolour),
      ),
    ));
  }
String getPetAge(UserAdoptionModel pet) {
  // ✅ 1. AGE OBJECT FROM API
  if (pet.ageDetails != null) {
    final y = pet.ageDetails!.years ?? 0;
    final m = pet.ageDetails!.months ?? 0;
    final d = pet.ageDetails!.days ?? 0;

    return "Age | ${y}y ${m}m ${d}d";
  }

  // ✅ 2. FALLBACK TO DOB
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

      return "Age | ${years}y ${months}m";
    } catch (_) {
      return "Age | N/A";
    }
  }

  return "Age | N/A";
}


 Widget buildPetCard(
  BuildContext context,
  double screenWidth,
  double screenHeight,
 UserAdoptionModel pet,
  String backgroundImage,
) {
  final bool isSold = pet.isSoldout == true;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: IgnorePointer(
      ignoring: isSold, // Freeze if sold
      child: Opacity(
        opacity: isSold ? 0.6 : 1.0, // Dim if sold
        child: GestureDetector(
          onTap: () {
            final petId = pet.id;
            if (petId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAdoptionPetPage(Id: petId),
                ),
              );
            } else {
              Get.snackbar("Error", "Pet ID is missing.");
            }
            print(petId);
          },
          child: Stack(
            children: [
              Container(
                width: screenWidth,
                height: screenHeight * 0.20,
                child: Image.asset(
                  backgroundImage,
                  fit: BoxFit.fill,
                ),
              ),
              if (isSold)
      Positioned(
        top: 8,
        right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'SOLD OUT',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
              fontFamily: FontFamily.Cairo,
            ),
          ),
        ),
      ),
              Positioned(
                left: screenWidth * 0.07,
                top: screenHeight * 0.015,
                right: screenWidth * 0.30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
  children: [
    Text(
      isSold ? "Sold" : (pet.mobileNumber ?? "Not Provided"),
      style: TextStyle(
        color: Colours.secondarycolour,
        fontFamily: FontFamily.Cairo,
        fontSize: screenWidth * 0.055,
        fontWeight: FontWeight.w600,
      ),
    ),
    SizedBox(width: screenWidth * 0.04),

    Text(
      getPetAge(pet), // ✅ SINGLE AGE
      style: TextStyle(
        color: Colours.secondarycolour,
        fontFamily: FontFamily.Cairo,
        fontSize: screenWidth * 0.04,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
),

                    const SizedBox(height: 1),
                    Text(
                      pet.isFree == true
                          ? "Type: Free"
                          : pet.isPaid == true
                              ? "Type: Paid"
                              : "Type: Not specified",
                      style: TextStyle(
                        color: Colours.secondarycolour,
                        fontFamily: FontFamily.Cairo,
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pet.description ?? "No description",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colours.secondarycolour,
                        fontFamily: FontFamily.Cairo,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: screenWidth * 0.06, color: Colours.secondarycolour),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            pet.location ?? "Unknown",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colours.secondarycolour,
                              fontFamily: FontFamily.Cairo,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
             if (pet.petProfileImage != null && pet.petProfileImage!.isNotEmpty)
  Positioned(
    right: screenWidth * 0.06,
    bottom: screenHeight * 0.022,
    child: CircleAvatar(
      radius: screenWidth * 0.15,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: CachedNetworkImageProvider(pet.petProfileImage!),
      onBackgroundImageError: (_, __) {}, // prevent crash
    ),
  )
else
  Positioned(
    right: screenWidth * 0.06,
    bottom: screenHeight * 0.022,
    child: CircleAvatar(
      radius: screenWidth * 0.15,
      backgroundColor: Colors.grey.shade200,
      child: Icon(
        Icons.pets, // fallback icon 🐾
        size: screenWidth * 0.12,
        color: Colours.brownColour,
      ),
    ),
  ),

            ],
          ),
        ),
      ),
    ),
  );
}
}