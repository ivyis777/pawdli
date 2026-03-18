import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CreateReelCameraPage extends StatefulWidget {
  const CreateReelCameraPage({super.key});

  @override
  State<CreateReelCameraPage> createState() => _CreateReelCameraPageState();
}

class _CreateReelCameraPageState extends State<CreateReelCameraPage> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;

  bool isRecording = false;

  // ⏱ TIMER (40s)
  static const int maxSeconds = 40;
  int secondsLeft = maxSeconds;
  Timer? _timer;

  // 🔦 FLASH
  FlashMode flashMode = FlashMode.off;

  // 🔍 ZOOM
  double minZoom = 1.0;
  double maxZoom = 1.0;
  double currentZoom = 1.0;
  double baseZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _controller!.initialize();

    minZoom = await _controller!.getMinZoomLevel();
    maxZoom = await _controller!.getMaxZoomLevel();

    if (mounted) setState(() {});
  }

  // ❌ CLOSE BUTTON
  Future<void> _onClosePressed() async {
    if (!isRecording) {
      Navigator.pop(context);
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Discard video?", style: TextStyle(color: Colors.white)),
        content: const Text("Your recording will be lost.",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text("Discard", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (shouldExit == true) {
      _stopTimer();
      await _controller?.stopVideoRecording();
      Navigator.pop(context);
    }
  }

  // 🔁 SWITCH CAMERA
  Future<void> _switchCamera() async {
    if (isRecording) return;
    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
    await _controller?.dispose();
    _initCamera();
  }

  // 🔦 FLASH
  Future<void> _toggleFlash() async {
    flashMode =
        flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _controller?.setFlashMode(flashMode);
    setState(() {});
  }

  // ⏱ TIMER
  void _startTimer() {
    secondsLeft = maxSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (secondsLeft == 0) {
        await _stopRecording();
        return;
      }
      setState(() => secondsLeft--);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  // 🎥 RECORD
  Future<void> _startStopRecording() async {
    if (_controller == null) return;

    if (isRecording) {
      await _stopRecording();
    } else {
      await _controller!.startVideoRecording();
      setState(() => isRecording = true);
      _startTimer();
    }
  }

  Future<void> _stopRecording() async {
    _stopTimer();
    final file = await _controller!.stopVideoRecording();
    setState(() => isRecording = false);
    Navigator.pop(context, File(file.path));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => !isRecording,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // CAMERA PREVIEW (NO FILTER)
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (d) => baseZoom = currentZoom,
                onScaleUpdate: (d) async {
                  currentZoom =
                      (baseZoom * d.scale).clamp(minZoom, maxZoom);
                  await _controller!.setZoomLevel(currentZoom);
                },
                child: CameraPreview(_controller!),
              ),
            ),

            // TOP BAR
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _onClosePressed),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          flashMode == FlashMode.off
                              ? Icons.flash_off
                              : Icons.flash_on,
                          color: Colors.white,
                        ),
                        onPressed: _toggleFlash,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cameraswitch,
                            color: Colors.white),
                        onPressed: _switchCamera,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // RECORD BUTTON
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _startStopRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording ? Colors.red : Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: isRecording
                        ? Text(
                            secondsLeft.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
