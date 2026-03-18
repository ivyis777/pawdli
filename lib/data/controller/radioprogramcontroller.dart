// import 'dart:convert';
// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:pawlli/data/api%20service.dart' show ApiService;
// import 'package:pawlli/data/model/radioprogrammodel.dart';

// class RadioProgramController extends GetxController {
//   var isRecorded = false.obs;
//   var selectedFile = Rx<File?>(null);
//   var uploadedFileUrl = "".obs;

//   void setProgramMode(String mode) {
//     isRecorded.value = mode == "recorded";
//   }

//   void setFile(File file) {
//     selectedFile.value = file;
//   }

//   Future<void> bookSlot(RadioProgramModel model) async {
//   const endpoint = "https://app.pawdli.com/user/radio_book_slot/";

//   try {
//     if (model.programMode == "recorded") {
//       if (model.uploadFile == null) {
//         throw Exception("Please upload a recorded audio file");
//       }

//       final response = await ApiService.postMultipart(
//         url: endpoint,
//         fields: model.toMultipartFields(),
//         file: model.uploadFile!,
//         fileFieldName: "file", // must match backend
//       );

//       final body = await response.stream.bytesToString();
//       if (response.statusCode == 200) {
//         uploadedFileUrl.value = body;
//         print("File uploaded successfully: $body");
//       } else {
//         throw Exception("Failed to upload file: ${response.statusCode} → $body");
//       }
//     } else {
//       // Live program — just send JSON
//       final response = await ApiService.postJson(
//         url: endpoint,
//         body: model.toJson(),
//       );

//       if (response.statusCode != 200) {
//         throw Exception(
//             "Failed to book live program: ${response.statusCode} → ${response.body}");
//       }
//     }
//   } catch (e) {
//     rethrow;
//   }
// }
// }