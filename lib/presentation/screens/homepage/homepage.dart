import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/competition_controller.dart';
import 'package:pawlli/data/controller/getuserprofilecontroller.dart';
import 'package:pawlli/data/controller/petslistcontroller.dart';
import 'package:pawlli/data/controller/reelitemcontroller.dart';
import 'package:pawlli/data/controller/updateuserprofilecontroller.dart';
import 'package:pawlli/gen/assests.gen.dart'; 
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/Pet%20Adoption/pet_adt_view.dart';
import 'package:pawlli/presentation/screens/add%20pet/addpet.dart';
import 'package:pawlli/presentation/screens/good%20bye%20buddy/goodbyebudddy.dart';
import 'package:pawlli/presentation/screens/homepage/countdownbutton.dart';
import 'package:pawlli/presentation/screens/notification%20page/notificationpage.dart';
import 'package:pawlli/presentation/screens/pet%20Radio/petradio.dart';
import 'package:pawlli/presentation/screens/pet%20store/pet_storemain.dart';
import 'package:pawlli/presentation/screens/pet%20therapy/pet_therapy.dart';
import 'package:pawlli/presentation/screens/petprofile/editpetprofile.dart';
import 'package:pawlli/presentation/screens/potcast/potcast.dart';
import 'package:pawlli/presentation/screens/reelspage/reels.dart';
import 'package:pawlli/presentation/screens/types%20of%20categaries/typesofcategaries.dart';
import 'package:pawlli/presentation/screens/userprofile/userprofile.dart';
import 'package:pawlli/presentation/screens/walletpage/walletpage.dart'; 
import 'package:get/get.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double speed; // 👈 REAL speed (px per frame)

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.speed = 0.001, // 👈 slow & smooth
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  final ScrollController _controller = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (!_controller.hasClients) return;

    final maxScroll = _controller.position.maxScrollExtent;
    if (maxScroll <= 0) return; // no overflow → no marquee

    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_controller.hasClients) return;

      final next = _controller.offset + widget.speed;

      if (next >= maxScroll) {
        _controller.jumpTo(0); // restart cleanly
      } else {
        _controller.jumpTo(next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final UserProfileController userProfileController =
    Get.put(UserProfileController());


  final Petslistcontroller petController = Get.find<Petslistcontroller>();
  final ReelsController reelController = Get.find<ReelsController>();

  final CompetitionController competitionController =
      Get.put(CompetitionController(), permanent: true);



@override
void initState() {
  super.initState();
  print("🏠 HomePage initState → CompetitionController CREATED");


  // ✅ Load user profile ONCE
  final userId = int.tryParse(
    GetStorage().read('userId')?.toString() ?? '',
  );

  if (userId != null) {
    userProfileController.loadUserProfile(userId);
  }



  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (reelController.reels.isEmpty) {
      reelController.fetchReels();
    }
  });
}

 

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive padding
    double horizontalPadding = screenWidth * 0.037; // 5% of screen width
    double verticalPadding = screenHeight * 0.010; // 2% of screen height

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
                 SizedBox(height: screenHeight*0.035),
            // Top image with CircleAvatar on top of it
 Stack(
  children: [
    // Background image (unchanged)
    Positioned(
      child: Container(
        width: screenWidth * 0.65,
        height: screenHeight * 0.12,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.images.topimage.path),
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
    
    // Avatar and Icons Row
    Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          // Profile Avatar
         GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  },
  child: Obx(() {
    final profile = userProfileController.userProfile.value;
    final String imageUrl = profile?.profilePicture ?? '';

    print("🖼 FINAL IMAGE URL => $imageUrl");

    return CircleAvatar(
      radius: 32,
      backgroundColor: Colors.white,

        child: CircleAvatar(
    radius: 30, // ⬅️ inner avatar radius
    backgroundColor: Colours.primarycolour,

      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(strokeWidth: 2),
                errorWidget: (context, url, error) =>
                    Image.asset(Assets.images.hpsittingdog.path),
              )
            : Image.asset(
                Assets.images.hpsittingdog.path,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
      ),
      ),
    );
  }),
),


          Spacer(),

          // Wallet Icon (unchanged)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyWalletPage()),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: screenWidth * 0.08,
                  color: Colours.brownColour,
                ),
              ),
            ),
          ),

          SizedBox(width: 15),

          // Notification Icon (unchanged)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.notifications,
                  size: screenWidth * 0.08,
                  color: Colours.brownColour,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Title Row
    Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
       
      ),
    ),

    // Scrollable Pet Avatars using Obx
   Padding(
  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
  child: Obx(() {
    final pets = petController.userPets;
   final sortedPets = [...pets];
sortedPets.sort((a, b) {
  final aUpdated = DateTime.tryParse(a.updatedAt ?? '') ??
      DateTime.tryParse(a.createdAt ?? '') ??
      DateTime(1970);
  final bUpdated = DateTime.tryParse(b.updatedAt ?? '') ??
      DateTime.tryParse(b.createdAt ?? '') ??
      DateTime(1970);
  return bUpdated.compareTo(aUpdated);
});
final visiblePets = sortedPets.take(10).toList();


   return SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPetPage()),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.07,
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.pets,
                    size: 25,
                    color: Colours.primarycolour,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: screenWidth * 0.22,
                  child: Center(
                    child: Text(
                      "Add Pet",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FontFamily.Cairo,
                        fontSize: screenWidth * 0.04,
                        color: Colours.brownColour,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      if (visiblePets.isNotEmpty)
        ...visiblePets.map((pet) {
          // ✅ Prepare image
          const String baseUrl = 'https://app.pawdli.com';
          String? petImage = pet.petProfileImage;
          ImageProvider imageProvider;

          if (petImage != null && petImage.isNotEmpty) {
            if (petImage.startsWith('http')) {
              imageProvider = CachedNetworkImageProvider(petImage);
            } else if (petImage.startsWith('/media')) {
              imageProvider = CachedNetworkImageProvider('$baseUrl$petImage');
            } else {
              imageProvider =
                  const AssetImage('assets/images/default_pet_avatar.png');
            }
          } else {
            imageProvider =
                const AssetImage('assets/images/default_pet_avatar.png');
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPetPage(PetId: pet.petId),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.08,
                    backgroundColor: Colours.secondarycolour,
                    backgroundImage: imageProvider,
                    child: petImage == null || petImage.isEmpty
                        ? const Icon(Icons.pets, color: Colors.white)
                        : null, // 🐾 Default paw icon if no image
                  ),
                ],
              ),
            ),
          );
        }),
    
          // ➕ Plus Icon (always shown)
          // const SizedBox(width: 5), // space between last avatar and plus
          
        ],
      ),
    );
  }),
),
  ],
),
       const SizedBox(width: 3),
       // 3️⃣ ➡ Dynamic Field: Button + Video Grid
    Padding(
      
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // Dynamic competition button
          CompetitionCountdownButton(),

          const SizedBox(height: 5),

          // Grid scroller for uploaded videos
 Obx(() {       
  final controller = Get.find<ReelsController>();

  if (controller.isLoading.value) {
    return const Center(child: CircularProgressIndicator());
  }

  if (controller.reels.isEmpty) {
    return const Text("Loading.......");
  }

  return SizedBox(
    height: 200, // Increased size so thumbnails are visible
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: controller.reels.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
       itemBuilder: (context, index) {
        final reel = controller.reels[index];

        return GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => ReelsPage(
                  reels: controller.reels,
                  startIndex: index,
                ),
              ),
            );

          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
  children: [
    // THUMBNAIL IMAGE
    CachedNetworkImage(
      imageUrl: reel.thumbnailUrl,
      width: 120,
      height: 200,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        width: 120,
        height: 200,
        color: Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        width: 120,
        height: 200,
        color: Colors.black26,
        child: const Icon(Icons.error, color: Colors.white),
      ),
    ),

    // 🔥 GRADIENT (for readability)
    Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black87,
              Colors.transparent,
            ],
          ),
        ),
      ),
    ),

  // 👤 USERNAME (SCROLLING) + ❤️ LIKES (STATIC)
Positioned(
  left: 6,
  right: 6,
  bottom: 6,
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // 🔄 USERNAME (SCROLLS ONLY)
      Expanded(
        child: MarqueeText(
          text: reel.username.isNotEmpty ? reel.username : "Unknown",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      const SizedBox(width: 6),

      // ❤️ LIKE COUNT (STATIC, NO SCROLL)
      if (reel.likesCount > 0)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 14,
            ),
            const SizedBox(width: 3),
            Text(
              reel.likesCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
    ],
  ),
),


  ],
),

          ),
        );
      },
    ),
  );
})

        ],
      ),
    ),

            // "Make a Buddy" Title and See All Button
    //         Padding(
    //           padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Text(
    //                 "Make a Buddy",
    //                 style: TextStyle(
    //                   color: Colours.black,
    //                   fontFamily: FontFamily.Cairo,
    //                   fontSize: screenWidth * 0.08,
    //                   fontWeight: FontWeight.w600,
    //                 ),
    //               ),
    //               TextButton(
    //                 onPressed: () {
    //                  Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (context) => SeeAllPage()));
    // print('Card tapped');
    //                 },
    //                 child: Text(
    //                   "See All",
    //                   style: TextStyle(
    //                     fontFamily: FontFamily.Cairo,
    //                     color: Colours.primarycolour,
    //                     fontSize: screenWidth * 0.05,
    //                     fontWeight: FontWeight.w600,
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
// Padding(
//   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.045), // Adjust for side padding
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Equal spacing between widgets
//     crossAxisAlignment: CrossAxisAlignment.center, // Vertically align widgets
//     children: [
//       // "All" Category
//       Flexible(
//         flex: 3,
//         child: Column(
//           children: [
//             Container(
//               width: screenWidth * 0.3, // Adjusted width
//               height: screenHeight * 0.2, // Adjusted height
//               child: GestureDetector(
//                 onTap: () {
//                 Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => SeeAllPage()));
//     print('Card tapped');
//                 },
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       top: screenHeight * 0.048,
//                       left: screenWidth * 0.001,
//                       child: Image.asset(
//                         Assets.images.homeallbg.path,
//                         width: screenWidth * 0.29,
//                         height: screenHeight * 0.14,
//                       ),
//                     ),
//                     Positioned(
//                       top: screenHeight * 0.03,
//                       left: screenWidth * 0.02,
//                       child: Image.asset(
//                         Assets.images.homeapagebg.path,
//                         width: screenWidth * 0.26,
//                         height: screenHeight * 0.08,
//                       ),
//                     ),
//                     Positioned(
//                       top: screenHeight * -0.045,
//                       left: screenWidth * -0.08,
//                       child: Image.asset(
//                         Assets.images.allimage.path,
//                         width: screenWidth * 0.45,
//                         height: screenHeight * 0.20,
//                       ),
//                     ),
             
//                     Positioned(
//                       top: screenHeight * 0.12,
//                       left: screenWidth * 0.10,
//                       child: Text(
//                         "All",
//                         style: TextStyle(
//                           color: Colours.secondarycolour,
//                           fontFamily: FontFamily.Cairo,
//                           fontSize: screenWidth * 0.07,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       // "Cats" Category
//     //   Flexible(
//     //     flex: 3,
//     //     child: Column(
//     //       children: [
//     //          GestureDetector(
//     //     onTap: () {
//     // Navigator.push(
//     //  context,
//     //    MaterialPageRoute(builder: (context) => SubcategariesPage(categoryId: 2)),
//     //    );
//     //   },
//     //     child: Container(
//     //           width: screenWidth * 0.25, // Adjusted width
//     //           height: screenHeight * 0.2, // Adjusted height
//     //           child: Stack(
//     //             children: [
//     //               Positioned(
//     //                 top: screenHeight * 0.007,
//     //                 left: screenWidth * 0.003,
//     //                 child: Image.asset(
//     //                   Assets.images.homeapagebg.path,
//     //                   width: screenWidth * 0.24,
//     //                   height: screenHeight * 0.13,
//     //                 ),
//     //               ),
//     //               Positioned(
//     //                 bottom: screenHeight * 0.074,
//     //                 left: screenWidth * 0.002,
//     //                 child: Image.asset(
//     //                   Assets.images.cathome.path,
//     //                   width: screenWidth * 0.28,
//     //                   height: screenHeight * 0.14,
//     //                 ),
//     //               ),
//     //                 Positioned(
//     //                   top: screenHeight * 0.12,
//     //                   left: screenWidth * 0.05,
//     //                   child: Text(
//     //                     "Cats",
//     //                     style: TextStyle(
//     //                       color: Colours.brownColour,
//     //                       fontFamily: FontFamily.Cairo,
//     //                       fontSize: screenWidth * 0.07,
//     //                       fontWeight: FontWeight.w700,
//     //                     ),
//     //                   ),
//     //                 ),
//     //             ],
//     //           ),
//     //         ),
            
//     //     )],
//     //     ),
//     //   ),
//     //   // "Dogs" Category
//     //   Flexible(
//     //     flex: 3,
//     //     child: Column(
//     //       children: [
//     //          GestureDetector(
//     //     onTap: () {
//     //       Navigator.push(
//     //                         context,
//     //                         MaterialPageRoute(builder: (context) => SubcategariesPage(categoryId: 1)),
//     //                       );
//     // print('Card tapped');
//     //     },
//     //     child:     Container(
//     //           width: screenWidth * 0.25, 
//     //           height: screenHeight * 0.2,
//     //           child: Stack(
//     //             children: [
//     //               Positioned(
//     //                top: screenHeight * 0.007,
//     //                 left: screenWidth * 0.02,
//     //                 child: Image.asset(
//     //                   Assets.images.homeapagebg.path,
//     //                  width: screenWidth * 0.23,
//     //                   height: screenHeight * 0.13,
//     //                 ),
//     //               ),
//     //               Positioned(
//     //                 bottom: screenHeight * 0.071,
//     //                 right: screenWidth * -0.010,
//     //                 child: Image.asset(
//     //                   Assets.images.doghome.path,
//     //                   width: screenWidth * 0.25,
//     //                   height: screenHeight * 0.14,
//     //                 ),
//     //               ),
//     //               Positioned(
//     //                   top: screenHeight * 0.12,
//     //                   left: screenWidth * 0.05,
//     //                   child: Text(
//     //                     "Dogs",
//     //                     style: TextStyle(
//     //                       color: Colours.brownColour,
//     //                       fontFamily: FontFamily.Cairo,
//     //                       fontSize: screenWidth * 0.07,
//     //                       fontWeight: FontWeight.w700,
//     //                     ),
//     //                   ),
//     //                 ),
//     //             ],
//     //           ),
//     //         ),
           
//     //      ) ],
//     //     ),
//     //   ),
//     ],
//   ),
// ),

          
            // Section: Our Services
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
                  // Text(
                  //   "Our Services",
                  //   style: TextStyle(
                  //     color: Colours.black,
                  //     fontFamily: FontFamily.Cairo,
                  //     fontSize: screenWidth * 0.08,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                  // TextButton(
                  //   onPressed: () {
             
                  //   },
                  //   child: Text(
                  //     "See All",
                  //     style: TextStyle(
                  //       fontFamily: FontFamily.Cairo,
                  //       color: Colours.primarycolour,
                  //       fontSize: screenWidth * 0.05,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  // ),
            //     ],
            //   ),
            // ),




          Padding(
  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.001, vertical: screenHeight * 0.01),
  child: GestureDetector(
                       onTap: () {
  // Navigate first
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Petradio()),
  ).then((_) {
    // Use addPostFrameCallback to perform actions after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Here you can perform updates like calling setState or modifying observables
      print('Card tapped');
    });
  });
},

    child: Stack(
      children: [
        // Background image
        Container(
          width: screenWidth * 1, // Adjust the width to fit the screen
          height: screenHeight * 0.2, // Adjust the height to fit the design
          child: Image.asset(
                        Assets.images.yellowcard.path,
                       width: screenWidth * 0.1,
                        height: screenHeight * 0.12
                      ),
        ),
    
        // Text content on the left
        Positioned(
          left: screenWidth * 0.05, // Adjust the horizontal position
          top: screenHeight * 0.02, // Adjust the vertical position
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pet Radio",
                style: TextStyle(
                  color: Colours.black, // Use a contrasting color for visibility
                  fontFamily: FontFamily.Cairo,
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Exclusive radio for the \nPets join and enjoy.",
                style: TextStyle(
                  color: Colours.black, // Slightly transparent white
                  fontFamily: FontFamily.Cairo,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
    
        // Cat image in position
Positioned(
  right: screenWidth * -0.04, // Adjust horizontal position
  bottom: screenHeight * -0.0001, // Adjust vertical position
  child: Image.asset(
    'assets/images/PetRadio.png', // Updated image path
    width: screenWidth * 0.50,    // Adjust width
    height: screenHeight * 0.25,  // Adjust height
    fit: BoxFit.contain,          // Ensures the image fits properly
  ),
),

      ],
    ),
  ),
),



 Padding(
  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.001, vertical: screenHeight * 0.01),
  child: GestureDetector(
                       onTap: () {
  // Navigate first
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PetstorePage()),
  ).then((_) {
    // Use addPostFrameCallback to perform actions after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Here you can perform updates like calling setState or modifying observables
      print('Card tapped');
    });
  });
},

    child: Stack(
      children: [
        // Background image
        Container(
          width: screenWidth * 1, // Adjust the width to fit the screen
          height: screenHeight * 0.2, // Adjust the height to fit the design
          child: Image.asset(
                        Assets.images.browncard.path,
                       width: screenWidth * 0.1,
                        height: screenHeight * 0.12
                      ),
        ),
    
        // Text content on the left
        // Positioned(
        //   left: screenWidth * 0.05, // Adjust the horizontal position
        //   top: screenHeight * 0.02, // Adjust the vertical position
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         "Make a Friend",
        //         style: TextStyle(
        //           color: Colours.black, // Use a contrasting color for visibility
        //           fontFamily: FontFamily.Cairo,
        //           fontSize: screenWidth * 0.08,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //       const SizedBox(height: 8),
        //       Text(
        //         "Paws & forever friends \nMeet new and enjoy.",
        //         style: TextStyle(
        //           color: Colours.black, // Slightly transparent white
        //           fontFamily: FontFamily.Cairo,
        //           fontSize: screenWidth * 0.06,
        //           fontWeight: FontWeight.w400,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
    
Positioned(
  right: screenWidth * 0.06, // Adjust horizontal position
  bottom: screenHeight * 0.03, // Adjust vertical position
  child: Image.asset(
    'assets/images/petstore_icon.png', // Updated image path
         width: screenWidth * 0.9,
        height: screenHeight * 0.16,  // Adjust height
    fit: BoxFit.cover,          // Ensures the image fits properly
  ),
),

      ],
    ),
  ),
),
// GestureDetector(
//   onTap: () async {
//       Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => PetstorePage()),
//               );

//   },
//   child: Padding(
//     padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
//     child: Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Container(
//         width: screenWidth * 0.9,
//         height: screenHeight * 0.16,
//         padding: EdgeInsets.all(screenWidth * 0.05),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//             image: DecorationImage(
//             image: AssetImage("assets/images/petstore_icon.png"),
//             fit: BoxFit.cover,
//           ),

//           // color: Colours.brownColour.withOpacity(0.3),
//         ),
//         )
//       ),
//     ),
//   ),

    Padding(
  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.001, vertical: screenHeight * 0.01),
  child: GestureDetector(
                       onTap: () {
  // Navigate first
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PetTherapy()),
  ).then((_) {
    // Use addPostFrameCallback to perform actions after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Here you can perform updates like calling setState or modifying observables
      print('Card tapped');
    });
  });
},
  child: Stack(
    children: [
      // Background image
     Container(
        width: screenWidth * 1, // Adjust the width to fit the screen
        height: screenHeight * 0.2, // Adjust the height to fit the design
        child: Image.asset(
                      Assets.images.yellowcard.path,
                     width: screenWidth * 0.05,
                      height: screenHeight * 0.12
                    ),
      ),

      // Text content on the left
      Positioned(
        left: screenWidth * 0.05, // Adjust the horizontal position
        top: screenHeight * 0.02, // Adjust the vertical position
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pet Therapy",
              style: TextStyle(
                color: Colours.black, // Use a contrasting color for visibility
                fontFamily: FontFamily.Cairo,
                fontSize: screenWidth * 0.08,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Therapy with pets for a \ncalmer and happier you",
              style: TextStyle(
                color: Colours.black, // Slightly transparent white
                fontFamily: FontFamily.Cairo,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),

      // Cat image in position
      Positioned(
        right: screenWidth * -0.05, // Adjust the horizontal position
        bottom: screenHeight * -0.050, // Adjust the vertical position
        child: Image.asset(
               'assets/images/PetTherapy.png',
       width: screenWidth * 0.55, // Adjust width
          height: screenHeight * 0.30, // Adjust height
          fit: BoxFit.fill, // Ensures the image fits properly
        ),
      ),
    ],
  ),
)),


            Padding(
  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.001, vertical: screenHeight * 0.01),
  child: GestureDetector(
                       onTap: () {
  // Navigate first
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SeeAllPage()),
  ).then((_) {
    // Use addPostFrameCallback to perform actions after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Here you can perform updates like calling setState or modifying observables
      print('Card tapped');
    });
  });
},

    child: Stack(
      children: [
        // Background image
        Container(
          width: screenWidth * 1, // Adjust the width to fit the screen
          height: screenHeight * 0.2, // Adjust the height to fit the design
          child: Image.asset(
                        Assets.images.browncard.path,
                       width: screenWidth * 0.1,
                        height: screenHeight * 0.12
                      ),
        ),
    
        // Text content on the left
        Positioned(
          left: screenWidth * 0.05, // Adjust the horizontal position
          top: screenHeight * 0.02, // Adjust the vertical position
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Make a Friend",
                style: TextStyle(
                  color: Colours.secondarycolour, // Use a contrasting color for visibility
                  fontFamily: FontFamily.Cairo,
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Paws & forever friends \nMeet new and enjoy.",
                style: TextStyle(
                  color: Colours.secondarycolour, // Slightly transparent white
                  fontFamily: FontFamily.Cairo,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
    
Positioned(
  right: screenWidth * -0.07, // Adjust horizontal position
  bottom: screenHeight * -0.04, // Adjust vertical position
  child: Image.asset(
    'assets/images/allanimals.png', // Updated image path
    width: screenWidth * 0.60,    // Adjust width
    height: screenHeight * 0.30,  // Adjust height
    fit: BoxFit.scaleDown,          // Ensures the image fits properly
  ),
),

      ],
    ),
  ),
),

Padding(
  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.001, vertical: screenHeight * 0.01),
  child: GestureDetector(
                       onTap: () {
  // Navigate first
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PodcastScreen()),
  ).then((_) {
    // Use addPostFrameCallback to perform actions after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Here you can perform updates like calling setState or modifying observables
      print('Card tapped');
    });
  });
},
  child: Stack(
    children: [
      // Background image
      Container(
        width: screenWidth * 1, // Adjust the width to fit the screen
        height: screenHeight * 0.2, // Adjust the height to fit the design
        child: Image.asset(
                      Assets.images.yellowcard.path,
                     width: screenWidth * 0.1,
                      height: screenHeight * 0.12
                    ),
      ),

      // Text content on the left
      Positioned(
        left: screenWidth * 0.05, // Adjust the horizontal position
        top: screenHeight * 0.02, // Adjust the vertical position
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pet Podcast",
              style: TextStyle(
                color: Colours.black, // Use a contrasting color for visibility
                fontFamily: FontFamily.Cairo,
                fontSize: screenWidth * 0.08,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Listen and our series \n of podcasts and enjoy",
              style: TextStyle(
                color: Colours.black, // Slightly transparent white
                fontFamily: FontFamily.Cairo,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),

      // Cat image in position
      Positioned(
        right: screenWidth * -0.10, // Adjust the horizontal position
        bottom: screenHeight * -0.012, // Adjust the vertical position
        child: Image.asset(
             'assets/images/Pet_Podcast1.png',
        
       width: screenWidth * 0.55, // Adjust width
          height: screenHeight * 0.28, // Adjust height
          fit: BoxFit.fill, 
        ),
      ),
    ],
  ),
)),
 Padding(
  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.001, vertical: screenHeight * 0.01),
  child: GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Coming Soon"),
            content: Text("This feature will be available soon!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    },

    child: Stack(
      children: [
        // Background image
        Container(
          width: screenWidth * 1, // Adjust the width to fit the screen
          height: screenHeight * 0.2, // Adjust the height to fit the design
          child: Image.asset(
                        Assets.images.browncard.path,
                       width: screenWidth * 0.1,
                        height: screenHeight * 0.12
                      ),
        ),
    
        // Text content on the left
        Positioned(
          left: screenWidth * 0.05, // Adjust the horizontal position
          top: screenHeight * 0.02, // Adjust the vertical position
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                     "Meet A Vet",
                style: TextStyle(
                  color: Colours.secondarycolour, // Use a contrasting color for visibility
                  fontFamily: FontFamily.Cairo,
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
            Text(
              "Connect a Vet in 5 minutes -\n ",
              style: TextStyle(
                color: Colours.secondarycolour, // Slightly transparent white
                fontFamily: FontFamily.Cairo,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w400,
              ),
            ),
            ],
          ),
        ),
    
        // Cat image in position
        Positioned(
           right: screenWidth * -0.06, // Adjust the horizontal position
          bottom: screenHeight * -0.03, /// Adjust the vertical position
          child: Image.asset(
                  'assets/images/MeetAVet .png',
            width: screenWidth * 0.58, // Adjust width
            height: screenHeight * 0.28, // Adjust height
            fit: BoxFit.contain, // Ensures the image fits properly
          ),
        ),
      ],
    ),
  ),
),
   
        

Padding(
  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.010), // Adjust for side padding
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround, // Equal spacing between widgets
    crossAxisAlignment: CrossAxisAlignment.start, // Vertically align widgets
    children: [
      // "All" Category
      Flexible(
        flex: 1,
        child: Column(
          children: [
            Container(
              width: screenWidth * 0.3, // Adjusted width
              height: screenHeight * 0.2, // Adjusted height
              child: GestureDetector(
                onTap: () {
                   Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AdoptionViewList()),
  ).then((_) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Card tapped');
    });
  });
                },
                child: Stack(
                  children: [
                    Positioned(
                      top: screenHeight * 0.048,
                      left: screenWidth * 0.001,
                      child: Image.asset(
                        Assets.images.homeallbg.path,
                        width: screenWidth * 0.29,
                        height: screenHeight * 0.14,
                      ),
                    ),
                    Positioned(
                     top: screenHeight * -0.01,
                      left: screenWidth * -0.04,
                      child: Image.asset(
                              'assets/images/Pet_Adoption1.png',
                             width: screenWidth * 0.38,
                        height: screenHeight * 0.18,
                      ),
                    ),
                   
             
                    Positioned(
                      top: screenHeight * 0.13,
                      left: screenWidth * 0.05,
                      child: Text(
                        "Adoption",
                        style: TextStyle(
                          color: Colours.secondarycolour,
                          fontFamily: FontFamily.Cairo,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
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
        
      // "Cats" Category
    Flexible(
  flex: 1,
  child: Column(
    children: [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Goodbyebudddy(), 
            ),
          );
        },
        child: Container(
          width: screenWidth * 0.6,
          height: screenHeight * 0.21,
          child: Stack(
            children: [
              // Positioned(
              //   top: screenHeight * 0.01,
              //   left: screenWidth * 0.001,
              //   child: Image.asset(
              //     Assets.images.homeapagebg.path,
              //     width: screenWidth * 0.4,
              //     height: screenHeight * 0.14,
              //   ),
              // ),
              Positioned(
                bottom: screenHeight * 0.060,
                right: screenWidth * 0.09,
                child: Image.asset(
                  'assets/images/Goodbye_Buddy.png',

                  width: screenWidth * 0.40,
                  height: screenHeight * 0.15,
                ),
              ),
              Positioned(
                top: screenHeight * 0.14,
                left: screenWidth * 0.04,
                child: Text(
                  "Good bye Buddy",
                  style: TextStyle(
                    color: Colours.brownColour,
                    fontFamily: FontFamily.Cairo,
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.w600,
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


      
    ],
  ),
),

          
          




          SizedBox(height: screenHeight*0.1,)
          ],
          
        ),
      ),
      
     
    );
  }

}