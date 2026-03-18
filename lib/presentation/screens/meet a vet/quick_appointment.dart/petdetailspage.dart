import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/confirmslot.dart';
import 'package:pawlli/presentation/screens/meet%20a%20vet/quick_appointment.dart/symptomspage.dart';


class PetDetailsPage extends StatefulWidget {
  const PetDetailsPage({super.key});

  @override
  State<PetDetailsPage> createState() => _PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> {
  // The currently selected value for the dropdowns
  String _selectedValue = 'Self';
  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'A+';
  String _selectedRelationship = 'Self';

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles;

  Future<void> _pickImage() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imageFiles = pickedFiles;
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _imageFiles = [...?_imageFiles, photo];
      });
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Image Source",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.Cairo,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colours.primarycolour,
        centerTitle: true,
        foregroundColor: Colours.brownColour,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedValue,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.Cairo,
                  color: Colours.black,
                ),
              ),
              const SizedBox(width: 8.0),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return _selectedValue == 'Self'
                      ? [
                          const PopupMenuItem<String>(
                            value: 'Other',
                            child: Text("Other"),
                          ),
                        ]
                      : [
                          const PopupMenuItem<String>(
                            value: 'Self',
                            child: Text("Self"),
                          ),
                        ];
                },
                icon: Icon(Icons.arrow_drop_down, color: Colours.black),
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colours.secondarycolour,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedValue == 'Self') ...[
                Text(
                  "Pet Details:",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w500,
                    fontFamily: FontFamily.Cairo,
                    color: Colours.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Card(
                  color: Colours.secondarycolour,
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Patient Name:', 'Rakesh Kumar K'),
                        const SizedBox(height: 8.0),
                        _buildDetailRow('Age:', '24 Years'),
                        const SizedBox(height: 8.0),
                        _buildDetailRow('Doctor:', 'Dr. Chomon Aktar'),
                      ],
                    ),
                  ),
                ),
              ],
              if (_selectedValue == 'Other') ...[
                // Full Name
                Text(
                  "Name:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: FontFamily.Cairo,
                    color: Colours.black,
                  ),
                ),
                const SizedBox(height: 5.0),
                _buildTextFieldCard(
                    controller: _fullNameController,
                    hintText: "Enter Pet Name"),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFieldCard(
                        controller: _ageController,
                        hintText: "Enter Age",
                        label: "Age:",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownCard(
                        value: _selectedGender,
                        label: "Gender:",
                        items: ['Male', 'Female', 'Other'],
                        onChanged: (value) =>
                            setState(() => _selectedGender = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownCard(
                        value: _selectedBloodGroup,
                        label: "Blood Group:",
                        items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                        onChanged: (value) =>
                            setState(() => _selectedBloodGroup = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                  ],
                ),
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: _showImageSourceOptions,
                child: Text(
                  "Upload Image",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w500,
                   fontFamily: FontFamily.Cairo,
                    color: Colours.black,
                  ),
                ),
                
              ),
           
              Container(
                width: screenWidth,
                height: 10,
                color: Colours.secondarycolour,
              ),
             
if (_imageFiles != null && _imageFiles!.isNotEmpty)
  Column(
    children: [
      SizedBox(
        height: screenHeight * 0.25,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _imageFiles!.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.02),
                  child: Image.file(
                    File(_imageFiles![index].path),
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.2,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colours.brownColour),
                    onPressed: () => _removeImage(index),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ],
  ),

// 👇 always visible

SymptomWidget(),


              const SizedBox(height: 30),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 500,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: Colours.primarycolour,
                    ),
                    onPressed: () {
                             Get.to(ReviewandpayPage()); 
                    },
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colours.secondarycolour,
                        fontFamily: FontFamily.Ubantu,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
                fontFamily: FontFamily.Cairo,
                    color: Colours.black,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
               fontFamily: FontFamily.Cairo,
                    color: Colours.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldCard(
      {required TextEditingController controller,
      required String hintText,
      String? label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
                fontFamily: FontFamily.Cairo,
                    color: Colours.black,
            ),
          ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 65.0,
          child: Card(
            color: Colours.secondarycolour,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: FontFamily.Cairo,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownCard({
    required String value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: FontFamily.Cairo,
                    color: Colours.black,
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 60.0,
          child: Card(
            color: Colours.secondarycolour,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: DropdownButton<String>(
                value: value,
                onChanged: onChanged,
                items: items
                    .map((item) =>
                        DropdownMenuItem<String>(value: item, child: Text(item)))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
