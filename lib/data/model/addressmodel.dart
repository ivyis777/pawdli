class AddressModel {
  final String name;
  final String phone;
  final String email;
  final String address;

  AddressModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
      };

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      name: json["name"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      address: json["address"] ?? "",
    );
  }
}
