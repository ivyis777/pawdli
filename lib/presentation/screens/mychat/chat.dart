import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/petslistcontroller.dart';
import 'package:pawlli/data/controller/recentchatcontroller.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/chat1to1/chatui.dart';
import 'package:get/get.dart';
class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final Petslistcontroller petsController = Get.put(Petslistcontroller());
  final recentChatController = Get.put(RecentPetChatController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Chats',
          style: TextStyle(
            color: Colours.seachbarcolour,
            fontFamily: FontFamily.Cairo,
            fontWeight: FontWeight.w700,
            fontSize: screenWidth * 0.06,
          ),
        ),
        backgroundColor: Colours.primarycolour,
        foregroundColor: Colours.seachbarcolour,
        centerTitle: true,
      ),
      backgroundColor: Colours.primarycolour,
      body: Column(
        children: [
          // 🧹 Removed ToggleSwitch here

          // Main content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36.0),
                  topRight: Radius.circular(36.0),
                ),
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
                child: SingleChildScrollView(
                  child: _MyChatsSection(), // ✅ Only show the chat section
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _MyChatsSection extends StatefulWidget {
  @override
  State<_MyChatsSection> createState() => _MyChatsSectionState();
}
class _MyChatsSectionState extends State<_MyChatsSection> {
  final Petslistcontroller petsController = Get.find<Petslistcontroller>();
  final RecentPetChatController recentChatController = Get.find<RecentPetChatController>();



@override
void initState() {
  super.initState();
  final box = GetStorage();
  final userId = box.read(LocalStorageConstants.userId);
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await petsController.loadUserPets(userId);

    if (petsController.userPets.isNotEmpty) {
      final firstPetId = petsController.userPets.first.petId.toString();

      recentChatController.setSelectedPet(firstPetId);

      // Manually trigger fetch once for initial pet
      await recentChatController.fetchRecentChatsForPet(firstPetId);
    }
  });

  // Listen for pet changes and update recent chat automatically
  ever<String>(recentChatController.selectedPetId, (petId) {
    if (petId.isNotEmpty) {
      recentChatController.fetchRecentChatsForPet(petId);
    }
  });
}



  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          'Switch Pet',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: Colours.brownColour,
            fontFamily: FontFamily.Cairo,
          ),
        ),
      ),
      Obx(() {
        if (petsController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (petsController.errorMessage.isNotEmpty) {
          return Center(child: Text(petsController.errorMessage.value));
        }

        if (petsController.userPets.isEmpty) {
          return Center(child: Text("No pets found."));
        }

       

     return Obx(() {
  if (petsController.userPets.isEmpty) {
    return Center(
      child: Text(
        "No pets available",
        style: TextStyle(
          fontSize: 18,
          color: Colours.brownColour,
        ),
      ),
    );
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: petsController.userPets.map((pet) {
        final isSelected = recentChatController.selectedPetId.value == pet.petId.toString();
      
        String? petImagePath = pet.petProfileImage;
        String fullPetImage = (petImagePath != null && petImagePath.isNotEmpty) 
            ? '$petImagePath' 
            : '';

        return GestureDetector(
         onTap: () {

  final selectedPetId = pet.petId.toString();
  recentChatController.setSelectedPet(selectedPetId);
  recentChatController.fetchRecentChatsForPet(selectedPetId);


},
child: Container(
  width: MediaQuery.of(context).size.width / 3,
  margin: const EdgeInsets.symmetric(horizontal: 8.0),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16.0),
    border: isSelected 
        ? Border.all(color: Colours.brownColour, width: 3) 
        : null,
    color: Colors.white,
  ),
  child: Stack(
    alignment: Alignment.center,
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
        Center(
  child: CircleAvatar(
  radius: 50,
  backgroundColor: Colours.primarycolour.withOpacity(0.2),
  backgroundImage: fullPetImage.isNotEmpty
      ? CachedNetworkImageProvider(fullPetImage)
      : null,
  child: fullPetImage.isEmpty
      ? Icon(Icons.pets, size: 30, color: Colours.brownColour)
      : null,
),
        ),


          SizedBox(height: screenHeight * 0.010),
          Text(
            pet.name ?? 'Unknown Pet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.brown : Colours.brownColour,
              fontFamily: FontFamily.Cairo,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ],
  ),
)

        );
      }).toList(),
    ),
  );
});
      }),
        SizedBox(height: screenHeight * 0.015),
 Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text(
          'Recent Chat',
           style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colours.brownColour,
            fontFamily: FontFamily.Cairo,
          ),
        ),
      ),
      SizedBox(height: screenHeight * 0.015),
    Obx(() {
      if (recentChatController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (recentChatController.errorMessage.isNotEmpty) {
        return Center(child: Text(recentChatController.errorMessage.value));
      }

      if (recentChatController.recentChats.isEmpty) {
        return const Center(child: Text("No recent chats available."));
      }


 return ListView.separated(
  physics: const NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  itemCount: recentChatController.recentChats.length,
  separatorBuilder: (_, __) => const SizedBox(height: 8),
  itemBuilder: (context, index) {
  final chat = recentChatController.recentChats[index];
  final petName = chat.withPet?.name ?? "Unknown";
  final petImagePath = chat.withPet?.petProfileImage;


  final String? fullPetImage = (petImagePath != null && petImagePath.isNotEmpty)
      ? '$petImagePath'
      : null;

  final backgroundAsset = (index % 2 == 0)
      ? Assets.images.chatbrowcard.path
      : Assets.images.chatyellowcard.path;

return GestureDetector(
  onTap: () {
    if (recentChatController.selectedPetId.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a pet to chat with')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat1to1(
          receiverId: chat.withPet?.petId.toString() ?? "",
          receiverName: chat.withPet?.name ?? "Unknown",
          petProfileImage: chat.withPet?.petProfileImage ?? "",
          petId: int.parse(recentChatController.selectedPetId.value),
        ),
      ),
    );
  },

    child: Container(
      height: 95,
      width: double.infinity,
      child: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              backgroundAsset,
              fit: BoxFit.fill,
            ),
          ),

          // Pet image (only if exists)
if (fullPetImage != null)
  Positioned(
    bottom: 10,
    left: 20,
    child: CircleAvatar(
  radius: 40,
  backgroundColor: Colours.brownColour.withOpacity(0.2),
  backgroundImage: CachedNetworkImageProvider(fullPetImage),
  onBackgroundImageError: (_, __) {},
),
  ),


          // Pet name
          Positioned(
            bottom: -10,
            left: 20,
            right: 20,
            height: 120,
            child: Center(
              child: Text(
                petName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colours.secondarycolour,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

);

    }),

  
  ],
)]);
}}

