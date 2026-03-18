import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/data/model/addressmodel.dart';

class AddressController extends GetxController {
  final box = GetStorage();

  Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  RxList<AddressModel> allAddresses = <AddressModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedAddresses();
  }

  // -------------------- LOAD SAVED --------------------
  void loadSavedAddresses() {
    final data = box.read("addresses") ?? [];

    allAddresses.value = List<Map<String, dynamic>>.from(data)
        .map((e) => AddressModel.fromJson(e))
        .toList();

    final saved = box.read("selectedAddress");
    if (saved != null) {
      selectedAddress.value = AddressModel.fromJson(saved);
    }
  }

  // -------------------- ADD ADDRESS --------------------
  void saveAddress(AddressModel model) {
    allAddresses.add(model);

    // Save all addresses
    box.write("addresses", allAddresses.map((e) => e.toJson()).toList());

    // Auto-select new address
    selectAddress(model);
  }

  // -------------------- SELECT ADDRESS --------------------
  void selectAddress(AddressModel model) {
    selectedAddress.value = model;
    box.write("selectedAddress", model.toJson());
  }

  // -------------------- UPDATE ADDRESS (🔥 New) --------------------
  void updateAddress(AddressModel oldAddress, AddressModel newAddress) {
    int index = allAddresses.indexOf(oldAddress);

    if (index != -1) {
      allAddresses[index] = newAddress;

      // Save to storage
      box.write("addresses", allAddresses.map((e) => e.toJson()).toList());

      // If edited address was selected → update selected
      if (selectedAddress.value == oldAddress) {
        selectAddress(newAddress);
      }

      allAddresses.refresh(); // refresh UI
    }
  }

  // -------------------- DELETE ADDRESS (Optional) --------------------
  void deleteAddress(AddressModel address) {
    allAddresses.remove(address);

    // Save remaining addresses
    box.write("addresses", allAddresses.map((e) => e.toJson()).toList());

    // If deleted address was selected → clear
    if (selectedAddress.value == address) {
      selectedAddress.value = null;
      box.remove("selectedAddress");
    }
  }
}
