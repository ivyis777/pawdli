import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/addresscontroller.dart';
import 'package:pawlli/data/model/addressmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/pet store/add_addresspage.dart';

class AddressListPage extends StatelessWidget {
  AddressListPage({super.key});

  final AddressController addressController = Get.find<AddressController>();

  // ---------------------------------------------------------
  // ⭐ USE CURRENT LOCATION
  // ---------------------------------------------------------
  Future<void> _selectCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
            msg: "Enable location permission from settings");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isEmpty) {
        Fluttertoast.showToast(msg: "Unable to fetch address");
        return;
      }

      final p = placemarks.first;

      final result = await Get.to(() => AddAddressPage(
            fromLocation: true,
            street: p.street ?? "",
            area: p.subLocality ?? "",
            city: p.locality ?? "",
            state: p.administrativeArea ?? "",
            pincode: p.postalCode ?? "",
          ));

      if (result != null && result is AddressModel) {
        addressController.saveAddress(result);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Location error");
    }
  }

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------- APP BAR WITH TOP IMAGE ----------------
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Select Address"),
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Stack(
          children: [
            Positioned(
              top: 1,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height * 0.10,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Assets.images.topimage.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ---------------- ADD ADDRESS FAB ----------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colours.brownColour,
        onPressed: () async {
          final newAddress = await Get.to(() => AddAddressPage());
          if (newAddress != null && newAddress is AddressModel) {
            addressController.saveAddress(newAddress);
          }
        },
        child: const Icon(Icons.add, color: Colors.white,),
      ),

      // ---------------- USE CURRENT LOCATION (BOTTOM) ----------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: SafeArea(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.my_location, color: Colors.white),
            label: const Text(
              "Use Current Location",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            onPressed: _selectCurrentLocation,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: Colours.primarycolour,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ),

      // ---------------- ADDRESS LIST ----------------
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Obx(() {
        return addressController.allAddresses.isEmpty
            ? const Center(child: Text("No addresses found. Add one."))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 90),
                itemCount: addressController.allAddresses.length,
                itemBuilder: (ctx, i) {
                  final addr = addressController.allAddresses[i];

                  return Card(
                    color: const Color.fromARGB(255, 251, 236, 210),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: ListTile(
                      title: Text(addr.name),
                      subtitle: Text(
                        "${addr.phone}\n${addr.address}",
                        maxLines: 3,
                      ),
                      isThreeLine: true,
                      onTap: () {
                        addressController.selectAddress(addr);
                        Get.back(result: true);
                      },
                      trailing: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final updated = await Get.to(
                                () => AddAddressPage(editAddress: addr),
                              );
                              if (updated != null &&
                                  updated is AddressModel) {
                                addressController.updateAddress(addr, updated);
                              }
                            },
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              addressController.deleteAddress(addr);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
      }),
    );
  }
}
