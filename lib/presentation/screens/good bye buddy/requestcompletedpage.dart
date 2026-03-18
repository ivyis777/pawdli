import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/presentation/widgets/bottom%20bar/bottombar.dart';

class CompleteRequestPage extends StatefulWidget {
  final int requestId;
  final String location;

  const CompleteRequestPage({
    super.key,
    required this.requestId,
    required this.location,
  });

  @override
  State<CompleteRequestPage> createState() => _CompleteRequestPageState();
}

class _CompleteRequestPageState extends State<CompleteRequestPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> images = [];
  final TextEditingController descriptionController =
      TextEditingController();

  bool isLoading = false;

  /// 📸 PICK IMAGES
  Future<void> pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        images.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  /// 🚀 API CALL
  Future<void> completeRequest() async {
    if (images.isEmpty) {
      Get.snackbar("Error", "Please upload images");
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter description");
      return;
    }

    setState(() => isLoading = true);

    try {
      final box = GetStorage();
      final accessToken = box.read('access') ?? '';

      final url = Uri.parse(
  "https://app.pawdli.com/user/goodbye-buddy/${widget.requestId}/admin-update/",
);

var request = http.MultipartRequest(
  "PATCH", // ✅ correct method
  url,
);

request.headers.addAll({
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    });
print("TOKEN: $accessToken");
request.fields["status"] = "completed"; // ✅ must match backend
request.fields["admin_description"] =
    descriptionController.text;

/// 📸 FIXED IMAGE KEY
for (var img in images) {
  request.files.add(
    await http.MultipartFile.fromPath(
      "admin_images", // ✅ VERY IMPORTANT
      img.path,
    ),
  );
}

      var response = await request.send();
      var res = await response.stream.bytesToString();

      print("STATUS: ${response.statusCode}");
      print("BODY: $res");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        Get.snackbar("Success", "Request Completed");

        Get.offAll(() =>  MainLayout());

        Get.back(result: true);
      } else {
        Get.snackbar("Error", res);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      /// 🔝 APP BAR WITH CURVE DESIGN
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
          "Complete Request",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colours.brownColour,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// REQUEST ID
            Text(
              "Request ID: ${widget.requestId}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            /// LOCATION
            Text(
              "Location: ${widget.location}",
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 25),

            /// UPLOAD TITLE
            const Text(
              "Upload Completion Images",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 15),

            /// TAKE IMAGES BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffF5A623),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 12),
              ),
              onPressed: pickImages,
              child: const Text(
                "Take Images",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 15),

            /// PREVIEW IMAGES
            if (images.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return Image.file(images[index],
                      fit: BoxFit.cover);
                },
              ),

            const SizedBox(height: 25),

            /// DESCRIPTION
            const Text(
              "Completion Description",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  // hintText: "Enter details...",
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// SUBMIT BUTTON
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF5A623),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100, vertical: 14),
                ),
                onPressed: isLoading ? null : completeRequest,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text(
                        "Request Completed",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}