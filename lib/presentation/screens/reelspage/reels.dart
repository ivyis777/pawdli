

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/presentation/screens/reelspage/createreelscamera.dart';
import 'package:pawlli/presentation/screens/reelspage/myreelspage.dart';
import 'package:pawlli/presentation/screens/reelspage/uploadreel.dart';
import 'package:pawlli/presentation/screens/reelspage/userreelspage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:pawlli/data/model/reelitemmodel.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';


// ---------------------------------------------------------------------------
//                              REELS PAGE
// ---------------------------------------------------------------------------

class ReelsPage extends StatefulWidget {
  final List<ReelItem> reels;
  final int startIndex;

  const ReelsPage({
    super.key,
    required this.reels,
    required this.startIndex,
  });

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late PageController pageController;
  int currentPage = 0;

  bool showSearchBar = false;
  String searchQuery = "";
  List<ReelItem> filteredReels = [];

  List<GlobalKey<_ReelPlayerState>> pageKeys = [];
  

  @override
  void initState() {
    super.initState();

    currentPage = widget.startIndex;
    filteredReels = widget.reels;

    pageController = PageController(initialPage: widget.startIndex);

    pageKeys =
        List.generate(widget.reels.length, (_) => GlobalKey<_ReelPlayerState>());
  }

  void regenerateKeysFor(List<ReelItem> list) {
    pageKeys = List.generate(list.length, (_) => GlobalKey<_ReelPlayerState>());
  }

  void pauseCurrentReel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (currentPage < pageKeys.length) {
        pageKeys[currentPage].currentState?.pauseVideo();
      }
    });
  }


  void _searchReels(String query) async {
  pauseCurrentReel();
  searchQuery = query;

  if (query.isEmpty) {
    setState(() {
      filteredReels = widget.reels;
      currentPage = 0;
      pageController.jumpToPage(0);
      regenerateKeysFor(filteredReels);
    });
    return;
  }

  try {
    final token = GetStorage().read("access") ?? "";
    final url =
        "https://app.pawdli.com/user/short_video/search?username=$query";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // API expects list of objects converted to ReelItem
      List<ReelItem> results = (data as List)
          .map((json) => ReelItem.fromJson(json))
          .toList();

      setState(() {
        filteredReels = results;
        currentPage = 0;
        pageController.jumpToPage(0);
        regenerateKeysFor(filteredReels);
      });
    } else {
      print("SEARCH FAILED ${response.body}");
    }
  } catch (e) {
    print("SEARCH ERROR $e");
  }
}


Future<void> _onHorizontalSwipe(DragEndDetails details) async {
  pauseCurrentReel();

  if (details.primaryVelocity == null) return;

  // ⬅️ Swipe LEFT only
  if (details.primaryVelocity! < -300) {
 pauseCurrentReel();

await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => MyReelsPage()),
);

// when coming back
pauseCurrentReel();

  }
}
void _showAddReelOptions() {
  pauseCurrentReel();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (bottomSheetContext) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // 📁 Upload Reel
            ListTile(
              leading:
                  const Icon(Icons.video_library, color: Colors.white),
              title: const Text(
                "Upload Reel",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () async {
                Navigator.pop(bottomSheetContext);

                final picker = ImagePicker();
                final pickedFile =
                    await picker.pickVideo(source: ImageSource.gallery);

                if (!mounted || pickedFile == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddDetailsPage(videoFile: File(pickedFile.path)),
                  ),
                );
              },
            ),

            const Divider(color: Colors.white24),

            // 📷 Open Camera
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.white),
              title: const Text(
                "Open Camera",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () async {
                Navigator.pop(bottomSheetContext);

                if (!mounted) return;

                final recordedVideo = await Navigator.push<File>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateReelCameraPage(),
                  ),
                );

                if (!mounted || recordedVideo == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddDetailsPage(videoFile: recordedVideo),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}


@override
void deactivate() {
  pauseCurrentReel();
  super.deactivate();
}



  @override
  Widget build(BuildContext context) {
    final reelsToShow = showSearchBar ? filteredReels : widget.reels;

    if (pageKeys.length != reelsToShow.length) {
      regenerateKeysFor(reelsToShow);
    }

    
      return Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,

        appBar: showSearchBar
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: TextField(
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: _searchReels,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      pauseCurrentReel();
                      setState(() {
                        showSearchBar = false;
                        searchQuery = "";
                        filteredReels = widget.reels;

                        currentPage = 0;
                        pageController.jumpToPage(0);

                        regenerateKeysFor(widget.reels);
                      });
                    },
                  )
                ],
              )
            : null,

        body: Stack(
          children: [
            GestureDetector(
  onHorizontalDragEnd: _onHorizontalSwipe, // 👈 ADD THIS
  child: PageView.builder(
    controller: pageController,
    scrollDirection: Axis.vertical,
    itemCount: reelsToShow.length,
    onPageChanged: (i) {
      pauseCurrentReel();
      setState(() => currentPage = i);
    },
    itemBuilder: (context, index) {
      return ReelPlayer(
        key: pageKeys[index],
        reel: reelsToShow[index],
        isActive: index == currentPage,
        onPause: pauseCurrentReel,
        onUserTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserReelsPage(
                username: reelsToShow[index].username,
              ),
            ),
          );
        },
      );
    },
  ),
),


              // 🔙 BACK BUTTON
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                child: GestureDetector(
                  onTap: () {
                    pauseCurrentReel();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

            // Bottom Controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 75,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {
                        pauseCurrentReel();
                        setState(() => showSearchBar = true);
                      },
                      icon: Icon(Icons.search,
                          color: Colours.primarycolour, size: 32),
                    ),

                    GestureDetector(
                      onTap: _showAddReelOptions, // 👈 POPUP HERE
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colours.primarycolour,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        pauseCurrentReel();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MyReelsPage()),
                        );
                      },
                      icon: Icon(Icons.video_library,
                          color: Colours.primarycolour, size: 32),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    
  }
}

// ---------------------------------------------------------------------------
//                            REEL PLAYER (FINAL)
// ---------------------------------------------------------------------------

class ReelPlayer extends StatefulWidget {
  final ReelItem reel;
  final bool isActive;
  final Function()? onPause;
  final VoidCallback? onUserTap;


  const ReelPlayer({
    super.key,
    required this.reel,
    required this.isActive,
    this.onPause,
    this.onUserTap,
  });

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> {
  late VideoPlayerController _video;
  bool isMuted = false;
  bool showHeart = false;
  bool isLongPressing = false;
  bool isCaptionExpanded = false;
  bool isCaptionOverflowing = false;

// bool _doesTextOverflow(String text, TextStyle style, double maxWidth) {
//   final textPainter = TextPainter(
//     text: TextSpan(text: text, style: style),
//     maxLines: 1,
//     textDirection: TextDirection.ltr,
//   )..layout(maxWidth: maxWidth);

//   return textPainter.didExceedMaxLines;
// }

// String _buildCollapsedCaption(
//   String text,
//   TextStyle style,
//   double maxWidth,
// ) {
//   final painter = TextPainter(
//     textDirection: TextDirection.ltr,
//     maxLines: 1,
//   );

//   String truncated = text;

//   while (truncated.isNotEmpty) {
//     painter.text = TextSpan(
//       text: "$truncated… more",
//       style: style,
//     );
//     painter.layout(maxWidth: maxWidth);

//     if (!painter.didExceedMaxLines) {
//       return "$truncated… more";
//     }

//     truncated = truncated.substring(0, truncated.length - 1);
//   }

//   return text;
// }

  String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);

  if (diff.inSeconds < 60) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
  if (diff.inHours < 24) return "${diff.inHours}h ago";
  return "${diff.inDays}d ago";
}


  @override
  void initState() {
    super.initState();

    _video = VideoPlayerController.network(widget.reel.videoUrl)
      ..initialize().then((_) {
        if (!mounted) return; 
        _video.setVolume(isMuted ? 0 : 1);
        if (widget.isActive) _video.play();
        _video.setLooping(true);

        setState(() {});
      });
  }

  void pauseVideo() {
    if (_video.value.isPlaying) {
      _video.pause();
    }
    // setState(() {});
  }

  void showLikeAnimation() {
    if (!mounted) return;
    setState(() => showHeart = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => showHeart = false);
    });
  }

  // ---------------------------------------------------------------------------
  //                          LIKE API FINAL (WORKS WITH YOUR SERVER)
  // ---------------------------------------------------------------------------

Future<void> likeReel() async {
  try {
    final box = GetStorage();

    final token = box.read("access") ?? "";
    final userId = box.read("user_id"); // 👈 logged-in user id
    final reelId = widget.reel.id;

    final url =
        "https://app.pawdli.com/user/short_video/$reelId/like/";

    // 🔍 LOGS YOU WANT
    print("❤️ LIKE TAPPED");
    print("🎬 REEL ID: $reelId");
    print("👤 LIKED USER ID: $userId");
    print("🌐 LIKE API URL: $url");

    // 🔥 OPTIMISTIC UPDATE (UI first)
    setState(() {
      widget.reel.isLiked = !widget.reel.isLiked;
      widget.reel.likesCount += widget.reel.isLiked ? 1 : -1;
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("✅ LIKE STATUS CODE: ${response.statusCode}");
    print("📦 LIKE RESPONSE BODY: ${response.body}");

    if (response.statusCode != 200) {
      // ❌ revert if API failed
      setState(() {
        widget.reel.isLiked = !widget.reel.isLiked;
        widget.reel.likesCount += widget.reel.isLiked ? 1 : -1;
      });
    }
  } catch (e) {
    print("❌ LIKE ERROR: $e");

    // ❌ revert on error
    setState(() {
      widget.reel.isLiked = !widget.reel.isLiked;
      widget.reel.likesCount += widget.reel.isLiked ? 1 : -1;
    });
  }
}


  // @override
  // void didUpdateWidget(covariant ReelPlayer oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   if (_video.value.isInitialized) {
  //     if (widget.isActive) {
  //       _video.play();
  //     } else {
  //       _video.pause();
  //     }
  //   }
  // }

  // @override
  // void dispose() {
  //   _video.dispose();
  //   super.dispose();
  // }


  // ---------------------------------------------------------------------------

  @override
  void didUpdateWidget(covariant ReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_video.value.isInitialized) {
      if (widget.isActive) {
        _video.play();
      } else {
        _video.pause();
      }
    }
  }

  @override
  void dispose() {
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


      return Stack(
        children: [
          if (_video.value.isInitialized)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,

              // 1️⃣ SINGLE TAP → MUTE / UNMUTE
              onTap: () {
                isMuted = !isMuted;
                _video.setVolume(isMuted ? 0 : 1);
                setState(() {});
              },

              // 2️⃣ DOUBLE TAP → LIKE + HEART ANIMATION
              onDoubleTap: () {
                if (!mounted) return;

                if (!widget.reel.isLiked) {
                  likeReel();
                }
                showLikeAnimation();
              },

              // 3️⃣ LONG PRESS → PAUSE WHILE HOLDING
              onLongPressStart: (_) {
                isLongPressing = true;
                _video.pause();
              },
              onLongPressEnd: (_) {
                if (!mounted) return;

                isLongPressing = false;
                if (widget.isActive) {
                  _video.play();
                }
              },

              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _video.value.size.width,
                        height: _video.value.size.height,
                        child: VideoPlayer(_video),
                      ),
                    ),
                  ),
                  // ❤️ HEART ANIMATION (CENTER)
                  if (showHeart)
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 100,
                    ),
                ],
              ),
            ),
          )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // RIGHT ICONS
          Positioned(
            right: 18,
            bottom: 140,
            child: Column(
              children: [
                GestureDetector(
  onTap: () {
    print("LIKE TAPPED"); // 👈 ADD HERE
    likeReel();           // 👈 CALL API
  },
  child: Column(
    children: [
      Icon(
        widget.reel.isLiked
            ? Icons.favorite
            : Icons.favorite_border,
        color: widget.reel.isLiked ? Colors.red : Colors.white,
        size: 40,
      ),
      const SizedBox(height: 6),
      Text(
        widget.reel.likesCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
),


                const SizedBox(height: 20),

                GestureDetector(
onTap: () {
  String message;

  if (Platform.isIOS) {
    message =
        "Download Pawdli App From IOS Store👇\n"
        "https://apps.apple.com/in/app/pawdli/id6747665709\n\n"
        "Download Pawdli App From Play Store👇\n"
        "https://play.google.com/store/apps/details?id=com.ivyis.pawlli";
  } else {
    message =
        "Download Pawdli App From Play Store👇\n"
        "https://play.google.com/store/apps/details?id=com.ivyis.pawlli\n\n"
        "Download Pawdli App From IOS Store👇\n"
        "https://apps.apple.com/in/app/pawdli/id6747665709";
  }

  Share.share(
    message,
    subject: "Pawdli App Download"
  );

  print("Running on: ${Platform.operatingSystem}");
  print("isIOS: ${Platform.isIOS}");
  print("isAndroid: ${Platform.isAndroid}");
},

  child: const Icon(Icons.share, color: Colors.white, size: 34),
),

              ],
            ),
          ),

          // MUTE BUTTON
          Positioned(
            right: 18,
            bottom: 290,
            child: GestureDetector(
              onTap: () {
                isMuted = !isMuted;
                _video.setVolume(isMuted ? 0 : 1);
                setState(() {});
              },
              child: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

         // USER INFO + CAPTION + TIME
Positioned(
  left: 16,
  right: 80,
  bottom: 80,
  child: GestureDetector(
    onTap: () {
      widget.onPause?.call();
      widget.onUserTap?.call();
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 👤 USER ROW
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 30,
              backgroundImage: widget.reel.userProfilePic.isNotEmpty
                  ? NetworkImage(widget.reel.userProfilePic)
                  : const AssetImage("assets/images/profile_avatar.png")
                      as ImageProvider,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.reel.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 1),

        // 📝 CAPTION (ONLY IF EXISTS)
       if (widget.reel.caption.isNotEmpty)
  LayoutBuilder(
    builder: (context, constraints) {
      const textStyle = TextStyle(
        color: Colors.white,
        fontSize: 14,
      );

      const moreStyle = TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

      // Detect overflow for 1 line
      final textPainter = TextPainter(
        text: TextSpan(text: widget.reel.caption, style: textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.maxWidth);

      final isOverflowing = textPainter.didExceedMaxLines;

      return GestureDetector(
        onTap: () {
          setState(() {
            isCaptionExpanded = !isCaptionExpanded;

            // ⏸ Pause video when expanded
            if (isCaptionExpanded) {
              _video.pause();
            } else {
              if (widget.isActive) _video.play();
            }
          });
        },
        child: RichText(
          maxLines: isCaptionExpanded ? null : 1,
          overflow:
              isCaptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          text: TextSpan(
            children: [
              // Caption text
              TextSpan(
                text: widget.reel.caption,
                style: textStyle,
              ),

              // Inline "... more"
              if (!isCaptionExpanded && isOverflowing)
                const TextSpan(
                  text: " …more",
                  style: moreStyle,
                ),

              // Inline " less"
              if (isCaptionExpanded)
                const TextSpan(
                  text: "  less",
                  style: moreStyle,
                ),
            ],
          ),
        ),
      );
    },
  ),


           const SizedBox(height: 4),
         // ⏱ TIME AGO
        Text(
          timeAgo(widget.reel.createdAt),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
      ],
    ),
  ),
),


        ],
      );
    
  }
}
