import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' as storage;
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/petslistcontroller.dart';
import 'package:pawlli/presentation/screens/add%20pet/addpet.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:pawlli/presentation/screens/petprofile/editpetprofile.dart';



class MyPets extends StatefulWidget {
  final bool fromUpdateFlow;
  const MyPets({Key? key, this.fromUpdateFlow = false}) : super(key: key);

  @override
  _MyPetsState createState() => _MyPetsState();
}

class _MyPetsState extends State<MyPets> {
  int? userId;
  final Petslistcontroller petsController = Get.put(Petslistcontroller());

  @override
  void initState() {
    super.initState();
    final box = storage.GetStorage();
    userId = box.read(LocalStorageConstants.userId);

    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        petsController.loadUserPets(userId!);
      });
    } else {
      print("User ID is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) =>HomePage()),
          (route) => true,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colours.secondarycolour,
        body: Stack(
          children: [
            Container(
              width: screenWidth * 0.55,
              height: screenHeight * 0.10,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/topimage.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                AppBar(
                  title: Text(
                    'My Pets',
                    style: TextStyle(
                      fontSize: screenHeight * 0.035,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                      color: Colors.brown,
                    ),
                  ),
                  foregroundColor: Colors.brown,
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                const SizedBox(height: 10),
                 Expanded(
                  child: Obx(() {
                    if (petsController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (petsController.errorMessage.isNotEmpty) {
                      return Center(
                        child: Text(
                          petsController.errorMessage.value,
                          style: TextStyle(
                              color: Colours.brownColour, fontSize: 16),
                        ),
                      );
                    }
                    if (petsController.userPets.isEmpty) {
                      return const Center(
                        child: Text(
                          "No pets found",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    final sortedPets = [...petsController.userPets];
                    sortedPets.sort((a, b) {
                      final aUpdated = DateTime.tryParse(a.updatedAt ?? '') ??
                          DateTime.tryParse(a.createdAt ?? '') ??
                          DateTime(1970);
                      final bUpdated = DateTime.tryParse(b.updatedAt ?? '') ??
                          DateTime.tryParse(b.createdAt ?? '') ??
                          DateTime(1970);
                      return bUpdated.compareTo(aUpdated);
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      itemCount: sortedPets.length,
                      itemBuilder: (context, index) {
                        final pet = sortedPets[index];

                        final backgroundImage = index.isEven
                            ? 'assets/images/yellowcard.png'
                            : 'assets/images/browncard.png';

                 
                        String? petImagePath = pet.petProfileImage;
                        String petImageUrl =
                            (petImagePath != null && petImagePath.isNotEmpty)
                                ? '$petImagePath'
                                : '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditPetPage(PetId: pet.petId),
                                ),
                              );
                            },
                            child: _buildAvatarWithBackground(
                              screenWidth,
                              screenHeight,
                              backgroundImage,
                              petImageUrl,
                              pet.name ?? "Unknown",
                            ),
                          ),
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
              MaterialPageRoute(builder: (context) => AddPetPage()),
            );
          },
          backgroundColor: Colors.brown[600],
          child: Icon(Icons.add, color: Colours.secondarycolour),
        ),
      ),
    );
  }

  
  Widget _buildAvatarWithBackground(
    double screenWidth,
    double screenHeight,
    String backgroundImage,
    String petImage,
    String name,
  ) {

    ImageProvider imageProvider;

    if (petImage.isNotEmpty) {
      if (petImage.startsWith('http')) {
        imageProvider = CachedNetworkImageProvider(petImage);
      } else if (petImage.startsWith('/media')) {
        imageProvider = CachedNetworkImageProvider('$petImage');
      } else {
        imageProvider =
            const AssetImage('assets/images/default_pet_avatar.png');
      }
    } else {
      imageProvider = const AssetImage('assets/images/default_pet_avatar.png');
    }

    return Container(
      width: screenWidth,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            backgroundImage,
            width: screenWidth,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 20,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colours.secondarycolour,
                  radius: screenWidth * 0.1,
                  backgroundImage: imageProvider,
                  onBackgroundImageError: (_, __) {
                    // fallback if cached image fails
                  },
                  child: (petImage.isEmpty)
                      ? const Icon(Icons.pets, color: Colors.white, size: 40)
                      : null, // 🐾 show paw icon if no image
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: screenWidth * 0.5,
                  child: Center(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: screenHeight * 0.025,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }}