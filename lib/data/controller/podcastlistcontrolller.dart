import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/podcastlistmodel.dart';


class PodcastListController extends GetxController {
  var isLoading = false.obs;
  var podcasts = <PodcastData>[].obs; // ✅ store actual podcast items (Data)
  var message = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadPodcasts();
  }

Future<void> loadPodcasts() async {
  try {
    isLoading.value = true;
    final result = await ApiService.fetchPodcastList(); // List<Data>

    podcasts.assignAll(result.cast<PodcastData>()); // ✅ force type
    message.value = result.isNotEmpty ? "Podcasts loaded successfully." : "No podcasts found.";
  } catch (e) {
    message.value = "Failed to load podcasts.";
  } finally {
    isLoading.value = false;
  }
}

}