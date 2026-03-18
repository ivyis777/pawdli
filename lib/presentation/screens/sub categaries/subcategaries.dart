// import 'package:flutter/material.dart';
// import 'package:pawlli/core/storage_manager/colors.dart';
// import 'package:pawlli/data/controller/subcategariescontroller.dart';
// import 'package:pawlli/gen/assests.gen.dart';
// import 'package:pawlli/gen/fonts.gen.dart';
// import 'package:get/get.dart';
// import 'package:pawlli/presentation/screens/singlecategaries/singlecategaries.dart';
// import 'package:cached_network_image/cached_network_image.dart';





// class SubcategariesPage extends StatefulWidget {
//   final int categoryId;
//   const SubcategariesPage({super.key, required this.categoryId});

//   @override
//   State<SubcategariesPage> createState() => _SubcategariesPageState();
// }

// class _SubcategariesPageState extends State<SubcategariesPage> {
//   final TextEditingController _searchController = TextEditingController();
//   final AllSubCategoriesController allsubcategoryController = Get.put(AllSubCategoriesController());

//   List<String> categoryNames = []; 
//   List<Map<String, String>> filteredItems = [];
//   bool isLoading = false; 
//   String errorMessage = ''; 

//   @override
//   void initState() {
//     super.initState();
//     fetchAllSubCategories();
//   }

//   @override
//   void didUpdateWidget(covariant SubcategariesPage oldWidget) {
//     super.didUpdateWidget(oldWidget);
    
//     if (oldWidget.categoryId != widget.categoryId) {
//       fetchAllSubCategories();
//     }
//   }

//   void fetchAllSubCategories() async {
//     setState(() {
//       isLoading = true;
//       filteredItems.clear();
//       errorMessage = '';
//     });

//     try {
//       await allsubcategoryController.fetchAllsubCategories(widget.categoryId);

//       if (allsubcategoryController.allsubCategories.isEmpty) {
//         setState(() {
//           errorMessage = "No subcategories found.";
//         });
//       } else {
//         setState(() {
//           filteredItems = allsubcategoryController.allsubCategories
//               .map((e) => {
//                     "image": e.image ?? "",
//                     "name": e.name ?? "Unknown",
//                     "id": e.subcategoryId?.toString() ?? "",
//                   })
//               .toList();
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = "Error fetching subcategories: $e";
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

// void _filterItems(String query) {
//   final lowerQuery = query.toLowerCase();
//   setState(() {
//     filteredItems = allsubcategoryController.allsubCategories
//         .where((e) => (e.name ?? "").toLowerCase().contains(lowerQuery))
//         .map((e) => {
//               "image": e.image ?? "",
//               "name": e.name ?? "Unknown",
//               "id": e.subcategoryId?.toString() ?? "",
//             })
//         .toList();
//   });
// }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     double horizontalPadding = screenWidth * 0.047;
//     double verticalPadding = screenHeight * 0.065;

//     final crossAxisCount = screenWidth < 600
//         ? 3
//         : screenWidth < 900
//             ? 3
//             : 4;

//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               children: [
//                 Container(
//                   width: screenWidth * 0.65,
//                   height: screenHeight * 0.12,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage(Assets.images.topimage.path),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                  Positioned(
//                   top: screenHeight * 0.04,
//                   left: screenWidth * 0.03,
//                   child: IconButton(
//                     icon: Icon(Icons.arrow_back, color: Colours.secondarycolour, size: 30),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(
//                       top: screenHeight * 0.08,
//                       left: horizontalPadding,
//                       right: horizontalPadding),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search',
//                       hintStyle: TextStyle(
//                         color: Colours.textColour,
//                         fontFamily: FontFamily.Cairo,
//                         fontSize: screenWidth * 0.05,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       prefixIcon: Icon(
//                         Icons.search,
//                         color: Colours.black,
//                         size: 30,
//                       ),
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 22.0, horizontal: 15.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide(
//                           color: Colours.primarycolour,
//                           width: 1.0,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide(
//                           color: Colours.primarycolour,
//                           width: 1.0,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide(
//                           color: Colours.primarycolour,
//                           width: 1.0,
//                         ),
//                       ),
//                       filled: true,
//                       fillColor: Colours.seachbarcolour,
//                     ),
//                     onChanged: (query) {
//                       _filterItems(query);
//                     },
//                   ),
//                 ),
//               ],
//             ),
            
//         Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     " Sub Categories",
//                     style: TextStyle(
//                       color: Colours.black,
//                       fontFamily: FontFamily.Cairo,
//                       fontSize: screenWidth * 0.09,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
                 
//                 ],
//               ),
         
//          Padding(
//               padding: const EdgeInsets.only(left: 5.0,right: 5.0),
//               child: GridView.builder(
//   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//     crossAxisCount: crossAxisCount,
//     crossAxisSpacing: 9.0,
//     mainAxisSpacing: 12.0,
//     childAspectRatio: 0.75, 
//   ),
//   itemCount: filteredItems.length,
//   shrinkWrap: true,
//   physics: NeverScrollableScrollPhysics(),
//   itemBuilder: (context, index) {
//     final item = filteredItems[index];
    
//     return GestureDetector(
//       onTap: () {
//    final selectedCategory = allsubcategoryController.allsubCategories[index];
//   final subcategoryId = selectedCategory.subcategoryId; 
//       if (subcategoryId != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SingleCategories(subcategoryId: subcategoryId),
//           ),
//         );
//       } else {
//         // Handle error or show a message if subcategoryId is missing
//         print('Subcategory ID is missing or null');
//       }
//       },
//       child: Container(
//         margin: EdgeInsets.all(4),
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // Important for GridView items
//           children: [
//             // Image Container with fixed height
//             Container(
//               height: screenHeight * 0.12, // Reduced height
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage(Assets.images.homeapagebg.path),
              
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             child: Stack(
//   alignment: Alignment.center,
//   children: [
//     // Optional background circle / border
//     Container(
//       width: screenWidth * 0.32,
//       height: screenWidth * 0.32,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(color: Colours.primarycolour, width: 2),
//         color: Colours.seachbarcolour,
//       ),
//     ),
//     // Circular avatar with image
//    CircleAvatar(
//   radius: screenWidth * 0.16,
//   backgroundColor: Colors.transparent,
//   child: ClipOval(
//     child: SizedBox(
//       width: screenWidth * 0.32,
//       height: screenWidth * 0.32,
//       child: CachedNetworkImage(
//         imageUrl: item["image"] ?? "",
//         fit: BoxFit.cover,
//         placeholder: (context, url) => Center(
//           child: SizedBox(
//             width: screenWidth * 0.08,
//             height: screenWidth * 0.08,
//             child: CircularProgressIndicator(strokeWidth: 2),
//           ),
//         ),
//         errorWidget: (context, url, error) => Icon(
//           Icons.pets,
//           size: screenWidth * 0.1,
//           color: Colours.secondarycolour,
//         ),
//       ),
//     ),
//   ),
// )
//   ],
// ),

//             ),
//             // Spacer between image and text
//             // Text Container with constraints
//             Container(
//               constraints: BoxConstraints(
//                 maxWidth: screenWidth * 0.25, // Constrain text width
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 4),
//               child: Text(
//                 item["name"]!,
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: Colours.brownColour,
//                   fontFamily: FontFamily.Cairo,
//                   fontSize: screenWidth * 0.040, // Slightly smaller font
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   },
// )
//             ),
//     ])));
//   }
// }
