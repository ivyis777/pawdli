// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pawlli/core/storage_manager/colors.dart';
// import 'package:pawlli/data/controller/singledescriptioncontroller.dart';
// import 'package:pawlli/gen/assests.gen.dart';
// import 'package:pawlli/gen/fonts.gen.dart';
// import 'package:pawlli/presentation/screens/descriptionpage/descriptionpage.dart';

// class SingleCategories extends StatefulWidget {
//   final int subcategoryId;
//   const SingleCategories({super.key, required this.subcategoryId});

//   @override
//   State<SingleCategories> createState() => _SingleCategoriesState();
// }

// class _SingleCategoriesState extends State<SingleCategories> {
//   final TextEditingController _searchController = TextEditingController();
//   final SingleCategoriesController _controller = Get.put(SingleCategoriesController());
//   bool isBrownBackground = true;

//   @override
//   void initState() {
//     super.initState();
//     _controller.getCategories(widget.subcategoryId);
//   }

//   void _filterItems(String query) {

//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
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
//                       left: screenWidth * 0.047,
//                       right: screenWidth * 0.047),
//                   child: TextField(
//   controller: _searchController,
//   decoration: InputDecoration(
//     hintText: 'Search',
//     hintStyle: TextStyle( 
//       color: Colours.textColour,
//       fontFamily: FontFamily.Cairo,
//       fontSize: screenWidth * 0.05,
//       fontWeight: FontWeight.w600,
//     ),
//     prefixIcon: Icon(Icons.search, color: Colours.black, size: 30),
//     contentPadding: EdgeInsets.symmetric(vertical: 22.0, horizontal: 15.0),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25),
//       borderSide: BorderSide(color: Colours.primarycolour, width: 1.0),
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25),
//       borderSide: BorderSide(color: Colours.primarycolour, width: 1.0),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(25),
//       borderSide: BorderSide(color: Colours.primarycolour, width: 1.0),
//     ),
//     filled: true,
//     fillColor: Colours.seachbarcolour,
//   ),
//   onChanged: (query) => _controller.filterCategories(query),
// ),

//                 ),
//               ],
//             ),
            
//            Obx(() {
//   if (_controller.isLoading.value) {
//     return Center(child: CircularProgressIndicator());
//   }

//   if (_controller.singleCategories.isEmpty) {
//     return Center(child: Text(_controller.errorMessage.value));
//   }

//   return ListView.builder(
//     shrinkWrap: true,
//     physics: NeverScrollableScrollPhysics(),
//     itemCount: _controller.filteredCategories.length, 
//     itemBuilder: (context, index) {
//       final category = _controller.filteredCategories[index]; 
//       String backgroundImage = isBrownBackground
//           ? 'assets/images/browncard.png'
//           : 'assets/images/yellowcard.png';
//       isBrownBackground = !isBrownBackground;

//       return Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: screenWidth * 0.05,
//           vertical: screenHeight * 0.01,
//         ),
//         child: GestureDetector(
//           onTap: () {
//             final petId = category.petId;
//             final petProfileImage = category.petProfileImage;
//             if (petId != null) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => DescriptionPage(petId: petId, petProfileImage: petProfileImage.toString()),
//                 ),
//               );
//             } else {
//               Get.snackbar("Error", "Pet ID is missing.");
//             }
//           },
//           child: Stack(
//             children: [
//               Container(
//                 width: screenWidth,
//                 height: screenHeight * 0.20,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(backgroundImage),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: screenWidth * 0.05,
//                 top: screenHeight * 0.02,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       category.name ?? "Default Name",
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.06,
//                         fontWeight: FontWeight.w600,
//                         color: Colours.secondarycolour,
//                       ),
//                     ),
//                     Text(
//   category.ageDetails != null
//     ? 'Age | ${category.ageDetails!.years}y ${category.ageDetails!.months}m ${category.ageDetails!.days}d'
//     : (category.age != null
//         ? 'Age | ${category.age}y'
//         : 'Age | N/A'),
//   style: TextStyle(fontSize: screenWidth * 0.04, color: Colours.secondarycolour),
// ),

//                     ConstrainedBox(
//                       constraints: BoxConstraints(
//                         maxWidth: screenWidth * 0.5, 
//                       ),
//                       child: Text(
//                         category.description ?? "Default Description",
//                         style: TextStyle(fontSize: screenWidth * 0.04, color: Colours.secondarycolour),
//                         softWrap: true,
//                       overflow: TextOverflow.ellipsis,
//           maxLines: 2,
//                       ),
//                     ),
                     

//                     Row(
//                       children: [Icon(Icons.location_on, size: screenWidth * 0.06, color: Colours.secondarycolour),
//                         const SizedBox(width: 6),
//                         Text(
//                         category.location ?? "Default location",
//                            overflow: TextOverflow.ellipsis,
//                                 maxLines: 1,
//                         style: TextStyle(fontSize: screenWidth * 0.04, color: Colours.secondarycolour),
//                       ),
//                   ]),
//                   ],
//                 ),
//               ),
//             Positioned(
//   right: screenWidth * 0.08,
//   bottom: screenHeight * 0.04,
//   child: (category.petProfileImage != null && category.petProfileImage!.isNotEmpty)
//       ? CircleAvatar(
//           radius: screenWidth * 0.13,
//           backgroundImage: CachedNetworkImageProvider(category.petProfileImage!),
//           backgroundColor: Colors.grey.shade200,
//           onBackgroundImageError: (_, __) {}, // still safe
//         )
//       : CircleAvatar(
//           radius: screenWidth * 0.13,
//           backgroundColor: Colors.grey.shade300,
//           child: Icon(
//             Icons.pets, // 🐾 fallback
//             size: screenWidth * 0.1,
//             color: Colours.secondarycolour,
//           ),
//         ),
// ),

//             ],
//           ),
//         ),
//       );
//     },
//   );
// }),

//             SizedBox(height: screenHeight * 0.2),
//           ],
//         ),
//       ),
//     );
//   }
// }
