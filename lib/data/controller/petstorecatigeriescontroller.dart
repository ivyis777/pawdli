import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/PetStoreCategariesModel.dart' show Data;


class PetStoreCategoryController extends GetxController {
  var isLoading = false.obs;
  var categories = <Data>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final result = await ApiService.fetchPetStoreCategories();
      categories.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }
}
