import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/singledescriptionmodel.dart';

class SingleCategoriesController extends GetxController {
  /// 🔒 All pets from all subcategories
  final allPets = <SingleCategoryModel>[];

  /// Pets of selected subcategory
  var singleCategories = <SingleCategoryModel>[].obs;

  /// UI list
  var filteredCategories = <SingleCategoryModel>[].obs;

  var isSearching = false.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isAllPetsLoaded = false.obs;


  /// Fetch pets of ONE subcategory (used on tap)
  Future<void> getCategories(int subcategoryId) async {
    isLoading(true);
    errorMessage.value = '';

    try {
      final response = await ApiService.fetchCategories(subcategoryId);
print("ALL PETS COUNT: ${allPets.length}");

      if (response.isNotEmpty) {
        singleCategories.assignAll(response);

        /// add to global list (avoid duplicates)
        for (final pet in response) {
          if (!allPets.any((p) => p.petId == pet.petId)) {
            allPets.add(pet);
          }
        }

        if (!isSearching.value) {
          filteredCategories.assignAll(singleCategories);
        }
      } else {
        singleCategories.clear();
        filteredCategories.clear();
        errorMessage.value = 'No Friends available';
      }
    } catch (_) {
      errorMessage.value = 'Failed to fetch pets';
    } finally {
      isLoading(false);
    }
  }

  /// 🔥 LOAD ALL SUBCATEGORIES IN BACKGROUND (KEY FIX)
  Future<void> loadAllPets(List<int> subcategoryIds) async {
    isAllPetsLoaded.value = false;

    await Future.wait(
      subcategoryIds.map((id) async {
        try {
          final response = await ApiService.fetchCategories(id);
          for (final pet in response) {
            if (!allPets.any((p) => p.petId == pet.petId)) {
              allPets.add(pet);
            }
          }
        } catch (_) {}
      }),
    );

    isAllPetsLoaded.value = true;
  }

  Future<Position> getUserLocation() async {
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

double distanceInKm(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
}



  /// 🔍 GLOBAL SEARCH
  Future<void> searchPets(String query) async {
    if (!isAllPetsLoaded.value) return;

    query = query.toLowerCase().trim();

    if (query.isEmpty) {
      isSearching.value = false;
      filteredCategories.assignAll(singleCategories);
      return;
    }

    isSearching.value = true;

    // 🔥 Detect "near me"
    final isNearMe = query.contains('near');

    Position? userPos;
    if (isNearMe) {
      userPos = await getUserLocation();
    }

    final results = <SingleCategoryModel>[];

    for (final pet in allPets) {
      final textMatch =
          fuzzyMatch(pet.name ?? '', query) ||
          fuzzyMatch(pet.subcategoryName ?? '', query) ||
          fuzzyMatch(pet.categoryName ?? '', query) ||
          fuzzyMatch(pet.location ?? '', query);

      if (!isNearMe && textMatch) {
        results.add(pet);
      }

      if (isNearMe && textMatch) {
        try {
          final locations =
              await locationFromAddress(pet.location ?? '');
          if (locations.isEmpty) continue;

          final petLoc = locations.first;
          final km = distanceInKm(
            userPos!.latitude,
            userPos.longitude,
            petLoc.latitude,
            petLoc.longitude,
          );

          if (km <= 30) {
            results.add(pet);
          }
        } catch (_) {}
      }
    }

    filteredCategories.assignAll(results);
  }
}

String _normalize(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .trim();
}

/// Simple fuzzy match (allows small typos)
bool fuzzyMatch(String source, String query) {
  source = _normalize(source);
  query = _normalize(query);

  if (source.contains(query)) return true;

  int mismatches = 0;
  int minLen = source.length < query.length ? source.length : query.length;

  for (int i = 0; i < minLen; i++) {
    if (source[i] != query[i]) mismatches++;
    if (mismatches > 2) return false; // tolerance
  }

  return true;
}
