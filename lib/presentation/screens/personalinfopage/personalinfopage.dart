import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart' as storage;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/getuserprofilecontroller.dart';
import 'package:pawlli/data/controller/updateuserprofilecontroller.dart';
import 'package:pawlli/data/model/updateprofilemodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/userprofile/userprofile.dart';
import 'package:toggle_switch/toggle_switch.dart'; 
import 'package:get/get.dart';
class PersonalInfoPage extends StatefulWidget {
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}
class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
     final userDetailsController = Get.put<UserProfileController >(UserProfileController ());
     final UpdateProfileController updateProfileController = Get.put(UpdateProfileController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();  
  final TextEditingController _address1Controller = TextEditingController(); 
  final TextEditingController _address2Controller = TextEditingController(); 
  final TextEditingController _cityController = TextEditingController(); 
  final TextEditingController _stateController = TextEditingController(); 
  final TextEditingController _countryController = TextEditingController(); 
  final TextEditingController _pincodeController = TextEditingController(); 
  PhoneNumber? _phoneNumber;
 ImagePicker _picker = ImagePicker();
  File? _imageFile; 
int? _selectedGenderIndex; 
  File? _profileImage;
  int? userId;
  String? _networkImageUrl;
bool _isPhoneNumberValid = false;

  @override
void initState() {
  super.initState();
  
  fetchUserDetails(); 

    
}
String sanitizePhoneNumber(String input) {
  // Remove all non-digit and non-plus characters
  String cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');

  // Fix multiple pluses like +93+987654567 → +93987654567
  if (cleaned.startsWith('+') && cleaned.substring(1).contains('+')) {
    cleaned = '+' + cleaned.substring(1).replaceAll('+', '');
  }

  // Remove '+' to make checking easier
  String digitsOnly = cleaned.replaceAll('+', '');

  // Fix known bad data: Afghan country code used for Indian number
  if (digitsOnly.startsWith('93') && digitsOnly.length == 12) {
    digitsOnly = digitsOnly.replaceFirst('93', '91');
  }

  return '+$digitsOnly';
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

Future<File?> _compressImage(XFile image) async {
  final filePath = image.path;
  final lastIndex = filePath.lastIndexOf(RegExp(r'.jp')); // .jpg or .jpeg
  final split = filePath.substring(0, lastIndex);
  final outPath = "${split}_compressed.jpg";

  final compressedXFile = await FlutterImageCompress.compressAndGetFile(
    filePath,
    outPath,
    quality: 70,
  );

  if (compressedXFile == null) return null;

  return File(compressedXFile.path); // ✅ return File, not XFile
}

Future<void> fetchUserDetails() async {
  final box = storage.GetStorage();
  userId ??= box.read(LocalStorageConstants.userId); 

  if (userId == null) {
    print("Error: userId is null. Cannot fetch wallet balance.");
    return;
  }

  try {
    await userDetailsController.loadUserProfile(userId); 
    final userDetails = userDetailsController.userProfile.value;

    if (userDetails != null && mounted) {
      final userData = userDetails;

      setState(() {
        _nameController.text = userData.name ?? '';
        _ageController.text = userData.age?.toString() ?? '';
        _emailController.text = userData.email ?? '';
        _address1Controller.text = userData.address ?? '';
        _address2Controller.text = userData.address ?? '';
        _cityController.text = userData.city ?? '';
        _stateController.text = userData.state ?? '';
        _countryController.text = userData.country ?? '';
        _pincodeController.text = userData.pincode?.toString() ?? '';

        if (userData.profilePicture?.isNotEmpty == true) {
          _networkImageUrl = userData.profilePicture;
        } else {
          _networkImageUrl = null;
        }

       
       switch (userData.gender?.toLowerCase()) {
  case "male":
    _selectedGenderIndex = 0;
    break;
  case "female":
    _selectedGenderIndex = 1;
    break;
  default:
    // fallback default selection
    _selectedGenderIndex = 0; // 👈 Default Male (set 1 for Female)
    break;
}
        box.write('selectedGender', _selectedGenderIndex);
      });

     

      // PHONE NUMBER PARSING
      if (userData.mobile?.isNotEmpty == true) {
        String rawMobile = userData.mobile!.trim();
        print("Raw mobile from API: $rawMobile");

        String sanitizedMobile = sanitizePhoneNumber(rawMobile);
        print("Sanitized mobile for libphonenumber: $sanitizedMobile");

        try {
          PhoneNumber.getRegionInfoFromPhoneNumber(sanitizedMobile).then((phone) {
            setState(() {
              _phoneNumber = phone;
              _phoneController.text = phone.parseNumber() ?? '';
            });
          }).catchError((e) {
            print('PhoneNumber parse error: $e');
          });
        } catch (e) {
          print('Exception during phone parse: $e');
        }
      }

    } else {
      debugPrint("User details not found.");
    }
  } catch (e) {
    debugPrint("Error fetching user details: $e");
  }
}

Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Picture'),
              onTap: () async {
                final XFile? image =
                    await picker.pickImage(source: ImageSource.camera);

                if (image != null) {
                  final compressed = await _compressImage(image);
                  if (compressed != null) {
                    final cropped = await _cropImage(compressed);
                    if (cropped != null) {
                      setState(() {
                        _profileImage = cropped; // ✅ SAVE CROPPED IMAGE
                      });
                    }
                  }
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Upload from Gallery'),
              onTap: () async {
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);

                  if (image != null) {
                    final File? compressed = await _compressImage(image);

                    if (compressed != null) {
                      final File? cropped = await _cropImage(compressed!);

                      if (cropped != null) {
                        setState(() {
                          _profileImage = cropped; // ✅ NO RED LINE
                        });
                      }
                    }
                  }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
     backgroundColor: Colours.secondarycolour,
       body: Stack(
        children: [
          Container(
            width: screenWidth * 0.55,
            height: screenHeight * 0.10,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.topimage.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                title: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: screenHeight * 0.035,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.Cairo,
                    color: Colours.brownColour,
                  ),
                ),
                foregroundColor: Colours.brownColour,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
 
         Expanded(
  child: SingleChildScrollView(
    child: Column(
      children: [
        Stack(
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
            errorWidget: (context, url, error) => Icon(Icons.error),
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
     
                SizedBox(height: 30), // Adjust the space between the CircleAvatar and form
          
                // Scrollable Form Container
               Container(
      padding: EdgeInsets.all(20),
  
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            TextFormField(
              
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.brown[600]),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown),
                  borderRadius: BorderRadius.circular(10),
                  
                ),
                  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colours.primarycolour, width: 2.0), // Focus color
      borderRadius: BorderRadius.circular(10),
    ),
  ),
                
            
              
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 15),

         TextFormField(
  controller: _ageController,
  decoration: InputDecoration(
    labelText: 'Age',
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
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your age';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number';
    }
    if (age < 1 || age > 100) {
      return 'Age must be between 1 to 100';
    }
    return null;
  },
),

            Container(
  padding: const EdgeInsets.symmetric(vertical: 5.0),
  width: double.infinity, // Ensures finite width
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      Text(
        'Gender:',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      Column(
        children: [
          ToggleSwitch(
              initialLabelIndex: _selectedGenderIndex,
            minWidth: 80.0,
            minHeight: 50.0,
          
            cornerRadius: 20.0,
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            totalSwitches: 3,
            icons: [
              FontAwesomeIcons.mars,
              FontAwesomeIcons.venus,
              FontAwesomeIcons.transgender
            ],
            iconSize: 30.0,
            borderWidth: 2.0,
            activeBgColors: [
              [Colours.primarycolour],
              [Colours.primarycolour],
              [Colours.primarycolour]
            ],
           onToggle: (index) {
  setState(() {
    _selectedGenderIndex = index;
  });
},

          ),
          SizedBox(height: 5), // Space between toggle and labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Male', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Female', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Others', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
),
            SizedBox(height: 15),
         InternationalPhoneNumberInput(
  onInputChanged: (PhoneNumber number) {
    setState(() {
      _phoneNumber = number;
    });
  },
 onInputValidated: (bool isValid) {
  setState(() {
    _isPhoneNumberValid = isValid;
  });
  // print(isValid ? '✅ Valid phone number' : '❌ Invalid phone number');
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
            SizedBox(height: 15),

            TextFormField(
  controller: _emailController,
  readOnly: true,
  style: TextStyle(color: Colors.grey), // Grey text
  decoration: InputDecoration(
    labelText: 'Email ID',
    labelStyle: TextStyle(color: Colors.grey),
    filled: true,
    fillColor: Colors.grey[100], // Optional: light grey background
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
),

            SizedBox(height: 15),

            // Address 1 Field
            TextFormField(
              controller: _address1Controller,
              decoration: InputDecoration(
                labelText: 'Address ',
                labelStyle: TextStyle(color: Colors.brown[600]),
           
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colours.primarycolour, width: 2.0), // Focus color
      borderRadius: BorderRadius.circular(10),
    ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                labelStyle: TextStyle(color: Colors.brown[600]),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colours.primarycolour, width: 2.0), // Focus color
      borderRadius: BorderRadius.circular(10),
    ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your city';
                }
                return null;
              },
            ),
            SizedBox(height: 15),

            // State Field
            TextFormField(
              controller: _stateController,
              decoration: InputDecoration(
                labelText: 'State',
                labelStyle: TextStyle(color: Colors.brown[600]),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colours.primarycolour, width: 2.0), // Focus color
      borderRadius: BorderRadius.circular(10),
    ),
              ),

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your state';
                }
                return null;
              },
            ),
            SizedBox(height: 15),

            // Country Field
            TextFormField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: 'Country',
                labelStyle: TextStyle(color: Colors.brown[600]),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colours.primarycolour, width: 2.0), // Focus color
      borderRadius: BorderRadius.circular(10),
    ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your country';
                }
                return null;
              },
            ),
            SizedBox(height: 15),


            // Pincode Field
           TextFormField(
  controller: _pincodeController,
  decoration: InputDecoration(
    labelText: 'Pincode',
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
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your pincode';
                }
                return null;
              },
            ),
         

        
          SizedBox(height: 20),
    Obx(() => updateProfileController.isLoading.value
    ? CircularProgressIndicator()
    : Center(
        child: ElevatedButton(
         onPressed: () async {
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
    await _updateProfile();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(fromUpdateFlow: true),
      ),
    );
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
            'Update',
            style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )
          ),
        ),
      ),
),

          ],
        ),
      ),
    )
              ],
            ),
          ),
        ),
      
        ])]));
  }
Future<void> _updateProfile() async {
  final model = UpdateProfileModel(
    id: userId,
    name: _nameController.text.trim(),
    email: _emailController.text.trim(),
    mobile: _phoneNumber?.phoneNumber?.trim() ?? _phoneController.text.trim(),
    age: int.tryParse(_ageController.text.trim()),
    gender: _selectedGenderIndex == 0
        ? 'Male'
        : _selectedGenderIndex == 1
            ? 'Female'
            : 'Other',
    address: _address1Controller.text.trim(),
    city: _cityController.text.trim(),
    state: _stateController.text.trim(),
    country: _countryController.text.trim(),
    pincode: int.tryParse(_pincodeController.text.trim()),
    profilePicture: _profileImage?.path,
  );

  await updateProfileController.updateUserProfile(model);

  // Reload user details and update UI state
  await fetchUserDetails();

  // Optionally show a success message here
}


}
