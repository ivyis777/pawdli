import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/descriptionmodel.dart';

class PetController extends GetxController {
  var isLoading = false.obs; 
  var petDescription = Rx<PetDescription?>(null);  
 
  void fetchPetDescription(int petId) async {
  try {
    isLoading(true);
    petDescription.value = null; 
    
    final result = await ApiService.fetchPetDescription(petId);

    if (result != null) {
      petDescription.value = result;
      print("Pet description loaded successfully");
    } else {
      print("Failed to fetch pet description (null response)");
    }
  } catch (e) {
    print('Error fetching pet: $e');
  } finally {
    isLoading(false); 
  }
}

}
