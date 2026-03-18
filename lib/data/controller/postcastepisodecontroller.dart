import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/podcastepisodemodel.dart' show Data;

class PodcastEpisodeController extends GetxController {
  var isLoading = false.obs;
  var episodes = <Data>[].obs;   // list of episodes
  var message = "".obs;

  // load episodes for a given podcastId
  Future<void> loadEpisodes(int podcastId) async {
    try {
      isLoading.value = true;
      final result = await ApiService.fetchPodcastEpisodeList(podcastId);

      if (result.isNotEmpty) {
        episodes.assignAll(result); // assign list directly
        message.value = "Episodes loaded successfully.";
      } else {
        message.value = "No episodes found.";
      }
    } finally {
      isLoading.value = false;
    }
  }
}
