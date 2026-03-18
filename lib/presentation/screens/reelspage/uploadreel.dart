import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/reelUploadcontroller.dart';
import 'package:pawlli/data/controller/reelitemcontroller.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:video_player/video_player.dart';

class UploadReelPage extends StatelessWidget {
  const UploadReelPage({super.key});

  Future<void> pickVideo(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddDetailsPage(videoFile: File(pickedFile.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(80),
  child: Stack(
    children: [
      AppBar(
        title: const Text("Upload Videos"),
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

      body: Center(
        child: ElevatedButton(
          onPressed: () => pickVideo(context),
          child: const Text("Select Video"),
        ),
      ),
    );
  }
}

class AddDetailsPage extends StatefulWidget {
  final File videoFile;

  const AddDetailsPage({required this.videoFile, super.key});

  @override
  State<AddDetailsPage> createState() => _AddDetailsPageState();
}

class _AddDetailsPageState extends State<AddDetailsPage> {
  final controller = Get.put(UploadReelController());

  final titleController = TextEditingController();
  final descController = TextEditingController();
  late VideoPlayerController _videoController;


  @override
  void initState() {
    super.initState();
    controller.generateThumbnail(widget.videoFile);

      _videoController = VideoPlayerController.file(widget.videoFile)
    ..initialize().then((_) {
      setState(() {});
    });
  }

@override
void dispose() {
  _videoController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(80),
  child: Stack(
    children: [
      AppBar(
        centerTitle: true,
        title: const Text("Upload Videos"),
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
           // ---------------- VIDEO PREVIEW ----------------
// ---------------- VIDEO PREVIEW WITH CENTER PLAY ICON ----------------
// ---------------- FIXED SIZE VIDEO PREVIEW ----------------
if (_videoController.value.isInitialized)
  GestureDetector(
    onTap: () {
      setState(() {
        _videoController.value.isPlaying
            ? _videoController.pause()
            : _videoController.play();
      });
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 240, // 🔒 FIXED HEIGHT
        width: double.infinity,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🎥 VIDEO FILLS CONTAINER
            FittedBox(
              fit: BoxFit.cover, // 🔥 KEY LINE
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            ),

            // ▶️ CENTER PLAY ICON
            AnimatedOpacity(
              opacity: _videoController.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.play_circle_fill,
                size: 64,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    ),
  )
else
  Container(
    height: 240,
    width: double.infinity,
    color: Colors.black12,
    child: const Icon(Icons.videocam, size: 50),
  ),

              const SizedBox(height: 12),

              // ---------------- DESCRIPTION ----------------
              TextField(
                controller: descController,
                maxLines: 3,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Description",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.2,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 25),

            Obx(() {
              return ElevatedButton(
                onPressed: controller.isUploading.value
                    ? null
                    : () async {

                        final uploadedAt = DateTime.now().toIso8601String();

                        debugPrint("🟡 UPLOAD BUTTON CLICKED");
                        debugPrint("📝 Description Entered: ${descController.text}");
                        debugPrint("⏱️ Upload Time (Local): $uploadedAt");

                        bool ok = await controller.uploadReel(
                          videoFile: widget.videoFile,
                          title: titleController.text,
                          description: descController.text,
                        );

                    if (ok) {
                      Get.find<ReelsController>().fetchReels();

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          // ⏱ Auto close after 2 seconds
                          Future.delayed(const Duration(seconds: 2), () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context); // close dialog
                              Navigator.pop(context); // go back page
                            }
                          });

                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colours.primarycolour,
                                  size: 60,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Uploaded Successfully",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Upload Failed ❌")),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colours.primarycolour,
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: controller.isUploading.value
    ? Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 36,
            width: 36,
            child: CircularProgressIndicator(
              value: controller.uploadProgress.value,
              color: Colors.green,
              strokeWidth: 4,
            ),
          ),
          Text(
            "${(controller.uploadProgress.value * 100).toInt()}%",
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      )
    : const Text(
        "Upload Video",
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),
      ),

              );
            }),
          ],
        ),
      ),
    );
  }
}
