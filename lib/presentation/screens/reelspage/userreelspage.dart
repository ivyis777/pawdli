import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/data/model/reelitemmodel.dart';
import 'package:pawlli/presentation/screens/reelspage/reels.dart';
import 'package:pawlli/presentation/screens/reelspage/savereel.dart';

class UserReelsPage extends StatefulWidget {
  final String username;

  const UserReelsPage({super.key, required this.username});

  @override
  State<UserReelsPage> createState() => _UserReelsPageState();
}

class _UserReelsPageState extends State<UserReelsPage> {
  bool isLoading = true;
  List<ReelItem> reels = [];

String formatDuration(double seconds) {
  final d = Duration(seconds: seconds.round());
  final minutes = d.inMinutes;
  final secs = d.inSeconds % 60;
  return "$minutes:${secs.toString().padLeft(2, '0')}";
}

  @override
  void initState() {
    super.initState();
    fetchUserReels();
  }

  Future<void> fetchUserReels() async {
    try {
      final token = GetStorage().read("access") ?? "";

      final url =
          "https://app.pawdli.com/user/short_video/search?username=${widget.username}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        setState(() {
          reels = data.map((e) => ReelItem.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    } catch (e) {
      debugPrint("USER REELS ERROR: $e");
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ APP BAR WITH USERNAME
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [
            AppBar(
              centerTitle: true,
              title: Text(widget.username),
              backgroundColor: Colors.white,
            ),
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

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reels.isEmpty
              ? const Center(child: Text("No reels found"))
              : GridView.builder(
                  padding: const EdgeInsets.all(6),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: reels.length,
                  itemBuilder: (_, i) {
                    final reel = reels[i];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReelsPage(
                              reels: reels,
                              startIndex: i,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
  children: [
    // THUMBNAIL
    Positioned.fill(
      child: FadeInImage.assetNetwork(
        placeholder: "assets/images/profile_avatar.png",
        image: reel.thumbnailUrl,
        fit: BoxFit.cover,
      ),
    ),

    // GRADIENT
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

  // ⏱ DURATION (BOTTOM RIGHT)
Positioned(
  bottom: 8,
  right: 8,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      formatDuration(reel.duration),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),


    // 💾 SAVE OPTION (TOP RIGHT)
    Positioned(
      top: 6,
      right: 6,
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onSelected: (value) async {
          if (value == 'save') {
            await ReelSaveHelper.save(context, reel.videoUrl);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 'save',
            child: Row(
              children: [
                Icon(Icons.download, size: 18),
                SizedBox(width: 8),
                Text("Save"),
              ],
            ),
          ),
        ],
      ),
    ),
// ---------------------- DESCRIPTION (SINGLE LINE) ----------------------
if (reel.caption.isNotEmpty)
  Positioned(
    bottom: 36, // 👈 ABOVE like & play icons
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

    // ❤️ LIKE COUNT (BOTTOM LEFT)
    if (reel.likesCount > 0)
      Positioned(
        bottom: 8,
        left: 8,
        child: Row(
          children: [
            const Icon(Icons.favorite,
                color: Colors.red, size: 18),
            const SizedBox(width: 4),
            Text(
              reel.likesCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
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
  }
}
