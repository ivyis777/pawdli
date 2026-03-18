import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/recentpetchatmodel.dart';
class RecentPetChatController extends GetxController {
  var recentChats = <RecentPetChat>[].obs;
  var selectedPetId = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void setSelectedPet(String petId) {
    selectedPetId.value = petId;
    fetchRecentChatsForPet(petId);
  }

  Future<void> fetchRecentChatsForPet(String petId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final chats = await ApiService.fetchRecentPetChat(petId: petId);
      if (chats != null && chats.isNotEmpty) {
        recentChats.value = chats;
      } else {
        recentChats.clear();
        errorMessage.value = "No chats found.";
      }
    } catch (e) {
      recentChats.clear();
      errorMessage.value = "Failed to load chats: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshChats() async {
    if (selectedPetId.isNotEmpty) {
      await fetchRecentChatsForPet(selectedPetId.value);
    }
  }
}
