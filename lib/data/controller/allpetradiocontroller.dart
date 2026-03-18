import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/allpetradiomodel.dart';

class AllPetRadioController extends GetxController {
  var allPetRadioModel = AllPetRadioModel().obs; // Stores full model
  var petRadioList = <Data>[].obs; // Stores only data list
  var isLoading = false.obs;

  void fetchRadioStations() async {
    try {
      isLoading.value = true;
      final response = await ApiService.fetchAllPetRadio();
      if (response != null) {
        allPetRadioModel.value = response; 
        petRadioList.value = response.data ?? []; 
      }
    } catch (e) {
      print("Error fetching radio stations: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

