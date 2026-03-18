import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/petstoresubcategaries.dart';


class PetStoreController extends GetxController {

  var subCategories = <SubCategoryData>[].obs;
  var isLoading = false.obs;
  var errorMessage = "".obs;

  Future<void> loadSubCategories(int categoryId) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      subCategories.assignAll(await ApiService.fetchPetStoreSubCategories(categoryId));
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
