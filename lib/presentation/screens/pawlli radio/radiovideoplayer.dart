// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class StreamVideoPage extends StatefulWidget {
//   final int slotId; // <-- Add this

//   const StreamVideoPage({Key? key, required this.slotId}) : super(key: key);

//   @override
//   State<StreamVideoPage> createState() => _StreamVideoPageState();
// }

// class _StreamVideoPageState extends State<StreamVideoPage> {
//   VideoPlayerController? _controller;
//   bool _isLoading = true;

//   Future<void> fetchStreamUrl() async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://app.pawdli.com/user/check_stream_url'),
//         body: jsonEncode({
//           "slot_id": widget.slotId
//         }),
//         headers: {
//           "Content-Type": "application/json",
//         },
//       );

//       final data = jsonDecode(response.body);
//       print("API Response: $data");

//       if (response.statusCode == 200 && data["stream_url"] != null) {
//         final streamUrl = data["stream_url"];
//         _initializeVideo(streamUrl);
//       } else {
//         throw Exception(data["message"] ?? "Stream URL not found");
//       }
//     } catch (e) {
//       print("Error: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Stream not available")),
//         );
//       }
//     }
//   }

//   void _initializeVideo(String url) {
//     _controller = VideoPlayerController.network(url)
//       ..initialize().then((_) {
//         setState(() => _isLoading = false);
//         _controller!.play();
//       });
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchStreamUrl();
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Live Stream")),
//       body: Center(
//         child: _isLoading
//             ? CircularProgressIndicator()
//             : AspectRatio(
//                 aspectRatio: _controller!.value.aspectRatio,
//                 child: VideoPlayer(_controller!),
//               ),
//       ),

//       floatingActionButton: _controller == null
//           ? null
//           : FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   _controller!.value.isPlaying
//                       ? _controller!.pause()
//                       : _controller!.play();
//                 });
//               },
//               child: Icon(
//                 _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
//               ),
//             ),
//     );
//   }
// }
