import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/goodbyebuddylistcontroller.dart';
import 'package:url_launcher/url_launcher.dart';

class UserRequestDetailsPage extends StatefulWidget {
  final int requestId;

  const UserRequestDetailsPage({super.key, required this.requestId});

  @override
  State<UserRequestDetailsPage> createState() =>
      _UserRequestDetailsPageState();
}

class _UserRequestDetailsPageState
    extends State<UserRequestDetailsPage> {

  final controller = Get.put(GoodbyeRequestDetailsController());

  String formatDateTime(String date) {
  try {
    final parsedDate = DateTime.parse(date).toLocal();
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
  } catch (e) {
    return date;
  }
}

  @override
  void initState() {
    super.initState();
    controller.fetchRequestDetails(widget.requestId);
  }

  Future<void> openGoogleMap(double lat, double lng) async {
    final Uri url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// 🔥 COMMON FULL IMAGE VIEW
  void showFullImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close,
                    color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 URL FIX METHOD
  String getImageUrl(String path) {
    if (path.startsWith("http")) return path;
    return "https://pawlli-podcasts.s3.ap-south-1.amazonaws.com/$path";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60, // 🔥 increase height
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        /// 🔥 TOP IMAGE
        flexibleSpace: Stack(
          children: [
            SizedBox(
              height: 100,
              width: 250,
              child: Image.asset(
                "assets/images/topimage.png", // 🔴 change if your path different
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),

        /// 🔙 BACK BUTTON
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colours.brownColour),
          onPressed: () {
            Get.back();
          },
        ),

        /// 📝 TITLE
        title: Text(
          "My Request Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colours.brownColour,
          ),
        ),
      ),

      body: Obx(() {

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.requestDetails.value;

        if (data == null) {
          return const Center(child: Text("No data"));
        }

        final images = data.images ?? [];
        final adminImages = data.adminImages ?? [];
        final adminDescription = data.adminDescription ?? "";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// STATUS
              Row(
                children: [
                  const Text("Task Status: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    data.status ?? "",
                    style: TextStyle(
                      color: data.status == "completed"
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
                const Divider(height: 30),

                              /// ADMIN SECTION (TOP)
                if (data.status == "completed") ...[

                  /// 🔹 ADMIN DESCRIPTION FIRST
                  if (adminDescription.isNotEmpty) ...[
                    const Text(
                      "Notes:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 247, 245),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color.fromARGB(255, 10, 10, 10)),
                      ),
                      child: Text(
                        adminDescription,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  /// 🔹 COMPLETED IMAGES BELOW DESCRIPTION
                  if (adminImages.isNotEmpty) ...[
                    const Text(
                      "Completed Work Images",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: adminImages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final url = getImageUrl(adminImages[index]);

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: GestureDetector(
                              onTap: () => showFullImage(url),
                              child: Image.network(
                                url,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],

                const Divider(height: 30),

              const Text("User Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

              const SizedBox(height: 20),

              /// USER IMAGES
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {

                  final url = getImageUrl(images[index]);

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: GestureDetector(
                        onTap: () => showFullImage(url),
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

        
             

              const SizedBox(height: 20),

              const Text("Location Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

              const SizedBox(height: 8),

              Text(data.location ?? ""),

              const SizedBox(height: 15),

              const Text("Landmark",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

              const SizedBox(height: 6),

              Text(data.landmark ?? ""),

              const SizedBox(height: 20),

              const Text("Google Maps Link",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

              const SizedBox(height: 6),

              InkWell(
                onTap: () {
                  if (data.latitude != null && data.longitude != null) {
                    openGoogleMap(data.latitude!, data.longitude!);
                  }
                },
                child: Text(
                  "https://www.google.com/maps/search/?api=1&query=${data.latitude},${data.longitude}",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),

              const SizedBox(height: 20),

              const Text("Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

              const SizedBox(height: 6),

              Text(data.description ?? ""),

              const SizedBox(height: 20),

              const Text("Created On",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

              const SizedBox(height: 6),

              Text(
                formatDateTime(data.createdAt ?? ""),
              ),
            ],
          ),
        );
      }),
    );
  }
}