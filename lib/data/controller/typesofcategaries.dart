
import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/typesofcategaries.dart';

class AllCategoriesController extends GetxController {
  var isLoading = false.obs;
  var allCategories = <Data>[].obs;
  var errorMessage = ''.obs;

 Future<void> fetchAllCategories() async {
  try {
    isLoading(true);
    errorMessage(''); 

    final categoriesModel = await ApiService.fetchAllCategories();

    if (categoriesModel != null) {
      allCategories.assignAll(categoriesModel);
    } else {
      errorMessage.value = 'Failed to fetch categories';
    }
  } catch (e) {
    errorMessage.value = 'An error occurred:';
  } finally {
    isLoading(false); 
  }
}
}