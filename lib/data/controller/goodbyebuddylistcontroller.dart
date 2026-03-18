import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/app url.dart';
import 'package:pawlli/data/model/goodbyebuddylistmodel.dart';

class GoodbyeRequestDetailsController extends GetxController {

  final box = GetStorage();

  var isLoading = false.obs;

  var requestDetails = Rxn<GoodbyeRequestDetailsModel>();

  Future<void> fetchRequestDetails(int requestId) async {

    try {

      isLoading.value = true;

      final response = await http.get(
        Uri.parse(AppUrl.GoodByeBuddyListUrl),
        headers: {
          "Authorization":
              "Bearer ${box.read(LocalStorageConstants.access)}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);
        print(response.body);

        final List list = data["data"];

        /// find selected request
        final request = list.firstWhere(
          (r) => r["id"] == requestId,
          orElse: () => {},
        );

        if (request.isNotEmpty) {

          requestDetails.value =
              GoodbyeRequestDetailsModel.fromJson(request);
        }
      }

    } catch (e) {

      print("Details fetch error: $e");

    } finally {

      isLoading.value = false;
    }
  }
}