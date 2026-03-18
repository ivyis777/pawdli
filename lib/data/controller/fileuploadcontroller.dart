import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pawlli/data/api%20service.dart';

class FilePickerController extends GetxController {
  var selectedFile = Rx<File?>(null);
  var fileName = "".obs;
  var selectedType = "".obs; // or "Video"
  var isUploading = false.obs;

  // PICK FILE
  Future pickFile() async {
    FilePickerResult? result;

    if (selectedType.value == "Audio") {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3'],
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4'],
      );
    }

    if (result != null) {
      selectedFile.value = File(result.files.single.path!);
      fileName.value = result.files.single.name;
    } else {
      fileName.value = "";
      selectedFile.value = null;
    }
  }

  // UPLOAD FILE
  Future<bool> uploadFile() async {
    if (selectedFile.value == null) return false;

    isUploading.value = true;

    bool success = await ApiService.uploadFile(
      file: selectedFile.value!,
      type: selectedType.value,
    );

    isUploading.value = false;
    return success;
  }
}
