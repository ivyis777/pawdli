import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/programlistmodel.dart';

class ProgramController extends GetxController {
  var isLoading = false.obs;
  var programList = Rxn<ProgramListModel>();

  // ✅ Custom getter to return List<Data> from the ProgramListModel's data
  List<Data> get programDataList => programList.value?.data ?? [];

  Future<void> loadProgramList(int userId, int radioId, String date) async {
    isLoading.value = true;
    try {
      var result = await ApiService.fetchProgramList(userId, radioId, date);
      if (result != null) {
        programList.value = result;
      } else {
        programList.value = null; // Handle API failure case
      }
    } catch (e) {
      print("❌ Error in ProgramController: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
