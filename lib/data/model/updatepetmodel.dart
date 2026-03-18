class UpdatePetModel {
  final String message;
  final PetData data;

  UpdatePetModel({required this.message, required this.data});

  factory UpdatePetModel.fromJson(Map<String, dynamic> json) {
    return UpdatePetModel(
      message: json['message'],
      data: PetData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

class PetData {
  final int petId;
  final String? categoryName;
  final String? subcategoryName;
  final String name;
  final Age? age;  // Added Age field here
  final String gender;
  final double weight;
  final double height;
  final Map<String, dynamic> preferences;
  final String? microchipNumber; // Made nullable because JSON shows null sometimes
  final String location;
  final String description;
  final String? petProfileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String dateOfBirth; // should be in format: YYYY-MM-DD
  final bool neuteredOrSpayed;
  final int category;
  final int subcategory;
  final int owner;

  PetData({
    required this.petId,
    this.categoryName,
    this.subcategoryName,
    required this.name,
    this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.preferences,
    this.microchipNumber,
    required this.location,
    required this.description,
    required this.petProfileImage,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.dateOfBirth,
    required this.neuteredOrSpayed,
    required this.category,
    required this.subcategory,
    required this.owner,
  });

  factory PetData.fromJson(Map<String, dynamic> json) {
    return PetData(
      petId: json['pet_id'],
      categoryName: json['category_name'],
      subcategoryName: json['subcategory_name'],
      name: json['name'],
      age: json['age'] != null ? Age.fromJson(json['age']) : null,  // Parse age here
      gender: json['gender'],
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      preferences: json['preferences'] ?? {},
      microchipNumber: json['microchip_number'],
      location: json['location'],
      description: json['description'],
      petProfileImage: json['pet_profile_image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'],
      dateOfBirth: json['date_of_birth'],
      neuteredOrSpayed: json['neutered_or_spayed'],
      category: json['category'],
      subcategory: json['subcategory'],
      owner: json['owner'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'pet_id': petId,
      if (categoryName != null) 'category_name': categoryName,
      if (subcategoryName != null) 'subcategory_name': subcategoryName,
      'name': name,
      'gender': gender,
      'weight': weight,
      'height': height,
      'preferences': preferences,
      'microchip_number': microchipNumber,
      'location': location,
      'description': description,
      'pet_profile_image': petProfileImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'date_of_birth': dateOfBirth,
      'neutered_or_spayed': neuteredOrSpayed,
      'category': category,
      'subcategory': subcategory,
      'owner': owner,
    };
    if (age != null) {
      data['age'] = age!.toJson();
    }
    return data;
  }
}

class Age {
  final int years;
  final int months;

  Age({required this.years, required this.months});

  factory Age.fromJson(Map<String, dynamic> json) {
    return Age(
      years: json['years'] ?? 0,
      months: json['months'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'years': years,
      'months': months,
    };
  }
}
