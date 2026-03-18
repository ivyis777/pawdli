import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart' as storage;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/createpetcontroller.dart';
import 'package:pawlli/data/controller/subcategariescontroller.dart';
import 'package:pawlli/data/controller/typesofcategaries.dart';
import 'package:pawlli/data/model/subcategarymodel.dart' show Data;
import 'package:pawlli/data/model/typesofcategaries.dart' as cat_model;
import 'package:toggle_switch/toggle_switch.dart';
import 'dart:io';
import 'package:get/get.dart';

class AddPetPage extends StatefulWidget {
  @override
  _AddPetPageState createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _LocationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController(); // Height controller
  TextEditingController _microchipController = TextEditingController();
  String _selectedCountryCode = '+91'; // default to India
TextEditingController _phoneController = TextEditingController();

  final AllCategoriesController _categoryController = Get.put(AllCategoriesController());
  final AllSubCategoriesController subCategoryController = Get.put(AllSubCategoriesController());
   final CreatePetController petController = Get.put(CreatePetController());
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _profileImage; // Correct


int? _compressedSize;
 String? _compressedSizeText; 
 String? _selectedType;
int? _selectedCategoryId;

String? _selectedSubcategoryId ;
    String? _selectedBreed ;
    int? userId;
      String? _apiFormattedDate; 
  String? _selectedGender = 'Male';
  String? _isSpayed = 'No';
DateTime today = DateTime.now();


@override
void initState() {
  super.initState();
        final box = storage.GetStorage();
  userId ??= box.read(LocalStorageConstants.userId); 
  WidgetsBinding.instance.addPostFrameCallback((_) {
  // Fetch categories from API
 
    _selectedType = null;
  _selectedBreed = null;
  _selectedSubcategoryId = null;
  subCategoryController.allsubCategories.clear();
  subCategoryController.errorMessage('');
  subCategoryController.isLoading(false);
   _categoryController.fetchAllCategories(); });
}
Future<File?> _compressImage(File file) async {
  final targetPath =
      '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

  XFile? result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 70,
  );

  if (result != null) {
    final compressedFile = File(result.path);

    // ✅ Calculate compressed file size
    final bytes = await compressedFile.length();
    final kb = (bytes / 1024).toStringAsFixed(2);
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);

    print("📉 Compressed File Size: $kb KB ($mb MB)");

    // Store size if you want to show in UI
    setState(() {
      // _compressedSizeText = "$kb KB"; // 👈 declare String? _compressedSizeText in state
    });

    return compressedFile;
  }

  return null;
}
Future<File?> _cropImage(File imageFile) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),

    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colours.primarycolour,
        toolbarWidgetColor: Colors.white,
        cropStyle: CropStyle.circle, // ✅ CIRCLE CROP (Android)
        hideBottomControls: true,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
        title: 'Crop Image',
        aspectRatioLockEnabled: true,
      ),
    ],
  );

  if (croppedFile == null) return null;
  return File(croppedFile.path);
}



Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();

  showModalBottomSheet(
    context: context,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Picture'),
              onTap: () async {
                Navigator.pop(sheetContext); // ✅ CLOSE SHEET FIRST

                final XFile? image =
                    await picker.pickImage(source: ImageSource.camera);

                if (image == null) return;

                final File? compressed =
                    await _compressImage(File(image.path));

                if (compressed == null) return;

                final File? cropped = await _cropImage(compressed);

                if (cropped != null) {
                  setState(() {
                    _profileImage = cropped; // ✅ CROPPED IMAGE SAVED
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Upload from Gallery'),
              onTap: () async {
                Navigator.pop(sheetContext); // ✅ CLOSE SHEET FIRST

                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);

                if (image == null) return;

                final File? compressed =
                    await _compressImage(File(image.path));

                if (compressed == null) return;

                final File? cropped = await _cropImage(compressed);

                if (cropped != null) {
                  setState(() {
                    _profileImage = cropped; // ✅ CROPPED IMAGE SAVED
                  });
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _selectDate(BuildContext context) async {
  // Get today's date without time (00:00:00)
  DateTime today = DateTime.now();
  DateTime onlyDate = DateTime(today.year, today.month, today.day);

  // Set initial and last date to today
  DateTime initialDate = onlyDate;
  DateTime lastDate = onlyDate;
  DateTime firstDate = DateTime(1900); // or any custom minimum date

  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData(
          primaryColor: Colours.primarycolour,
          colorScheme: ColorScheme.light(
            primary: Colours.primarycolour,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colours.primarycolour,
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (pickedDate != null) {
    final formattedDate = "${pickedDate.year}-"
        "${pickedDate.month.toString().padLeft(2, '0')}-"
        "${pickedDate.day.toString().padLeft(2, '0')}";

    setState(() {
      _birthdayController.text = formattedDate;
      _apiFormattedDate = formattedDate;
    });
  }
}

Widget _buildTextField(
  String label,
  TextEditingController controller, {
  Widget? suffixIcon,
  bool requireValidation = true,
  bool readOnly = false,           // 👈 add readOnly
  VoidCallback? onTap,             // 👈 add onTap
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: TextFormField(
      controller: controller,
      readOnly: readOnly,          // 👈 apply readOnly
      onTap: onTap,                // 👈 apply onTap
      validator: (value) {
        if (requireValidation && (value == null || value.trim().isEmpty)) {
          return 'Please enter this field';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colours.brownColour,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colours.primarycolour),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
      ),
    ),
  );
}


Widget _buildTypeDropdown() {
  return Obx(() {
    if (_categoryController.isLoading.value) {
      return const CircularProgressIndicator();
    }

    final categories = _categoryController.allCategories;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: _selectedType,  // should be null initially for validation to work properly
        hint: const Text('Select Type'),
        items: categories.map((cat_model.Data category) {
          return DropdownMenuItem<String>(
            value: category.name,
            child: Text(category.name ?? ''),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedType = newValue;
            _selectedBreed = null;
            _selectedSubcategoryId = null;
            subCategoryController.allsubCategories.clear();
            subCategoryController.errorMessage('');
          });

          final selectedCategory = categories.firstWhere(
            (cat_model.Data category) => category.name == newValue,
            orElse: () => cat_model.Data(),
          );

          if (selectedCategory.categoryId != null) {
            _selectedCategoryId = selectedCategory.categoryId;
            Future.microtask(() {
              subCategoryController.fetchAllsubCategories(_selectedCategoryId!);
            });
          }
        },
        decoration: InputDecoration(
          labelText: 'Select Type',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colours.primarycolour, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colours.primarycolour, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a Type';
          }
          return null;
        },
      ),
    );
  });
}


Widget _buildBreedDropdown() {
  return Obx(() {
    final breedList = subCategoryController.allsubCategories;

    if (breedList.isEmpty) {
      return DropdownButtonFormField<String>(
        items: [],
        onChanged: null,
        decoration: InputDecoration(
          labelText: 'Select Breed',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedBreed?.isNotEmpty == true ? _selectedBreed : null,
      items: breedList.map<DropdownMenuItem<String>>((e) {
        return DropdownMenuItem<String>(
          value: e.name,
          child: Text(e.name ?? ''),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedBreed = newValue;

          final selected = breedList.firstWhere(
            (e) => e.name == newValue,
            orElse: () => Data(),
          );
          _selectedSubcategoryId = selected.subcategoryId.toString();
        });
      },
      decoration: InputDecoration(
        labelText: 'Select Breed',
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.brown,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colours.primarycolour, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colours.primarycolour, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a Breed';
        }
        return null;
      },
    );
  });
}


  Widget _buildGenderButtons() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Gender:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ToggleSwitch(
          minWidth: 90.0,
          initialLabelIndex: _selectedGender == 'Male' ? 0 : 1,
          cornerRadius: 20.0,
          activeFgColor: Colors.white,
          inactiveBgColor: Colors.grey,
          inactiveFgColor: Colors.white,
          totalSwitches: 2,
          labels: ['Male', 'Female'],
          icons: [FontAwesomeIcons.mars, FontAwesomeIcons.venus],
          activeBgColors: [
            [Colours.primarycolour],
            [Colours.primarycolour]
          ],
          onToggle: (index) {
            setState(() {
              _selectedGender = index == 0 ? 'Male' : 'Female';
            });
            print('Gender switched to: $_selectedGender');
          },
        ),
      ],
    ),
  );
}


  Widget _buildSpayedButtons() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7.0),
    child: Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Neutered/Spayed:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ToggleSwitch(
            minWidth: 90.0,
            cornerRadius: 20.0,
            activeBgColors: [[Colours.primarycolour], [Colours.primarycolour]],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            initialLabelIndex: _isSpayed == 'Yes' ? 0 : 1, // Sync with current state
            totalSwitches: 2,
            labels: ['Yes', 'No'],
            radiusStyle: true,
            onToggle: (index) {
              setState(() {
                _isSpayed = index == 0 ? 'Yes' : 'No'; // Update state
              });
              print('Spayed/Neutered switched to: $_isSpayed');
            },
          ),
        ],
      ),
    ),
  );
}
         

  @override
  Widget build(BuildContext context) {
      double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      
       body: Stack(
        children: [
          Container(
            width: screenWidth * 0.55,
            height: screenHeight * 0.10,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/topimage.png'), // Ensure the correct path
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                title: Text(
                  'Add  Pet',
                  style: TextStyle(
                    fontSize: screenHeight * 0.035,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo', 
                    color: Colors.brown, 
                  ),
                ),
                foregroundColor: Colors.brown,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
       Expanded(
         child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
             Center(
  child: Stack(
    alignment: Alignment.center,
    children: [
      GestureDetector(
        onTap: () {
          _pickImage();
        },
        child: Container(
          width: 160, 
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.5), 
          ),
          child: ClipOval(
           child: _profileImage != null
    ? Image.file(
        _profileImage!,
        width: 160,
        height: 160,
        fit: BoxFit.cover,
      )
    : null

          ),
        ),
      ),
      Positioned(
        bottom: 10,
        right: 10,
        child: GestureDetector(
          onTap: () {
          _pickImage();
          },
          child: Icon(
            Icons.camera_alt,
            color: Colors.brown,
            size: 30,
          ),
        ),
      ),
      if (_compressedSizeText != null) // 👈 show size below image
  Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Text(
      "Size: $_compressedSizeText",
      style: TextStyle(fontSize: 14, color: Colors.brown),
    ),
  ),
    ],
  ),
),

          Form(
  key: _formKey,
  child: Column(
    children: [
      _buildTextField('Pet Name', _nameController),
   
                _buildTypeDropdown(),
              _buildBreedDropdown(),
            //  _buildTextField("Enter Pet Age", _ageController),
            _buildTextField("Enter Pet Description", _descriptionController),
             _buildTextField("Enter Pet Location", _LocationController),
           _buildTextField(
  "Enter Birthday (YYYY/MM/DD)",
  _birthdayController,
  readOnly: true, // 👈 Prevent keyboard input
  onTap: () => _selectDate(context), // 👈 Trigger date picker on field tap
  suffixIcon: IconButton(
    icon: Icon(Icons.calendar_today, color: Colors.brown),
    onPressed: () => _selectDate(context),
  ),
),

              _buildGenderButtons(),
              _buildSpayedButtons(),
           
              Row(
                children: [
                  Expanded(
                    child: _buildTextField("Enter Weight (kg)", _weightController),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField("Enter Height (cm)", _heightController),
                  ),
                ],
              ),
              
              _buildTextField("Enter Microchip Number", _microchipController,requireValidation: false),



               Center(
              child: 
ElevatedButton(
  onPressed: () {
     if (_formKey.currentState!.validate()) {
final Map<String, dynamic> petData = {
  "name": _nameController.text,
  "breed": _selectedBreed,
  "gender": _selectedGender,
  "weight": _weightController.text,
  "height": _heightController.text,
  "microchip_number": _microchipController.text.isNotEmpty ? _microchipController.text : null,
  "location": _LocationController.text,
  "neutered_or_spayed": _isSpayed == 'Yes',
  "date_of_birth": _apiFormattedDate ?? "",
  "description": _descriptionController.text,
  "dateOfBirth": _birthdayController.text,
  "category": _selectedCategoryId,
  "subcategory": _selectedSubcategoryId,
  "owner": userId,
  // "phone_number": '$_selectedCountryCode${_phoneController.text}',
};

// ✅ Add the image only if it’s a valid File
if (_profileImage != null && _profileImage is File) {
  petData["pet_profile_image"] = _profileImage!;
}

    print("Sending data: $petData");
  petController.createPet(petData, context);
  }},


                style: ElevatedButton.styleFrom(
                   backgroundColor: Colours.primarycolour,
                  fixedSize: Size(screenWidth * 0.8, screenHeight * 0.07),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ],
          ),
               ),
            ]),
    ))])]));

    
  }
}


