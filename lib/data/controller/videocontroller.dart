// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:get/get.dart' hide FormData, MultipartFile, Response;
// import 'package:file_picker/file_picker.dart';
// import 'package:pawlli/data/model/reelUploadmodel.dart';

// class UploadController extends GetxController {
//   Rx<File?> selectedFile = Rx<File?>(null);
//   var isUploading = false.obs;
//   var isLoadingReels = false.obs;

//   RxList<ProgramUploadModel> uploadedVideos = <ProgramUploadModel>[].obs;

//   // Pick a file (mp4 or mp3)
//   Future<void> pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['mp4', 'mp3'],
//     );

//     if (result != null && result.files.single.path != null) {
//       selectedFile.value = File(result.files.single.path!);
//     }
//   }

//   // Upload file to backend
//   // Upload the file
// Future<void> uploadFile(ProgramUploadModel model) async {
//   if (selectedFile.value == null) {
//     Get.snackbar("Error", "Please select a file first");
//     return;
//   }

//   isUploading.value = true;

//   try {
//     String fileName = selectedFile.value!.path.split('/').last;

//     FormData formData = FormData.fromMap({
//       ...model.toJson(),
//       "program_file": await MultipartFile.fromFile(
//         selectedFile.value!.path,
//         filename: fileName,
//       ),
//     });

//     Response response = await Dio().post(
//       "https://app.pawdli.com/user/radio_book_slot/",
//       data: formData,
//       options: Options(
//         headers: {
//           "Content-Type": "multipart/form-data",
//         },
//       ),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       Get.snackbar("Success", "File uploaded successfully 🎉");
//     } else {
//       Get.snackbar("Error",
//           "Upload failed ❌ Code: ${response.statusCode}");
//     }
//   } catch (e) {
//     Get.snackbar("Error", "Upload failed: $e");
//   } finally {
//     isUploading.value = false;
//   }
// }


//   // Fetch uploaded video list
//   Future<void> fetchReels() async {
//     isLoadingReels.value = true;

//     try {
//       Response response = await Dio().post(
//         "https://app.pawdli.com/user/check_stream_url",
//         data: {"user_id": 10},
//       );

//     if (response.statusCode == 200) {
//   var data = response.data["data"] as List<dynamic>;
//   uploadedVideos.value = data.map((e) => ProgramUploadModel.fromJson(e)).toList();
// } else {
//   Get.snackbar("Error", "Failed to fetch videos ❌");
// }

//     } catch (e) {
//       Get.snackbar("Error", "Fetch error: $e");
//     } finally {
//       isLoadingReels.value = false;
//     }
//   }
// }
