import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:video_player/video_player.dart';
import 'package:pawlli/data/api service.dart';

class StreamVideoPage extends StatefulWidget {
  final String streamUrl;

  const StreamVideoPage({Key? key, required this.streamUrl}) : super(key: key);

  @override
  State<StreamVideoPage> createState() => _StreamVideoPageState();
}

class _StreamVideoPageState extends State<StreamVideoPage> {
  late VideoPlayerController _controller;
  bool _loading = true;
  bool _error = false;

  Timer? _pollTimer;
  String currentUrl = "";

  @override
  void initState() {
    super.initState();
    currentUrl = widget.streamUrl;
    _startPlayer();
    _startPolling();
  }

  // ----------------------- POLLING BACKEND -----------------------
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final result = await ApiService.validateSlotAndGetToken();
      if (result == null) return;

      bool live = result["live"] ?? false;
      String newUrl = result["stream_url"] ?? "";

      debugPrint("🔄 Poll: live=$live | url=$newUrl");

      if (!live) {
        debugPrint("⚠️ Stream offline");
        setState(() => _error = true);
        return;
      }

      if (newUrl.isNotEmpty && newUrl != currentUrl) {
        debugPrint("🔁 Stream URL changed — reconnecting...");
        currentUrl = newUrl;
        _startPlayer();
      }
    });
  }

  // ----------------------- START PLAYER -----------------------
  Future<void> _startPlayer() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(currentUrl));

      await _controller.initialize();
      await _controller.play();

      _controller.addListener(() {
        if (_controller.value.hasError) {
          debugPrint("🔥 Player Error: ${_controller.value.errorDescription}");
          setState(() => _error = true);
        }
      });

      setState(() => _loading = false);
    } catch (e) {
      debugPrint("🔥 Init Error: $e");
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ----------------------- UI -----------------------
  @override
  Widget build(BuildContext context) {
    bool isAudioOnly =
        _controller.value.isInitialized &&
        (_controller.value.size.width == 0 ||
            _controller.value.aspectRatio.isNaN);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Live Stream"),
        backgroundColor: Colors.black,
        foregroundColor: Colours.secondarycolour,
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)

            : _error
                ? const Text(
                    "Stream Offline",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  )

                : _controller.value.isInitialized
                    ? isAudioOnly
                        ? const AudioVisualizer()
                        : AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )

                    : const Text(
                        "Stream not available",
                        style: TextStyle(color: Colors.white),
                      ),
      ),
    );
  }
}

// ----------------------- AUDIO VISUALIZER -----------------------

class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer({super.key});

  @override
  _AudioVisualizerState createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _bar(25),
            const SizedBox(width: 6),
            _bar(45),
            const SizedBox(width: 6),
            _bar(35),
            const SizedBox(width: 6),
            _bar(55),
          ],
        );
      },
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 10,
      height: height * (_controller.value + 0.4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
