import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/postcastepisodecontroller.dart';
import 'package:pawlli/presentation/screens/potcast/videoplayer.dart';

class Allepisode extends StatefulWidget {
  final int podcastId;

  const Allepisode({Key? key, required this.podcastId}) : super(key: key);

  @override
  _AllepisodeState createState() => _AllepisodeState();
}

class _AllepisodeState extends State<Allepisode> {
  late final PodcastEpisodeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PodcastEpisodeController());
    controller.loadEpisodes(widget.podcastId);
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Unknown Date";
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat("MMM d, yyyy").format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.episodes.isEmpty) {
          return Center(child: Text(controller.message.value));
        }

        // Get podcast info from first episode (all episodes belong to same podcast)
        final podcastInfo = controller.episodes.first.podcast;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Podcast Header
              _buildHeader(controller.episodes.first.thumbnailUrlFull ?? ""),

              const SizedBox(height: 60),

              // Podcast Info (title, host, description)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      podcastInfo?.title ?? "Podcast",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      controller.episodes.first.guest?.name ?? "Unknown Host",
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      podcastInfo?.description ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14, height: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // All Episodes Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: const [
                    Text(
                      "All Episodes",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            // Replace this block
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: Column(
    children: List.generate(controller.episodes.length, (index) {
      final ep = controller.episodes[index];
      return Column(
        children: [
          _buildEpisodeItem(
            "Ep ${index + 1}",
            ep.title ?? "No Title",
            "${ep.durationMinutes ?? 0} min",
            _formatDate(ep.uploadedAt),
            ep.fileUrlFull ?? "",
          ),
          const SizedBox(height: 8), // space between episodes
        ],
      );
    }),
  ),
),


            ],
          ),
        );
      }),
    );
  }

  // Header with banner + avatar
  Widget _buildHeader(String imagePath) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 260,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imagePath.isNotEmpty
                  ? NetworkImage(imagePath)
                  : const AssetImage("assets/images/placeholder.png")
                      as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: 40,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ),
        Positioned(
          bottom: -50,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: imagePath.isNotEmpty
                  ? Image.network(imagePath, width: 95, height: 95, fit: BoxFit.cover)
                  : Image.asset("assets/images/placeholder.png",
                      width: 95, height: 95, fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodeItem(
      String epNumber, String title, String duration, String date, String videoUrl) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                epNumber,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    "$duration   |   $date",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (videoUrl.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApiVideoPlayer(videoUrl: videoUrl),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No video available for this episode")),
                  );
                }
              },
              child: Icon(
                videoUrl.isNotEmpty
                    ? Icons.play_circle_fill
                    : Icons.play_circle_outline,
                color: videoUrl.isNotEmpty ? Colours.primarycolour : Colors.grey,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
