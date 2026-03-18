import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/subcategarymodel.dart';


class AllSubCategoriesController extends GetxController {
  var isLoading = false.obs;
  var allsubCategories = <Data>[].obs;
  var errorMessage = ''.obs;
  


  Future<void> fetchAllsubCategories(int categoryId) async {
    try {
      isLoading(true); 
      errorMessage(''); 

      // Fetch categories from the API
      final categoriesModel = await ApiService.fetchAllSubCategories(categoryId);

      // Check if the response is valid (non-null and non-empty)
      if (categoriesModel != null && categoriesModel.isNotEmpty) {
        // Update the observable list with the fetched data
        allsubCategories.assignAll(categoriesModel.toList()); // Fix applied here
      } else {
        // Handle empty response or null categoriesModel
        errorMessage('No categories found');
        allsubCategories.clear(); // Clear the list
      }
    } catch (e) {
      // Handle any errors, such as network issues
      errorMessage('An error occurred:');
      allsubCategories.clear(); // Clear the list on error
    } finally {
      isLoading(false); // Stop loading
    }
  }
}
