class UserAdoptionModel {
  final int id;
  final String? message;
  final String? mobileNumber;
  final bool isAvailable;
  final bool isFree;
  final bool isPaid;
  final bool isSoldout;
  final DateTime requestedAt;
  final int? requestedBy;
  final int? category;
  final String? categoryName;
  final int? subcategory;
  final String? subcategoryName;

  // 🔥 FIXED AGE STRUCTURE
  final AgeDetails? ageDetails;

  final String gender;
  final String? location;
  final String name;
  final dynamic preferences;
  final String weight;
  final double height;
  final String? microchipNumber;
  final int? owner;
  final String? petProfileImage;
  final String description;
  final String? dateOfBirth;
  final bool? neuteredOrSpayed;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserAdoptionModel({
    required this.id,
    this.message,
    this.mobileNumber,
    required this.isAvailable,
    required this.isFree,
    required this.isPaid,
    required this.isSoldout,
    required this.requestedAt,
    this.requestedBy,
    this.category,
    this.categoryName,
    this.subcategory,
    this.subcategoryName,
    this.ageDetails,
    required this.gender,
    this.location,
    required this.name,
    this.preferences,
    required this.weight,
    required this.height,
    this.microchipNumber,
    this.owner,
    this.petProfileImage,
    required this.description,
    this.dateOfBirth,
    this.neuteredOrSpayed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAdoptionModel.fromJson(Map<String, dynamic> json) {
    return UserAdoptionModel(
      id: json['id'] ?? 0,
      message: json['message'],
      mobileNumber: json['mobile_number'],
      isAvailable: json['is_available'] ?? false,
      isFree: json['is_free'] ?? false,
      isPaid: json['is_paid'] ?? false,
      isSoldout: json['is_soldout'] ?? false,
      requestedAt:
          DateTime.tryParse(json['requested_at'] ?? '') ?? DateTime.now(),
      requestedBy: json['requested_by'],
      category: json['category'],
      categoryName: json['category_name'],
      subcategory: json['subcategory'],
      subcategoryName: json['subcategory_name'],

      // ✅ AGE OBJECT PARSING (IMPORTANT)
      ageDetails: json['age'] != null && json['age'] is Map<String, dynamic>
          ? AgeDetails.fromJson(json['age'])
          : null,

      gender: json['gender'] ?? '',
      location: json['location'],
      name: json['name'] ?? '',
      preferences: json['preferences'],
      weight: json['weight']?.toString() ?? '',
      height: (json['height'] is num)
          ? (json['height'] as num).toDouble()
          : 0.0,
      microchipNumber: json['microchip_number'],
      owner: json['owner'],
      petProfileImage: json['pet_profile_image'],
      description: json['description'] ?? '',
      dateOfBirth: json['date_of_birth'],
      neuteredOrSpayed: json['neutered_or_spayed'],
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'mobile_number': mobileNumber,
      'is_available': isAvailable,
      'is_free': isFree,
      'is_paid': isPaid,
      'is_soldout': isSoldout,
      'requested_at': requestedAt.toIso8601String(),
      'requested_by': requestedBy,
      'category': category,
      'category_name': categoryName,
      'subcategory': subcategory,
      'subcategory_name': subcategoryName,
      'age': ageDetails?.toJson(),
      'gender': gender,
      'location': location,
      'name': name,
      'preferences': preferences,
      'weight': weight,
      'height': height,
      'microchip_number': microchipNumber,
      'owner': owner,
      'pet_profile_image': petProfileImage,
      'description': description,
      'date_of_birth': dateOfBirth,
      'neutered_or_spayed': neuteredOrSpayed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// ✅ AGE DETAILS MODEL
class AgeDetails {
  final int? years;
  final int? months;
  final int? days;

  AgeDetails({this.years, this.months, this.days});

  factory AgeDetails.fromJson(Map<String, dynamic> json) {
    return AgeDetails(
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
}
