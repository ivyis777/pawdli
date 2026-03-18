import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latLng; 
import 'package:http/http.dart' as http;
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/Donation/donationpaymentservice.dart';
import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/data/controller/goodbyebuddycontroller.dart';
import 'package:get/get.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/good%20bye%20buddy/superuserdetailspage.dart';
import 'package:pawlli/presentation/screens/good%20bye%20buddy/userdetailspage.dart';


class Goodbyebudddy extends StatefulWidget {
  const Goodbyebudddy({Key? key}) : super(key: key);

  @override
  _GoodbyebudddyState createState() => _GoodbyebudddyState();
}

class _GoodbyebudddyState extends State<Goodbyebudddy> 
with SingleTickerProviderStateMixin {
  TextEditingController programDescriptionController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
    TextEditingController locationController = TextEditingController();
  final GoodByeBuddyController goodByeBuddyController = Get.put(GoodByeBuddyController());
  final TextEditingController donationAmountController = TextEditingController();
  TextEditingController donationMessageController = TextEditingController();
final DonationPaymentService donationPaymentService =
    Get.put(DonationPaymentService());
late TabController _tabController;
String pageTitle = "GoodByeBuddy";

String? _locationString;


final _locationChannel = MethodChannel('location_permissions');

int _locationPermissionAttempts = 0;
  final box = GetStorage();
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  latLng.LatLng? _selectedLocation;
  bool _isLoadingLocation = false;
  List requests = [];
bool isLoadingRequests = true;


  List<XFile>? _imageFiles; 

  String formatDateTime(String date) {
  try {
    final parsedDate = DateTime.parse(date).toLocal();

    return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
  } catch (e) {
    return date; // fallback if error
  }
}

@override
void initState() {
  super.initState();

  donationPaymentService.init();

  _tabController = TabController(
    length: 3, // GoodByeBuddy + Donation
    vsync: this,
  );

    _tabController.addListener(() {
    if (_tabController.index == 0) {
      setState(() {
        pageTitle = "GoodByeBuddy";
      });
    } else if (_tabController.index == 1) {
      setState(() {
        pageTitle = "Donation";
      });
    } else if (_tabController.index == 2) {
      setState(() {
        pageTitle = "Requests";
      });
    }
  });

  fetchRequests();
}

void safeSnackbar(String title, String message,
    {Color bg = Colors.black}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (Get.overlayContext != null) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: bg,
        colorText: Colors.white,
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  });
}


Future<void> _pickImage() async {
  final List<XFile>? pickedFiles = await _picker.pickMultiImage();
  if (pickedFiles != null && pickedFiles.isNotEmpty) {
    List<XFile> compressedList = [];
    for (var file in pickedFiles) {
      final compressed = await _compressImage(file);
      if (compressed != null) {
        compressedList.add(XFile(compressed.path));
      }
    }
    setState(() {
      _imageFiles = compressedList;
    });
  }
}

Future<XFile?> _compressImage(XFile file) async {
  try {
    final filePath = file.path;

    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) return file;

    final outPath =
        '${filePath.substring(0, lastDot)}_compressed.jpg';

    final compressedFile =
        await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    return compressedFile != null
        ? XFile(compressedFile.path)
        : file;
  } catch (e) {
    debugPrint('Compression error: $e');
    return file;
  }
}

Future<void> fetchRequests() async {
  try {
    final response = await http.get(
      Uri.parse(AppUrl.GoodByeBuddyListUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${box.read(LocalStorageConstants.access)}",
      },
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      final allRequests = data["data"] ?? [];

      final isSuperUser =
          box.read(LocalStorageConstants.isSuperUser);

      final userId =
          box.read(LocalStorageConstants.userId);

          print("IS SUPER USER: $isSuperUser");
      print("USER ID: $userId");
      print("TOTAL REQUESTS FROM API: ${allRequests.length}");


      bool isAdmin = false;

      if (isSuperUser == true ||
          isSuperUser == "true" ||
          isSuperUser == 1) {
        isAdmin = true;
      }

      if (isAdmin) {
          requests = allRequests;
        } else {
          requests = allRequests
              .where((r) => r["created_by"]?.toString() == userId?.toString())
              .toList();
        }

        // ✅ SORT REQUESTS
        requests.sort((a, b) {
          final statusA = (a["status"] ?? "").toString().toLowerCase();
          final statusB = (b["status"] ?? "").toString().toLowerCase();

          // ✅ Pending first
          if (statusA == "completed" && statusB != "completed") {
            return 1; // completed goes down
          }
          if (statusA != "completed" && statusB == "completed") {
            return -1; // pending goes up
          }

          // ✅ If same status → sort by latest date
          final dateA = DateTime.tryParse(a["created_at"] ?? "") ?? DateTime(2000);
          final dateB = DateTime.tryParse(b["created_at"] ?? "") ?? DateTime(2000);

          return dateB.compareTo(dateA); // latest first
        });

        setState(() {
          isLoadingRequests = false;
        });
    }

  } catch (e) {
    print("Request API error: $e");
  }
}

Future<void> _takePhoto() async {
  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
  if (photo != null) {
    final compressed = await _compressImage(photo);
    if (compressed != null) {
      setState(() {
        _imageFiles = (_imageFiles ?? []) + [XFile(compressed.path)];
      });
    }
  }
}

 final MapController _mapController = MapController();
  latLng.LatLng? _selectedMapLocation;
  bool _showMap = false;
 
  // Function to show map for location selection
   Future<void> _openMapForLocationSelection() async {
  setState(() => _isLoadingLocation = true);

  try {
    // 1️⃣ Permission check
    bool hasPermission = await checkLocationPermission();
    if (!hasPermission) {
      hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        _locationPermissionAttempts++;

        setState(() => _isLoadingLocation = false); // 🔴 FIX

        if (_locationPermissionAttempts >= 2) {
          final openSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                'Location permission is denied.\nPlease enable it in app settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );

          if (openSettings == true) {
            await Geolocator.openAppSettings();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission required')),
          );
        }
        return;
      }
    }

    // 2️⃣ Location services check
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false); // 🔴 FIX
      bool? shouldEnable = await showEnableLocationDialog();
      if (shouldEnable == true) {
        await Geolocator.openLocationSettings();
      }
      return;
    }

    // 3️⃣ Get current location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 10),
    );

    // 4️⃣ Open map with initial marker
    setState(() {
      _selectedMapLocation =
          latLng.LatLng(position.latitude, position.longitude);
      _showMap = true;
      _locationPermissionAttempts = 0;
      _isLoadingLocation = false; // 🔴 FIX
    });
  } on PlatformException catch (e) {
    setState(() => _isLoadingLocation = false);
    _handleLocationError(e);
  } catch (e) {
    setState(() => _isLoadingLocation = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unexpected error: $e')),
    );
  }
}

Future<bool?> showEnableLocationDialog() async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Location Service Disabled'),
      content: const Text('Please enable location services'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Enable'),
        ),
      ],
    ),
  );
}

Future<bool> checkLocationPermission() async {
  final status = await Geolocator.checkPermission();
  return status == LocationPermission.always || 
         status == LocationPermission.whileInUse;
}

Future<bool> requestLocationPermission() async {
  final status = await Geolocator.requestPermission();
  return status == LocationPermission.always || 
         status == LocationPermission.whileInUse;
}
void _handleLocationError(PlatformException e) {
  String errorMessage;
  
  switch (e.code) {
    case 'PERMISSION_DENIED':
      errorMessage = 'Location permissions denied';
      break;
    case 'PERMISSION_DENIED_NEVER_ASK':
      errorMessage = 'Location permissions permanently denied. Please enable in app settings.';
      _showPermissionSettingsDialog();
      break;
    case 'LOCATION_SERVICES_DISABLED':
      errorMessage = 'Location services disabled';
      break;
    case 'TIMEOUT':
      errorMessage = 'Location request timed out';
      break;
    default:
      errorMessage = 'Error getting location: ${e.message}';
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage)),
  );
}

Future<void> _showPermissionSettingsDialog() async {
  final openSettings = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Permission Required'),
      content: const Text('Location permissions are permanently denied. Please enable them in app settings.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
  
  if (openSettings == true) {
    await Geolocator.openAppSettings();
  }
}
  Future<void> _confirmLocation() async {
  if (_selectedMapLocation == null) return;

  setState(() {
    _isLoadingLocation = true;
  });

  try {
    
    List<Placemark> placemarks = await placemarkFromCoordinates(
      _selectedMapLocation!.latitude,
      _selectedMapLocation!.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String address = [
        place.street,
        place.locality,
        place.postalCode,
        place.country
      ].where((part) => part != null && part!.isNotEmpty).join(', ');

      setState(() {
        _locationString = address;
        _selectedLocation = latLng.LatLng(
          _selectedMapLocation!.latitude,
          _selectedMapLocation!.longitude,
        );
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to get address: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isLoadingLocation = false;
      _showMap = false;
    });
  }
}
   Widget _buildMapView() {
  return Stack(
    children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _selectedMapLocation ?? latLng.LatLng(0, 0), // Changed from 'center' to 'initialCenter'
          initialZoom: 15.0, // Changed from 'zoom' to 'initialZoom'
          onTap: (tapPosition, point) {
            setState(() {
              _selectedMapLocation = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:'com.ivyis.pawlli',
          ),
          MarkerLayer(
            markers: [
              if (_selectedMapLocation != null)
                Marker(
                  point: _selectedMapLocation!,  // required parameter
                  child: const Icon(  // Changed from 'builder' to 'child'
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                  width: 40, // Added width
                  height: 40, // Added height
                ),
            ],
          ),
        ],
      ),
      Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: ElevatedButton(
          onPressed: _confirmLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Confirm Location',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
      Positioned(
        top: 20,
        right: 20,
        child: FloatingActionButton(
          onPressed: () {
  if (_selectedMapLocation == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select a location")),
    );
    return;
  }
  _confirmLocation();
},

          child: const Icon(Icons.close),
        ),
      ),
    ],
  );
}
void _showImageSourceOptions() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows better positioning
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final screenHeight = MediaQuery.of(context).size.height;

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 80, // Moves it up
          left: 16,
          right: 16,
          top: 10, // Extra top padding
        ),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              "Select Image Source",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: FontFamily.Cairo,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.image, size: 25),
              title: Text(
                "Gallery",
                style: TextStyle(
                  fontSize: screenHeight * 0.020,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.Cairo,
                  color: Colours.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera, size: 25),
              title: Text(
                "Camera",
                style: TextStyle(
                  fontSize: screenHeight * 0.020,
                  fontWeight: FontWeight.w500,
                  fontFamily: FontFamily.Cairo,
                  color: Colours.black,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

Future<void> _getCurrentLocation() async {
  setState(() {
    _isLoadingLocation = true;
  });

  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Location services are disabled.';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Reverse geocoding
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;

      // Build a readable address string, e.g.:
      String address =
          "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

      setState(() {
        _selectedLocation = latLng.LatLng(position.latitude, position.longitude);
        _locationString = address;  // <-- Save this string for upload
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
    );
  } finally {
    setState(() {
      _isLoadingLocation = false;
    });
  }
}



@override
void dispose() {
  _tabController.dispose();
  donationAmountController.dispose();
  donationMessageController.dispose();
  donationPaymentService.disposeService();
  super.dispose();
}


  @override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
  appBar: AppBar(
      toolbarHeight: 60, 
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,

  flexibleSpace: Stack(
          children: [
            SizedBox(
              height: 100,
              width: 250,
              child: Image.asset(
                "assets/images/topimage.png",
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),

  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colours.brownColour),
    onPressed: () {
      Get.back();
    },
  ),

  title: Text(
    pageTitle,
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      fontFamily: FontFamily.Cairo,
      color: Colours.brownColour,
    ),
  ),

  bottom: TabBar(
    controller: _tabController,
    labelColor: Colours.primarycolour,
    unselectedLabelColor: Colors.black,
    indicatorColor: Colours.primarycolour,
    indicatorWeight: 3,
    tabs: const [
      Tab(text: "GoodByeBuddy"),
      Tab(text: "Donation"),
      Tab(text: "Requests"),
    ],
  ),
),
  body: Stack(
      children: [
        Column(
          children: [

            // 🔹 TAB CONTENT
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [

                  // ==================================================
                  // 🟢 TAB 1 — GOODBYEBUDDY (YOUR EXISTING FORM)
                  // ==================================================
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        SizedBox(height: 16),

                        Text('Location:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _openMapForLocationSelection,
                          child: Text("Select Location from Map"),
                        ),
                        if (_locationString != null)
                          Text("Address: $_locationString"),

                        SizedBox(height: 16),

                        // IMAGE PICKER
                        GestureDetector(
                          onTap: _showImageSourceOptions,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colours.black),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: Text("Upload Image")),
                            ),
                          ),
                        ),

                        if (_imageFiles != null && _imageFiles!.isNotEmpty)
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imageFiles!.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Image.file(
                                    File(_imageFiles![index].path),
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),

                        SizedBox(height: 16),

                         Text(
                          'Landmark:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: landmarkController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16), // ✅ RADIUS
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colours.primarycolour, width: 2),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        Text(
                          'Description:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: programDescriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16), // ✅ RADIUS
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colours.primarycolour, width: 2),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        Center(
                          child: ElevatedButton(
                            onPressed: () async {

                              // ✅ LOCATION VALIDATION
                              if (_locationString == null || _locationString!.isEmpty) {
                                safeSnackbar(
                                  "Location required",
                                  "Please select and confirm a location from the map",
                                  bg: Colors.red,
                                );
                                return;
                              }

                              // ✅ OTHER BASIC VALIDATION
                              if (landmarkController.text.trim().isEmpty ||
                                  programDescriptionController.text.trim().isEmpty ||
                                  _imageFiles == null ||
                                  _imageFiles!.isEmpty) {
                                safeSnackbar(
                                  "Missing details",
                                  "Please fill all fields and upload images",
                                  // snackPosition: SnackPosition.TOP,
                                  bg: Colors.orange,
                                  // colorText: Colors.white,
                                );
                                return;
                              }

                              // ✅ DEBUG (IMPORTANT)
                              print("📍 FINAL LOCATION STRING: $_locationString");

                              await goodByeBuddyController.uploadGoodByeBuddyData(
                                location: _locationString!,
                                latitude: _selectedLocation?.latitude,   // ✅ ADD THIS
                                longitude: _selectedLocation?.longitude, // ✅ ADD THIS
                                landmark: landmarkController.text.trim(),
                                description: programDescriptionController.text.trim(),
                                imageFiles: _imageFiles!
                                    .map((e) => File(e.path))
                                    .toList(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colours.primarycolour,
                              fixedSize: Size(screenWidth * 0.8, 50),
                            ),
                            child: const Text("Submit", style: TextStyle(color: Colors.white),),
                          ),

                        ),

                        SizedBox(height: 40),
                      ],
                    ),
                  ),

                  // ==================================================
                  // 🟢 TAB 2 — DONATION (ONLY 3 THINGS)
                  // ==================================================
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      children: [

                        SizedBox(height: 30),

                        Text(
                          "Support Paw ❤️",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 12),

                        Text(
                          "Your donation helps rescue, treat, and care for animals in need. "
                          "Every contribution supports food, medical care, and shelter.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),

                        SizedBox(height: 20),

                        TextField(
                          controller: donationAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter amount (₹)",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        SizedBox(height: 16),

                        TextField(
                          controller: donationMessageController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Word of support for the Pets",
                            contentPadding: EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colours.primarycolour, width: 2),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: () async {
                            final amount = double.tryParse(
                              donationAmountController.text.replaceAll(RegExp(r'[^\d.]'), ''),
                            );

                            if (amount == null || amount <= 0) {
                              safeSnackbar("Error", "Enter valid amount");
                              return;
                            }

                            await donationPaymentService.startDonation(amount: amount);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colours.primarycolour,
                            fixedSize: Size(screenWidth * 0.8, 50),
                          ),
                          child: const Text(
                            "Donate",
                            style: TextStyle(
                              color: Colors.white, // ✅ white text
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ==================================================
                  // 🟢 TAB 3 — REQUEST LIST
                  // ==================================================

                  isLoadingRequests
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {

                            final item = requests[index];

                            return GestureDetector(
                              onTap: () {

                                final isSuperUser =
                                    box.read(LocalStorageConstants.isSuperUser) == true;

                                if (isSuperUser) {
                                  Get.to(() => SuperUserRequestDetailsPage(
                                        requestId: item["id"],
                                      ));
                                } else {
                                  Get.to(() => UserRequestDetailsPage(
                                        requestId: item["id"],
                                      ));
                                }
                              },
                              child: Card(
                                elevation: 5,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff2e1c6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [

                                          Text(
                                            "Request No : ${item['id']}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: item["status"] == "completed"
                                                  ? Colors.green.shade100
                                                  : Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              item["status"],
                                              style: TextStyle(
                                                color: item["status"] == "completed"
                                                    ? Colors.green
                                                    : Colors.orange,
                                                // fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      Text(item["location"] ?? ""),

                                      const SizedBox(height: 8),

                                      Text(
                                        formatDateTime(item["created_at"] ?? ""),
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),

        
        
        // ================= MAP OVERLAY =================
        if (_showMap)
          Positioned.fill(
            child: Material(
              color: Colors.white,
              child: _buildMapView(),
            ),
          ),

        // ================= LOADING OVERLAY =================
        if (_isLoadingLocation)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    ),
  );
}

}