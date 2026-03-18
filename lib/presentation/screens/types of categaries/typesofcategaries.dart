import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/singledescriptioncontroller.dart';
import 'package:pawlli/data/controller/subcategariescontroller.dart';
import 'package:pawlli/data/controller/typesofcategaries.dart';
import 'package:pawlli/data/model/subcategarymodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/descriptionpage/descriptionpage.dart';

class SeeAllPage extends StatefulWidget {
  const SeeAllPage({super.key});

  @override
  State<SeeAllPage> createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  final TextEditingController _searchController = TextEditingController();
  final AllCategoriesController allcategoryController =
      Get.put(AllCategoriesController());
  final AllSubCategoriesController subcategoryController =
      Get.put(AllSubCategoriesController());
  final SingleCategoriesController singleCategoryController =
      Get.put(SingleCategoriesController());

  int? selectedCategoryId;
  String selectedCategoryName = "";
  int? selectedSubCategoryId;
  String selectedSubCategoryName = "";
  bool isBrownBackground = true;

  List<Map<String, String>> allItems = [];
  List<Map<String, String>> filteredItems = [];
  List<SubCategoriesModel> filteredSubcategories = <SubCategoriesModel>[].obs;

  @override
  void initState() {
    super.initState();
    fetchAllCategories();
  }

  void fetchAllCategories() async {
    await allcategoryController.fetchAllCategories();

    setState(() {
      allItems = allcategoryController.allCategories
          .map((e) => {
                "image": e.image ?? "",
                "name": e.name ?? "Unknown",
                "id": e.categoryId?.toString() ?? "",
              })
          .toList();

      filteredItems = List.from(allItems);
    });

    if (allcategoryController.allCategories.isNotEmpty) {
      final firstCat = allcategoryController.allCategories.first;
      selectedCategoryId = firstCat.categoryId;
      selectedCategoryName = firstCat.name ?? "";

      await fetchSubCategories(firstCat.categoryId!);

      if (subcategoryController.allsubCategories.isNotEmpty) {
        final firstSub = subcategoryController.allsubCategories.first;
        selectedSubCategoryId = firstSub.subcategoryId;
        selectedSubCategoryName = firstSub.name ?? "";

        await fetchSingleCategory(firstSub.subcategoryId!);
      }
    }
  }

Future<void> fetchSubCategories(int categoryId) async {
  selectedSubCategoryId = null;
  selectedSubCategoryName = "";

  // 1️⃣ Load subcategories for selected category
  await subcategoryController.fetchAllsubCategories(categoryId);

  // 2️⃣ Clear old pets when category changes
  singleCategoryController.allPets.clear();
  singleCategoryController.singleCategories.clear();
  singleCategoryController.filteredCategories.clear();

  // 3️⃣ 🔥 BACKGROUND LOAD ALL PETS OF THIS CATEGORY
  final subIds = subcategoryController.allsubCategories
      .map((e) => e.subcategoryId!)
      .toList();

  singleCategoryController.loadAllPets(subIds);

  setState(() {});
}



  Future<void> fetchSingleCategory(int subCategoryId) async {
    try {
      await (singleCategoryController as dynamic).getCategories(subCategoryId);
    } catch (e) {
      try {
        await (singleCategoryController as dynamic)
            .fetchSingleCategories(subCategoryId);
      } catch (_) {
        print("fetchSingleCategory: controller method not found: $e");
      }
    }

    setState(() {});
  }

//  void _filterItems(String query) {
//   query = query.toLowerCase().trim();

//   if (query.isEmpty) {
//     singleCategoryController.filteredCategories
//         .assignAll(singleCategoryController.singleCategories);
//     return;
//   }

//   singleCategoryController.filteredCategories.assignAll(
//     singleCategoryController.singleCategories.where((pet) {
//       final petName = pet.name?.toLowerCase() ?? '';
//       final breedName = pet.subcategoryName?.toLowerCase() ?? '';
//       final petType = pet.categoryName?.toLowerCase() ?? '';
//       final location = pet.location?.toLowerCase() ?? '';
//       final gender = pet.gender?.toLowerCase() ?? '';
//       final likes = pet.preferences?.likes?.toLowerCase() ?? '';
//       final dislikes = pet.preferences?.dislikes?.toLowerCase() ?? '';

//       return petName.contains(query) ||
//           breedName.contains(query) ||
//           petType.contains(query) ||
//           location.contains(query) ||
//           gender.contains(query) ||
//           likes.contains(query) ||
//           dislikes.contains(query);
//     }).toList(),
//   );
// }


Widget _buildCategoryAvatar(
  String? imageUrl,
  double radius, {
  Color? bg,
}) {
  final bool isSelected = bg != null;

  return Container(
    padding: const EdgeInsets.all(3), // thickness of outer ring
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: isSelected
          ? Border.all(
              color: Colours.primarycolour, // ring color
              width: 2.5, // ring thickness
            )
          : null,
    ),
    child: CircleAvatar(
      radius: radius,
      backgroundColor: Colours.secondarycolour,
      backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
          ? NetworkImage(imageUrl)
          : null,
      child: (imageUrl == null || imageUrl.isEmpty)
          ? Icon(Icons.pets, color: Colours.primarycolour)
          : null,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: screenWidth * 0.65,
                  height: screenHeight * 0.12,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Assets.images.topimage.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.05,
                  left: screenWidth * 0.03,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colours.secondarycolour,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.055,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Make a Friend",
                      style: TextStyle(
                        color: Colours.brownColour,
                        fontFamily: FontFamily.Cairo,
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),


                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.10,
                    left: screenWidth * 0.047,
                    right: screenWidth * 0.047,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: Colours.textColour,
                        fontFamily: FontFamily.Cairo,
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon:
                          Icon(Icons.search, color: Colours.textColour, size: 30),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                            color: Colours.primarycolour, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                            color: Colours.primarycolour, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                            color: Colours.primarycolour, width: 1.0),
                      ),
                      filled: true,
                      fillColor: Colours.seachbarcolour,
                    ),
                    onChanged: singleCategoryController.searchPets,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Categories Title
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       " Categories",
            //       style: TextStyle(
            //         color: Colours.black,
            //         fontFamily: FontFamily.Cairo,
            //         fontSize: screenWidth * 0.09,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 7),

            // ---------------- Horizontal CATEGORIES ----------------
            SizedBox(
              height: screenWidth * 0.25 + 40,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                scrollDirection: Axis.horizontal,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final cat = allcategoryController.allCategories[index];
                  final catId = cat.categoryId;
                  final isSelected = selectedCategoryId == catId;

                  return GestureDetector(
                    onTap: () {
                      if (catId != null) {
                        setState(() {
                          selectedCategoryId = catId;
                          selectedCategoryName = item["name"] ?? "";
                          selectedSubCategoryId = null;
                          selectedSubCategoryName = "";
                        });
                        fetchSubCategories(catId);
                      }
                    },
                    child: Container(
                      width: screenWidth * 0.28,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCategoryAvatar(item["image"], screenWidth * 0.12,
                              bg: isSelected ? Colours.primarycolour : null),
                          const SizedBox(height: 6),
                            Text(
                              item["name"] ?? "",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: FontFamily.Cairo,
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.042, // 🔽 smaller for Android
                                color: Colours.brownColour,
                              ),
                            ),

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // const SizedBox(height: 15),

            // // Selected category title
            // if (selectedCategoryId != null)
            //   Padding(
            //     padding: const EdgeInsets.only(left: 12),
            //     child: Align(
            //       alignment: Alignment.centerLeft,
            //       child: Text(
            //         selectedCategoryName,
            //         style: TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //             fontFamily: FontFamily.Cairo),
            //       ),
            //     ),
            //   ),
            const SizedBox(height: 2),

            // ---------------- Horizontal SUB-CATEGORIES ----------------
            Obx(() {
        // ✅ ALWAYS show subcategories, even during search
        if (subcategoryController.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (subcategoryController.allsubCategories.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: Text("No subcategories found")),
          );
        }

        return SizedBox(
          height: screenWidth * 0.25 + 70,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            scrollDirection: Axis.horizontal,
            itemCount: subcategoryController.allsubCategories.length,
            itemBuilder: (context, index) {
              final sub = subcategoryController.allsubCategories[index];
              final isSelected = selectedSubCategoryId == sub.subcategoryId;

              return GestureDetector(
                onTap: () {
                  if (sub.subcategoryId != null) {
                    setState(() {
                      selectedSubCategoryId = sub.subcategoryId;
                      selectedSubCategoryName = sub.name ?? "";
                    });

                    // 🔥 Clear search when user taps subcategory
                    _searchController.clear();
                    singleCategoryController.isSearching.value = false;

                    fetchSingleCategory(sub.subcategoryId!);
                  }
                },
                child: Container(
                  width: screenWidth * 0.26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildCategoryAvatar(
                        sub.image,
                        screenWidth * 0.12,
                        bg: isSelected ? Colours.primarycolour : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        sub.name ?? "",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colours.brownColour,
                          fontFamily: FontFamily.Cairo,
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.042,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),

            // const SizedBox(height: 10),

            // // Selected subcategory title
            // if (selectedSubCategoryId != null)
            //   Padding(
            //     padding: const EdgeInsets.only(left: 12),
            //     child: Align(
            //       alignment: Alignment.centerLeft,
            //       child: Text(
            //         selectedSubCategoryName,
            //         style: TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //             fontFamily: FontFamily.Cairo,
            //             color: Colours.black),
            //       ),
            //     ),
            //   ),

            const SizedBox(height: 5),

            // ---------------- LIST of SINGLE CATEGORY ITEMS ----------------
            Obx(() {
              if (singleCategoryController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (singleCategoryController.singleCategories.isEmpty) {
                return Center(
                    child:
                        Text(singleCategoryController.errorMessage.value));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    singleCategoryController.filteredCategories.length,
                itemBuilder: (context, index) {
                  final category =
                      singleCategoryController.filteredCategories[index];
                  String backgroundImage = isBrownBackground
                      ? 'assets/images/browncard.png'
                      : 'assets/images/yellowcard.png';
                  isBrownBackground = !isBrownBackground;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.01,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        final petId = category.petId;
                        final petProfileImage = category.petProfileImage;
                        if (petId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DescriptionPage(
                                  petId: petId,
                                  petProfileImage: petProfileImage.toString()),
                            ),
                          );
                        } else {
                          Get.snackbar("Error", "Pet ID is missing.");
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: screenWidth,
                            height: screenHeight * 0.20,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(backgroundImage),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Positioned(
                            left: screenWidth * 0.05,
                            top: screenHeight * 0.02,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name ?? "Default Name",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.w600,
                                    color: Colours.secondarycolour,
                                  ),
                                ),
                                Text(
                                  category.ageDetails != null
                                      ? 'Age | ${category.ageDetails!.years}y ${category.ageDetails!.months}m ${category.ageDetails!.days}d'
                                      : (category.age != null
                                          ? 'Age | ${category.age}y'
                                          : 'Age | N/A'),
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: Colours.secondarycolour),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: screenWidth * 0.5,
                                  ),
                                  child: Text(
                                    category.description ??
                                        "Default Description",
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Colours.secondarycolour),
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: screenWidth * 0.06,
                                        color: Colours.secondarycolour),
                                    const SizedBox(width: 6),
                                    Text(
                                      category.location ?? "Default location",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          color: Colours.secondarycolour),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: screenWidth * 0.08,
                            bottom: screenHeight * 0.04,
                            child: (category.petProfileImage != null &&
                                    category.petProfileImage!.isNotEmpty)
                                ? CircleAvatar(
                                    radius: screenWidth * 0.13,
                                    backgroundImage: CachedNetworkImageProvider(
                                        category.petProfileImage!),
                                    backgroundColor: Colors.grey.shade200,
                                    onBackgroundImageError: (_, __) {},
                                  )
                                : CircleAvatar(
                                    radius: screenWidth * 0.13,
                                    backgroundColor: Colors.grey.shade300,
                                    child: Icon(
                                      Icons.pets,
                                      size: screenWidth * 0.15,
                                      color: Colours.primarycolour,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),

            SizedBox(height: screenHeight * 0.1),
          ],
        ),
      ),
    );
  }
}
