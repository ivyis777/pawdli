import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart' as storage;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/getpetprofilecontroller.dart';
import 'package:pawlli/data/controller/subcategariescontroller.dart';
import 'package:pawlli/data/controller/typesofcategaries.dart';
import 'package:pawlli/data/controller/updatepetcontroller.dart';
import 'package:pawlli/data/model/updatepetmodel.dart';
import 'package:pawlli/presentation/screens/my%20pets/my%20pets.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:pawlli/data/model/subcategarymodel.dart' show Data;
import 'package:pawlli/data/model/typesofcategaries.dart' as cat_model;
import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 

class EditPetPage extends StatefulWidget {
    final int? PetId;
     const EditPetPage({super.key, required this.PetId});
  @override
  
  _EditPetPageState createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
    final petProfileController= Get.put< PetProfileController >( PetProfileController ());
    final AllCategoriesController _categoryController = Get.put(AllCategoriesController());
  final AllSubCategoriesController subCategoryController = Get.put(AllSubCategoriesController());
   final UpdatePetController updatePetController  = Get.put(UpdatePetController());
  ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
    String? _networkImageUrl;
 TextEditingController _nameController = TextEditingController();
  TextEditingController _LocationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController(); // Height controller
  TextEditingController _microchipController = TextEditingController();
File? _profileImage;
  final _formKey = GlobalKey<FormState>();
 String? _selectedType;
int? _selectedCategoryId;
int? _selectedGenderIndex;
int? _selectedSpayedIndex;


String? _selectedBreed; // subcategory name
int? _selectedSubcategoryId;

String? _selectedSubcategoryName;

    int? userId;
  String? _selectedGender;
  String? _isSpayed ;
 // subcategory name


@override
void dispose() {
  _nameController.dispose();
  _LocationController.dispose();
  _descriptionController.dispose();
  _ageController.dispose();
  _birthdayController.dispose();
  _weightController.dispose();
  _heightController.dispose();
  _microchipController.dispose();
  super.dispose();
}


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData(); 
    });
  }


void _initializeData() async {
  await _categoryController.fetchAllCategories(); 
  final box = storage.GetStorage();
  userId = box.read(LocalStorageConstants.userId); 
  debugPrint("Retrieved userId: $userId");

  await fetchPetDetails();
}
Future<void> fetchPetDetails() async {
  try {
    await petProfileController.loadPetProfile(widget.PetId);
    final petDetails = petProfileController.PetProfile.value;

    if (petDetails != null) {
      // Load categories first
      await _categoryController.fetchAllCategories();
      final categoryList = _categoryController.allCategories;

      // Find matching category
      final matchedCategory = categoryList.firstWhere(
        (cat) => cat.categoryId == petDetails.category,
        orElse: () => cat_model.Data(),
      );

      setState(() {
        _selectedType = matchedCategory.name;
        _selectedCategoryId = matchedCategory.categoryId;
      });

      // If category is found, load breeds
      if (_selectedCategoryId != null) {
        await subCategoryController.fetchAllsubCategories(_selectedCategoryId!);
        
        // Wait for breeds to load
        await Future.delayed(Duration(milliseconds: 100));

        setState(() {
          // Use subcategoryName directly from API response
          _selectedBreed = petDetails.subcategoryName;
          _selectedSubcategoryId = petDetails.subcategory;
          _selectedSubcategoryName = petDetails.subcategoryName;
        });
      }

      // Set other fields...
      setState(() {
        _nameController.text = petDetails.name ?? '';
        _ageController.text = petDetails.age?.years?.toString() ?? '';
        _LocationController.text = petDetails.location ?? '';
        _descriptionController.text = petDetails.description ?? '';
        _birthdayController.text = petDetails.dateOfBirth ?? '';
        _weightController.text = petDetails.weight?.toString() ?? '';
        _heightController.text = petDetails.height?.toString() ?? '';
        _microchipController.text = petDetails.microchipNumber ?? '';
        _selectedGender = petDetails.gender;
        
        if (petDetails.petProfileImage != null && petDetails.petProfileImage!.isNotEmpty) {
          _networkImageUrl = petDetails.petProfileImage;
        } else {
          _networkImageUrl = null;
        }

        switch (_selectedGender?.toLowerCase()) {
          case 'male': _selectedGenderIndex = 0; break;
          case 'female': _selectedGenderIndex = 1; break;
          default: _selectedGenderIndex = 2;
        }

        _selectedSpayedIndex = (petDetails.neuteredOrSpayed == true) ? 0 : 1;
      });
    }
  } catch (e) {
    debugPrint("Error fetching pet details: $e");
  }
}

Future<File?> _compressImage(XFile image) async {
  final filePath = image.path;
  final lastIndex = filePath.lastIndexOf(RegExp(r'.jp')); // works for .jpg, .jpeg
  final split = filePath.substring(0, lastIndex);
  final outPath = "${split}_compressed.jpg";

  final compressedXFile = await FlutterImageCompress.compressAndGetFile(
    filePath,
    outPath,
    quality: 70, // adjust quality (0–100)
  );

  if (compressedXFile == null) return null;

  return File(compressedXFile.path); // ✅ return File
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
                  _profileImage = cropped; // ✅ CROPPED IMAGE SAVED
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
                  _profileImage = cropped; // ✅ CROPPED IMAGE SAVED
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
    // Format as YYYY-MM-DD
    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

    setState(() {
      _birthdayController.text = formattedDate;
    });
  }
}



Widget _buildTextField(
  String label,
  TextEditingController controller, {
  Widget? suffixIcon,
  bool requireValidation = true,
    bool readOnly = false,           // 👈 add readOnly
  VoidCallback? onTap,      // <- add this flag
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: TextFormField(
      controller: controller,
       readOnly: readOnly,          // 👈 apply readOnly
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




Widget _buildTypeDropdown() {
  return Obx(() {
    if (_categoryController.isLoading.value) {
      return CircularProgressIndicator();
    }

    if (_categoryController.errorMessage.isNotEmpty) {
      return Text(_categoryController.errorMessage.value);
    }

    final categories = _categoryController.allCategories;

    // Extract unique, non-null category names
    final validCategoryNames = categories
        .where((cat) => cat.name != null)
        .map((cat) => cat.name!)
        .toSet()
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: validCategoryNames.contains(_selectedType) ? _selectedType : null,
        items: validCategoryNames.map((name) {
          return DropdownMenuItem<String>(
            value: name,
            child: Text(name),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedType = newValue;

            final selectedCategory = categories.firstWhere(
              (cat_model.Data category) => category.name == newValue,
              orElse: () => cat_model.Data(),
            );

            if (selectedCategory.categoryId != null) {
              _selectedCategoryId = selectedCategory.categoryId;
              subCategoryController.fetchAllsubCategories(_selectedCategoryId!);
            }
          });
        },
        decoration: InputDecoration(
          labelText: 'Select Type',
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
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
      ),
    );
  });
}
Widget _buildBreedDropdown() {
  return Obx(() {
    if (subCategoryController.isLoading.value) {
      return CircularProgressIndicator();
    }

    if (subCategoryController.errorMessage.isNotEmpty) {
      return Text(subCategoryController.errorMessage.value);
    }

    final breedList = subCategoryController.allsubCategories;

    // ✅ Filter valid, unique breed names
    final validBreeds = breedList
        .where((sub) => sub.name != null)
        .map((sub) => sub.name!)
        .toSet()
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        // ✅ Ensure selected value is in the dropdown
        value: validBreeds.contains(_selectedBreed) ? _selectedBreed : null,
        items: validBreeds.map((name) {
          return DropdownMenuItem<String>(
            value: name,
            child: Text(name),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedBreed = newValue;

            final selected = breedList.firstWhere(
              (e) => e.name == newValue,
              orElse: () => Data(),
            );

            _selectedSubcategoryId = selected.subcategoryId;
            _selectedSubcategoryName = selected.name;
          });
        },
        decoration: InputDecoration(
          labelText: 'Select Breed',
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
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
      ),
    );
  });
}

  Widget _buildGenderButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
       
        child: Row(
   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Gender:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            
         ToggleSwitch(
  minWidth: 90.0,
  initialLabelIndex: _selectedGenderIndex ?? 0,
  cornerRadius: 20.0,
  activeFgColor: Colors.white,
  inactiveBgColor: Colors.grey,
  inactiveFgColor: Colors.white,
  totalSwitches: 2,
  labels: ['Male', 'Female'],
  icons: [FontAwesomeIcons.mars, FontAwesomeIcons.venus],
  activeBgColors: [[Colours.primarycolour], [Colours.primarycolour]],
  onToggle: (index) {
    setState(() {
      _selectedGenderIndex = index;
    });
  },
),

            
          ],
        ),
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
  initialLabelIndex: _selectedSpayedIndex ?? 0,
  totalSwitches: 2,
  labels: ['Yes', 'No'],
  radiusStyle: true,
  onToggle: (index) {
    setState(() {
      _selectedSpayedIndex = index;
    });
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
      
       body:
        Stack(
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
                  'Edit Pet',
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 20),
                        Center(
                          child:  Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
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
    : (_networkImageUrl != null
        ? CachedNetworkImage(
            imageUrl: _networkImageUrl!,
            width: 160,
            height: 160,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 50,
            ),
          )
        : SizedBox(
            width: 160,
            height: 160,
          )),

),

              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.brown,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
     
                        ),
                        SizedBox(height: 20),
                        _buildTextField("Enter Pet Name", _nameController),
                        _buildTypeDropdown(),
                        _buildBreedDropdown(),
                        _buildTextField("Enter Pet Description", _descriptionController),
                        _buildTextField("Enter Pet Location", _LocationController),
                        _buildTextField(
                          "Enter Birthday (yyyy/mm/dd)",
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
                        Row(
                          children: [
                            Expanded(child: _buildTextField("Enter Weight (kg)", _weightController)),
                            SizedBox(width: 10),
                            Expanded(child: _buildTextField("Enter Height (cm)", _heightController)),
                          ],
                        ),
           _buildTextField("Enter Microchip Number", _microchipController,requireValidation: false),
                        SizedBox(height: 20),
                        Center(
                          child: Obx(() => updatePetController.isLoading.value
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: () async {
                                    final formState = _formKey.currentState;
                                    if (formState != null && formState.validate()) {
                                      print("✅ Form validated!");
                                      final result = await _updatePetProfile();
                                      if (result != null &&
                                          result.message.toLowerCase().contains("success")) {
                                        print("🎉 Pet updated successfully!");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => MyPets( fromUpdateFlow: true,)),
                                        );
                                      } 
                                    } else {
                                      print("❌ Form not validated");
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
                  "Update",
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                                )),
                        )

            ],
          ),
               ),
       ),
    )])]));

    
  }
 Future<UpdatePetModel?> _updatePetProfile() async {
  final model = UpdatePetModel(
    message: "Updating...",
    data: PetData(
      petId: widget.PetId!,
      categoryName: _selectedType ?? '',
      subcategoryName: _selectedBreed ?? '',
      name: _nameController.text.trim(),
      // age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _selectedGenderIndex == 0
          ? 'Male'
          : _selectedGenderIndex == 1
              ? 'Female'
              : 'Other',
      weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
      height: double.tryParse(_heightController.text.trim()) ?? 0.0,
      preferences: {},
      microchipNumber: _microchipController.text.trim(),
      location: _LocationController.text.trim(),
      description: _descriptionController.text.trim(),
      petProfileImage: _profileImage?.path ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      dateOfBirth: _birthdayController.text.trim(),
       neuteredOrSpayed: _selectedSpayedIndex == 0 ? true : false,
      category: _selectedCategoryId ?? 0,
      subcategory: _selectedSubcategoryId ?? 0,
      owner: userId ?? 0,
    ),
  );

  return await updatePetController.updatePet(model, widget.PetId.toString());
}


}