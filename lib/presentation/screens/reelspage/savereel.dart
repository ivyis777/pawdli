import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReelSaveHelper {
  static Future<void> save(BuildContext context, String videoUrl) async {
    try {
      final permission = await Permission.storage.request();

      if (!permission.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission required")),
        );
        return;
      }

      Directory directory;

      if (Platform.isAndroid) {
        directory = Directory("/storage/emulated/0/Movies/Pawlli");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final filePath =
          "${directory.path}/reel_${DateTime.now().millisecondsSinceEpoch}.mp4";

      final response = await http.get(Uri.parse(videoUrl));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video saved successfully")),
      );
    } catch (e) {
      print("SAVE VIDEO ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save video")),
      );
    }
  }
}
