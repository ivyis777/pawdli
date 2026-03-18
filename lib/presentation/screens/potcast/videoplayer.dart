import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ApiVideoPlayer extends StatefulWidget {
  final String videoUrl; // <-- Pass video URL from API

  const ApiVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _ApiVideoPlayerState createState() => _ApiVideoPlayerState();
}

class _ApiVideoPlayerState extends State<ApiVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      setState(() {
        _currentPosition = _controller.value.position;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatTime(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(position.inMinutes.remainder(60));
    final seconds = twoDigits(position.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) setState(() => _showControls = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? GestureDetector(
              onTap: _toggleControls,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video Player
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),

                  // Back Arrow (Top Left)
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Controls Overlay
                  if (_showControls)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Progress bar
                            VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: Colors.red,
                                bufferedColor: Colors.grey,
                              ),
                            ),

                            // Time and controls row
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatTime(_currentPosition),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    formatTime(_controller.value.duration),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),

                            // Play / Pause / Seek buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.replay_10,
                                      color: Colors.white),
                                  iconSize: 36,
                                  onPressed: () {
                                    final newPos = _controller.value.position -
                                        Duration(seconds: 10);
                                    _controller.seekTo(newPos > Duration.zero
                                        ? newPos
                                        : Duration.zero);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    color: Colors.white,
                                  ),
                                  iconSize: 60,
                                  onPressed: () {
                                    setState(() {
                                      _controller.value.isPlaying
                                          ? _controller.pause()
                                          : _controller.play();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.forward_10,
                                      color: Colors.white),
                                  iconSize: 36,
                                  onPressed: () {
                                    final newPos = _controller.value.position +
                                        Duration(seconds: 10);
                                    _controller.seekTo(newPos <
                                            _controller.value.duration
                                        ? newPos
                                        : _controller.value.duration);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
