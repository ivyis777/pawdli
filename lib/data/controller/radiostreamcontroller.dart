import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StreamVideoPage extends StatefulWidget {
  final String streamUrl;

  const StreamVideoPage({Key? key, required this.streamUrl}) : super(key: key);

  @override
  _StreamVideoPageState createState() => _StreamVideoPageState();
}

class _StreamVideoPageState extends State<StreamVideoPage> {
  late VideoPlayerController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl))
      ..initialize().then((_) {
        setState(() => isLoading = false);
        controller.play();
      }).catchError((e) {
        debugPrint("Video init error: $e");
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Live Stream")),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  )
                : Text("Failed to load stream", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
