import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart' as storage;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/adoptioncreationcontroller.dart';
import 'package:pawlli/data/model/subcategarymodel.dart' show Data;
import 'package:pawlli/data/model/typesofcategaries.dart' as cat_model;
import 'package:toggle_switch/toggle_switch.dart';
import 'dart:io';
import 'package:get/get.dart';

class AddPetAdoption extends StatefulWidget {
  @override
  _AddPetAdoptionState createState() => _AddPetAdoptionState();
}

class _AddPetAdoptionState extends State<AddPetAdoption> {
  ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _LocationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController(); 
  TextEditingController _microchipController = TextEditingController();
 
TextEditingController _phoneController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN');
   final CreateAdoptionController petController = Get.put(CreateAdoptionController ());
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
File? _profileImage; // Correct
bool _isAvailable = true;
bool _isSoldout = false;
bool _isPhoneNumberValid = false;


 String? _selectedType;
int? _selectedCategoryId;
  String? _apiFormattedDate; 
String? _selectedSubcategoryId ;
    String? _selectedBreed ;
    int? userId;
  String? _selectedGender = 'Male';
  String? _isSpayed = 'No';
String _isFree = 'Yes';

@override
void initState() {
  super.initState();
        final box = storage.GetStorage();
  userId ??= box.read(LocalStorageConstants.userId); 
  WidgetsBinding.instance.addPostFrameCallback((_) {
 
 
    _selectedType = null;
  _selectedBreed = null;
  _selectedSubcategoryId = null;
  // subCategoryController.allsubCategories.clear();
  // subCategoryController.errorMessage('');
  // subCategoryController.isLoading(false);
  //  _categoryController.fetchAllCategories();
    });
}
String sanitizePhoneNumber(String input) {
  String cleaned = input.replaceAll(RegExp(r'[^+\d]'), '');
  cleaned = cleaned.replaceAll('+', '');

  // Auto-correct for known bad data (e.g. +93+ format used for Indian numbers)
  if (cleaned.startsWith('91') && cleaned.length == 12) {
    cleaned = cleaned.replaceFirst('93', '91');
  }

  return '+$cleaned';
}
Future<File?> _compressImage(XFile image) async {
  final filePath = image.path;
  final lastIndex = filePath.lastIndexOf(RegExp(r'.jp')); // .jpg/.jpeg
  final split = filePath.substring(0, lastIndex);
  final outPath = "${split}_compressed.jpg";

  final compressedXFile = await FlutterImageCompress.compressAndGetFile(
    filePath,
    outPath,
    quality: 70,
  );

  if (compressedXFile == null) return null;
  return File(compressedXFile.path); // ✅ Always return File
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
                    await _picker.pickImage(source: ImageSource.camera);
                if (image == null) return;

                final File? compressed =
                    await _compressImage(image);
                if (compressed == null) return;

                final File? cropped =
                    await _cropImage(compressed);
                if (cropped == null) return;

                setState(() {
                  _profileImage = cropped; // ✅ SAVE CROPPED IMAGE
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Upload from Gallery'),
              onTap: () async {
                Navigator.pop(sheetContext); // ✅ CLOSE SHEET FIRST

                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image == null) return;

                final File? compressed =
                    await _compressImage(image);
                if (compressed == null) return;

                final File? cropped =
                    await _cropImage(compressed);
                if (cropped == null) return;

                setState(() {
                  _profileImage = cropped; // ✅ SAVE CROPPED IMAGE
                });
              },
            ),
          ],
        ),
      );
    },
  );
}


Future<void> _selectDate(BuildContext context) async {
  DateTime initialDate = DateTime.now();
  DateTime firstDate = DateTime(1900);
  DateTime lastDate = DateTime.now();

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
  VoidCallback? onTap,  // <- add this flag
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: TextFormField(
      controller: controller,
        readOnly: readOnly,          
      onTap: onTap,      
      validator: (value) {
        if (requireValidation && (value == null || value.trim().isEmpty)) {
          return 'Please enter this field';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colours.brownColour),
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
         
Widget _buildIsFreeOrPaidToggle() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Is Free:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ToggleSwitch(
          minWidth: 90.0,
          cornerRadius: 20.0,
          activeBgColors: [[Colours.primarycolour], [Colours.primarycolour]],
          activeFgColor: Colors.white,
          inactiveBgColor: Colors.grey,
          inactiveFgColor: Colors.white,
          initialLabelIndex: _isFree == 'Yes' ? 0 : 1,
          totalSwitches: 2,
          labels: ['Yes', 'No'],
          radiusStyle: true,
          onToggle: (index) {
            setState(() {
              _isFree = index == 0 ? 'Yes' : 'No';
            });
            print('Is Free switched to: $_isFree');
          },
        ),
      ],
    ),
  );
}
Widget _buildStatusToggle() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Status:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IgnorePointer( // Prevent interaction
          child: ToggleSwitch(
            minWidth: 100.0,
            cornerRadius: 20.0,
            activeBgColors: [
              [Colours.primarycolour],
              [Colours.primarycolour]
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            initialLabelIndex: 0, // Always "Available"
            totalSwitches: 2,
            labels: ['Available', 'Adopted'],
            radiusStyle: true,
            onToggle: (_) {}, // Won't be called due to IgnorePointer
          ),
        ),
      ],
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
                    fontFamily: 'Cairo', // Ensure this font is properly defined in pubspec.yaml
                    color: Colors.brown, // Change Colours.brownColour to an actual color
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
    ],
  ),
),

          Form(
  key: _formKey,
  child: Column(
    children: [
      _buildTextField('Pet Name', _nameController, requireValidation: false),
   
            SizedBox(height: 5),
         InternationalPhoneNumberInput(
onInputChanged: (PhoneNumber number) {
    setState(() {
      _phoneNumber = number;
    });
  },
  onInputValidated: (bool isValid) {
    setState(() {
      _isPhoneNumberValid = isValid; // ✅ <-- This is what was missing
    });
    print(isValid ? '✅ Valid phone number' : '❌ Invalid phone number');
  },
  selectorConfig: SelectorConfig(
    selectorType: PhoneInputSelectorType.DIALOG,
  ),
  textFieldController: _phoneController,
  formatInput: false,
  
  initialValue: _phoneNumber,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    return null;
  },
  inputDecoration: InputDecoration(
    labelText: 'Phone Number',
      fillColor: Colors.white,

    labelStyle: TextStyle(color: Colors.brown[600]),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.brown),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colours.primarycolour, width: 2.0),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
)
,
              //   _buildTypeDropdown(),
              // _buildBreedDropdown(),

            //  _buildTextField("Enter Pet Age", _ageController),
            _buildTextField("Enter Pet Description", _descriptionController),
             _buildTextField("Enter Pet Location", _LocationController),
              _buildTextField(
                "Enter Birthday (YYYY/MM/DD)", requireValidation: false,
                _birthdayController,
                  readOnly: true,
                onTap: () => _selectDate(context),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.brown),
                  onPressed: () => _selectDate(context),
                ),
              ),
              _buildGenderButtons(),
              _buildSpayedButtons(),
              _buildIsFreeOrPaidToggle(),
         _buildStatusToggle(),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField("Enter Weight (kg)", _weightController, requireValidation: false),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField("Enter Height (cm)", _heightController, requireValidation: false),
                  ),
                ],
              ),
              
              _buildTextField("Enter Microchip Number", _microchipController,requireValidation: false),



               Center(
              child: 
ElevatedButton(
  onPressed: () {
     if (!_isPhoneNumberValid) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter a valid phone number'),
        backgroundColor: Colors.black,
      ),
    );
    return;
  }

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
  // "category": _selectedCategoryId,
  // "subcategory": _selectedSubcategoryId,
  "owner": userId,
  "mobile_number": _phoneNumber.phoneNumber ?? '',

     "is_free": _isFree == 'Yes',
        "is_paid": _isFree == 'No',
"isAvailable": _isAvailable,
"isSoldout": _isSoldout,

  
};

// ✅ Add the image only if it’s a valid File
 if (_profileImage != null && _profileImage is File) {
          petData["pet_profile_image"] = _profileImage!;
        }

        print("Sending data: $petData");

        /// ✅ FIX: use `petData` instead of undefined `adoptionForm`
        petController.createAdoptionRequest(petData, context);
      }
    },


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


