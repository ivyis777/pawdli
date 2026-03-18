import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/languagemodel.dart';


class LanguageController extends GetxController {
  var isLoading = false.obs;
  var allLanguages = <String>[].obs;
  var selectedLanguages = <String>[].obs;
 @override
  void onInit() {
    super.onInit();
    fetchLanguageData(); // Fetch data when the controller is initialized
  }
  Future<void> fetchLanguageData() async {
    try {
      isLoading.value = true;
      final LanguageCreationModel? result = await ApiService.fetchLanguage();

      if (result?.languages != null) {
        allLanguages.assignAll(result!.languages!);
      } else {
        allLanguages.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }
}
