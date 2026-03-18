import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/podcastlistcontrolller.dart';
import 'package:pawlli/presentation/screens/potcast/ontappodcast.dart';

class PodcastScreen extends StatefulWidget {
  @override
  _PodcastScreenState createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  String selectedCategory = 'Explore';

  final PodcastListController controller = Get.put(PodcastListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Pet Podcast',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colours.primarycolour,
        foregroundColor: Colours.seachbarcolour,
      ),
      body: Stack(
        children: [
          // Semi-circle at the top
          Positioned(
            top: -50,
            left: -50,
            right: -50,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 500,
              decoration: BoxDecoration(
                color: Colours.primarycolour,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(150),
                ),
              ),
            ),
          ),

          Column(
            children: [
              SizedBox(height: 40),
              // Category Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCategoryButton('Live', Icons.live_tv),
                    _buildCategoryButton('Podcast', Icons.podcasts),
                    _buildCategoryButton('Explore', Icons.explore),
                    _buildCategoryButton('Events', Icons.event),
                    _buildCategoryButton('Library', Icons.library_music),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Show different content based on selected category
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.podcasts.isEmpty) {
                    return Center(child: Text(controller.message.value));
                  }

                  return selectedCategory == 'Library'
                      ? _buildLibraryGrid()
                      : selectedCategory == 'Explore'
                          ? _buildExploreContent(context)
                          : Center();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Category Button Widget
  Widget _buildCategoryButton(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: selectedCategory == title
                ? Colors.brown
                : Colors.brown.shade200,
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: selectedCategory == title ? Colors.brown : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Grid for Library Category (Dynamic)
  Widget _buildLibraryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemCount: controller.podcasts.length,
        itemBuilder: (context, index) {
          final podcast = controller.podcasts[index];
          return _buildPodcastCard(podcast);
        },
      ),
    );
  }
/// Explore Section - Dynamic
Widget _buildExploreContent(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: controller.podcasts
          .where((p) => p.isActive == true) // ✅ only active
          .map((podcast) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Allepisode(
                  podcastId: podcast.podcastId?? 0,
                ),
              ),
            );
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Podcast Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: podcast.coverImage != null &&
                          podcast.coverImage!.isNotEmpty
                      ? Image.network(
                          podcast.coverImage!,
                          width: MediaQuery.of(context).size.width * 0.9,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/images/placeholder.png",
                          width: MediaQuery.of(context).size.width * 0.9,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 10),
                // Podcast Title
                Text(
                  podcast.title ?? "No Title",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                // Podcast Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    podcast.description ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );
}

// Podcast Card Widget (Dynamic) for Library
Widget _buildPodcastCard(podcast) {
  if (podcast.isActive != true) return const SizedBox.shrink(); // ✅ hide inactive

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Podcast Image
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: podcast.coverImage != null && podcast.coverImage!.isNotEmpty
                ? Image.network(
                    podcast.coverImage!,
                    width: MediaQuery.of(context).size.width * 0.9,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/images/placeholder.png",
                    width: MediaQuery.of(context).size.width * 0.9,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        // Podcast Title
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            podcast.title ?? "No Title",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        // Podcast Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            podcast.description ?? "",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colours.darkgreyColour,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}
}