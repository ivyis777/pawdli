class PetAge {
  final int? years;
  final int? months;
  final int? days;

  PetAge({this.years, this.months, this.days});

  factory PetAge.fromJson(Map<String, dynamic> json) {
    return PetAge(
      years: json['years'],
      months: json['months'],
      days: json['days'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'years': years,
      'months': months,
      'days': days,
    };
  }

  @override
  String toString() {
    return '${years ?? 0}y ${months ?? 0}m ${days ?? 0}d';
  }
}

class PetDescription {
  final int? petId;
  final String? categoryName;
  final String? subcategoryName;
  final String? name;
  final PetAge? age;
  final String? gender;
  final double? weight;
  final double? height;
  final Map<String, dynamic>? preferences;
  final String? microchipNumber;
  final String? location;
  final String? description;
  final String? petProfileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;
  final String? dateOfBirth;
  final bool? neuteredOrSpayed;
  final int? category;
  final int? subcategory;
  final int? owner;

  PetDescription({
    this.petId,
    this.categoryName,
    this.subcategoryName,
    this.name,
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.preferences,
    this.microchipNumber,
    this.location,
    this.description,
    this.petProfileImage,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.dateOfBirth,
    this.neuteredOrSpayed,
    this.category,
    this.subcategory,
    this.owner,
  });

  factory PetDescription.fromJson(Map<String, dynamic> json) {
    return PetDescription(
      petId: json['pet_id'],
      categoryName: json['category_name'],
      subcategoryName: json['subcategory_name'],
      name: json['name'],
      age: json['age'] != null ? PetAge.fromJson(json['age']) : null,
      gender: json['gender'],
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      preferences: json['preferences'] != null ? Map<String, dynamic>.from(json['preferences']) : null,
      microchipNumber: json['microchip_number'],
      location: json['location'],
      description: json['description'],
      petProfileImage: json['pet_profile_image'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isActive: json['is_active'],
      dateOfBirth: json['date_of_birth'],
      neuteredOrSpayed: json['neutered_or_spayed'],
      category: json['category'],
      subcategory: json['subcategory'],
      owner: json['owner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'category_name': categoryName,
      'subcategory_name': subcategoryName,
      'name': name,
      'age': age?.toJson(),
      'gender': gender,
      'weight': weight,
      'height': height,
      'preferences': preferences,
      'microchip_number': microchipNumber,
      'location': location,
      'description': description,
      'pet_profile_image': petProfileImage,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'date_of_birth': dateOfBirth,
      'neutered_or_spayed': neuteredOrSpayed,
      'category': category,
      'subcategory': subcategory,
      'owner': owner,
    };
  }
}
