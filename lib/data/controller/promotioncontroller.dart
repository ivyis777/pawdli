// import 'package:get/get.dart';
// import 'package:pawlli/data/api%20service.dart';
// import 'package:pawlli/data/model/promotionmodel.dart';


// class PromotionController extends GetxController {
//   var promotions = <PromotionModel>[].obs;
//   var isLoading = false.obs; // Default should be false to prevent unnecessary loading

//   Future<void> fetchPromotions() async {
//     isLoading.value = true;
//     try {
//       List<PromotionModel>? response = await ApiService.fetchPromotions();

//       if (response != null && response.isNotEmpty) {
//         promotions.assignAll(response);
//       } else {
//         promotions.clear(); // Clears the list if response is empty or null
//       }

//       print('Fetched promotions: $response');
//     } catch (e) {
//       print("Error fetching promotions: $e");
//       promotions.clear();
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }