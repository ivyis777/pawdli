import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api service.dart';
import 'package:pawlli/data/model/reelUploadmodel.dart';

class UploadReelController extends GetxController {
  // -------------------- STATE --------------------
  final isUploading = false.obs;

  /// Upload progress: 0.0 → 1.0
  final uploadProgress = 0.0.obs;

  /// Main preview thumbnail
  final thumbnailBytes = Rxn<Uint8List>();

  /// Frames strip thumbnails
  final videoFrames = <Uint8List>[].obs;

  /// API response
  final uploadResponse = Rxn<UploadReelResponse>();

  final GetStorage box = GetStorage();

  // -------------------- THUMBNAIL (MAIN PREVIEW) --------------------
  Future<void> generateThumbnail(File video) async {
    try {
      final data = await VideoThumbnail.thumbnailData(
        video: video.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 400,
        quality: 70,
      );

      thumbnailBytes.value = data;

      // 🔥 Also generate frames for bottom strip
      await generateFrames(video);
    } catch (e) {
      print("❌ THUMBNAIL ERROR: $e");
    }
  }

  // -------------------- FRAMES FOR STRIP --------------------
  Future<void> generateFrames(File video) async {
    try {
      videoFrames.clear();

      // Generate 6 frames (1s interval)
      for (int i = 1; i <= 6; i++) {
        final bytes = await VideoThumbnail.thumbnailData(
          video: video.path,
          imageFormat: ImageFormat.JPEG,
          timeMs: i * 1000,
          quality: 50,
        );

        if (bytes != null) {
          videoFrames.add(bytes);
        }
      }
    } catch (e) {
      print("❌ FRAME GENERATION ERROR: $e");
    }
  }

  // -------------------- UPLOAD REEL (WITH PROGRESS) --------------------
  Future<bool> uploadReel({
    required File videoFile,
    required String title,
    required String description,
  }) async {
    try {
          // ================= DEBUG START =================
    final uploadTime = DateTime.now().toIso8601String();

    debugPrint("🚀 uploadReel() STARTED");
    debugPrint("📁 Video Path: ${videoFile.path}");
    debugPrint("📝 Title: $title");
    debugPrint("📝 Description Sent: $description");
    debugPrint("⏱️ Upload Time: $uploadTime");
    // ================= DEBUG END ===================

      isUploading.value = true;
      uploadProgress.value = 0;

      // ✅ Always read token using constant
      String? token = box.read(LocalStorageConstants.access);

      if (token == null || token.isEmpty) {
        debugPrint("❌ ERROR: Access token missing");
        isUploading.value = false;
        return false;
      }

       debugPrint("🔐 Access Token Found");

      // 🔥 Upload with progress (token refresh handled in API)
      final UploadReelResponse? result =
          await ApiService.uploadReelWithProgress(
        videoFile: videoFile,
        title: title,
        caption: description,
        token: token,
        onProgress: (sent, total) {
          if (total > 0) {
            uploadProgress.value = sent / total;
          }
        },
      );

      if (result == null) {
        print("❌ Upload failed: API returned null");
        isUploading.value = false;
        uploadProgress.value = 0;
        return false;
      }

          // ================= RESPONSE DEBUG =================
    debugPrint("✅ UPLOAD SUCCESS");
    debugPrint("📦 API RESPONSE: $result");
    // =================================================

      uploadResponse.value = result;

      isUploading.value = false;
      uploadProgress.value = 0;
      return true;
    } catch (e) {
      print("❌ UPLOAD ERROR: $e");
      isUploading.value = false;
      uploadProgress.value = 0;
      return false;
    }
  }

  // -------------------- CLEANUP --------------------
  @override
  void onClose() {
    thumbnailBytes.value = null;
    videoFrames.clear();
    uploadProgress.value = 0;
    super.onClose();
  }
}
