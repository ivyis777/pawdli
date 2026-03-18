// import 'package:flutter/material.dart';
// import 'package:pawlli/core/storage_manager/colors.dart';
// import 'package:pawlli/gen/assests.gen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AddAddressPage extends StatefulWidget {
//   const AddAddressPage({super.key});

//   @override
//   State<AddAddressPage> createState() => _AddAddressPageState();
// }

// class _AddAddressPageState extends State<AddAddressPage> {
//   // Controllers
//   final nameController = TextEditingController();
//   final mobileController = TextEditingController();
//   final address1Controller = TextEditingController();
//   final address2Controller = TextEditingController();
//   final pinController = TextEditingController();

//   String? selectedState;
//   String? selectedCity;

//   // Save address and return to CartPage
//   Future<void> _saveAddress() async {
//     final prefs = await SharedPreferences.getInstance();

//     final newAddress =
//         "${nameController.text}, ${address1Controller.text}, ${address2Controller.text}, ${selectedCity ?? ""}, ${selectedState ?? ""}, ${pinController.text}";

//     List<String> savedAddresses = prefs.getStringList("addresses") ?? [];
//     savedAddresses.add(newAddress);
//     await prefs.setStringList("addresses", savedAddresses);

//     Navigator.pop(context, newAddress);
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
         
//           Stack(
//             children: [
//               Container(
//                 width: screenWidth * 0.55,
//                 height: screenHeight * 0.10,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(Assets.images.topimage.path),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               AppBar(
//                 title: Text(
//                   'Add Address',
//                   style: TextStyle(
//                     fontSize: screenHeight * 0.03,
//                     fontWeight: FontWeight.w600,
//                     color: Colours.brownColour,
//                   ),
//                 ),
//                 centerTitle: true,
//                 foregroundColor: Colours.brownColour,
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//               ),
//             ],
//           ),

//           // Form
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 _buildFieldWithHeading("Full Name", "Name", nameController),
//                 _buildFieldWithHeading("Mobile Number", "Number", mobileController),
//                 _buildFieldWithHeading("Address 1", "Street, Building", address1Controller),
//                 _buildFieldWithHeading("Address 2", "Apartment, Suite", address2Controller),
//                 _buildFieldWithHeading("Pin Code", "Zip / Postal Code", pinController),

//                 const SizedBox(height: 12),
//                 Text("State",
//                     style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colours.textColour)),
//                 const SizedBox(height: 6),
//                 DropdownButtonFormField<String>(
//                   value: selectedState,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colours.primarycolour, width: 2),
//                     ),
//                   ),
//                   items: const [
//                     DropdownMenuItem(value: "CA", child: Text("California")),
//                     DropdownMenuItem(value: "NY", child: Text("New York")),
//                   ],
//                   onChanged: (value) => setState(() => selectedState = value),
//                 ),

//                 const SizedBox(height: 12),
//                 Text("City",
//                     style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colours.textColour)),
//                 const SizedBox(height: 6),
//                 DropdownButtonFormField<String>(
//                   value: selectedCity,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colours.primarycolour, width: 2),
//                     ),
//                   ),
//                   items: const [
//                     DropdownMenuItem(value: "LA", child: Text("Los Angeles")),
//                     DropdownMenuItem(value: "NYC", child: Text("New York City")),
//                   ],
//                   onChanged: (value) => setState(() => selectedCity = value),
//                 ),
//               ],
//             ),
//           ),

//           // Save Button
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: ElevatedButton(
//               onPressed: _saveAddress,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colours.primarycolour,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//               ),
//               child: const Text("SAVE",
//                   style: TextStyle(color: Colors.white, fontSize: 16)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFieldWithHeading(String label, String hint, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label,
//               style: TextStyle(
//                   fontSize: 14, fontWeight: FontWeight.w500, color: Colours.textColour)),
//           const SizedBox(height: 6),
//           Card(
//             color: Colours.secondarycolour,
//             child: TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: hint,
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colours.textColour, width: 2)),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colours.primarycolour, width: 2),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
