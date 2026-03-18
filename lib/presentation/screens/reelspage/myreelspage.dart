import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/myreelscontroller.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/reelspage/reels.dart';
import 'package:pawlli/presentation/screens/reelspage/savereel.dart';

class MyReelsPage extends StatelessWidget {
  MyReelsPage({super.key});

  // ❗ Do NOT create a new controller here
  final MyReelsController controller = Get.find<MyReelsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(80),
  child: Stack(
    children: [
      AppBar(
        centerTitle: true,
        title: const Text("My Videos"),
        backgroundColor: Colors.white,
      ),

      // ---------------- TOP IMAGE POSITIONED ----------------
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.55,
          height: MediaQuery.of(context).size.height * 0.10,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.images.topimage.path),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ],
  ),
),
      body: Obx(() {
        print("📌 UI Rebuild — Reels Count: ${controller.myReels.length}");

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (controller.myReels.isEmpty) {
          return const Center(
            child: Text("No reels found", style: TextStyle(color: Colors.white70)),
          );
        }

       return GridView.builder(
  padding: const EdgeInsets.all(6),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,         // 2 per row
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 0.65,    // Taller TikTok style
  ),
  itemCount: controller.myReels.length,
  itemBuilder: (_, i) {
    final reel = controller.myReels[i];

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => ReelsPage(
              reels: controller.myReels,
              startIndex: i,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // ---------------------- THUMBNAIL ----------------------
            Positioned.fill(
              child: FadeInImage.assetNetwork(
                placeholder: "assets/images/profile_avatar.png", // Add a placeholder image
                image: reel.thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),

            // ---------------------- GRADIENT OVERLAY ----------------------
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ---------------------- MORE OPTIONS (⋮) ----------------------
Positioned(
  top: 6,
  left: 6,
  child: PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert, color: Colors.white),
    onSelected: (value) async {
      if (value == 'delete') {
        Get.defaultDialog(
          title: "Delete Video",
          middleText: "Are you sure you want to delete this video permanently?",
          textConfirm: "Delete",
          textCancel: "Cancel",
          confirmTextColor: Colors.white,
          onConfirm: () {
            controller.deleteReel(reel.id);
            Get.back();
          },
        );
      }
    },
    itemBuilder: (_) => [
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text("Delete"),
          ],
        ),
      ),
    ],
  ),
),

// ---------------------- DESCRIPTION (SINGLE LINE) ----------------------
if (reel.caption.isNotEmpty)
  Positioned(
    bottom: 30, // 👈 ABOVE like & play icons
    left: 8,
    right: 8,
    child: Text(
      reel.caption,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        shadows: [
          Shadow(
            blurRadius: 6,
            color: Colors.black,
            offset: Offset(0, 1),
          ),
        ],
      ),
    ),
  ),



            // ---------------------- PLAY ICON ----------------------
            // const Positioned(
            //   bottom: 8,
            //   right: 8,
            //   child: Icon(
            //     Icons.play_circle_fill,
            //     size: 26,
            //     color: Colors.white,
            //   ),
            // ),

                        // ---------------------- DURATION BADGE ----------------------
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatDuration(reel.duration),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),

            // ---------------------- LIKES COUNT ----------------------
            if (reel.likesCount > 0)
              Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      reel.likesCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  },
);



      }),
    );
  }
}

/// ⭐ ADD THIS OUTSIDE THE CLASS
String _formatDuration(double seconds) {
  final int s = seconds.toInt();
  final int min = s ~/ 60;
  final int sec = s % 60;
  return "$min:${sec.toString().padLeft(2, '0')}";
}
