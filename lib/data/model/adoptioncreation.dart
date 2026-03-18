class AdoptionCreationResponse {
  final String? message;
  final AdoptionData? data;

  AdoptionCreationResponse({
    required this.message,
    required this.data,
  });

  factory AdoptionCreationResponse.fromJson(Map<String, dynamic> json) {
    return AdoptionCreationResponse(
      message: json['message'],
      data: json['data'] != null ? AdoptionData.fromJson(json['data']) : null,
    );
  }
}

class AdoptionData {
  final int id;
  final String? message;
  final String? mobileNumber;
  final bool? isAvailable;
  final bool? isFree;
  final bool? isPaid;
  final bool? isSoldout;
  final DateTime? requestedAt;
  final int? requestedBy;
  final dynamic category;
  final dynamic subcategory;
  final String? age;
  final String? gender;
  final String? location;
  final String? name;
  final String? preferences;
  final String? weight;
  final double? height;
  final String? microchipNumber;
  final dynamic owner;
  final String? petProfileImage;
  final String description;
  final String? dateOfBirth;
  final bool? neuteredOrSpayed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdoptionData({
    required this.id,
    this.message,
    this.mobileNumber,
    this.isAvailable,
    this.isFree,
    this.isPaid,
    this.isSoldout,
    this.requestedAt,
    this.requestedBy,
    this.category,
    this.subcategory,
    this.age,
    this.gender,
    this.location,
    this.name,
    this.preferences,
    this.weight,
    this.height,
    this.microchipNumber,
    this.owner,
    this.petProfileImage,
    required this.description,
    this.dateOfBirth,
    this.neuteredOrSpayed,
    this.createdAt,
    this.updatedAt,
  });

  factory AdoptionData.fromJson(Map<String, dynamic> json) {
    return AdoptionData(
      id: json['id'],
      message: json['message'],
      mobileNumber: json['mobile_number'],
      isAvailable: json['is_available'],
      isFree: json['is_free'],
      isPaid: json['is_paid'],
      isSoldout: json['is_soldout'],
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'])
          : null,
      requestedBy: json['requested_by'],
      category: json['category'],
      subcategory: json['subcategory'],
      age: json['age'],
      gender: json['gender'],
      location: json['location'],
      name: json['name'],
      preferences: json['preferences'],
      weight: json['weight']?.toString(), // always safely as String?
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      microchipNumber: json['microchip_number'],
      owner: json['owner'],
      petProfileImage: json['pet_profile_image'],
      description: json['description'],
      dateOfBirth: json['date_of_birth'],
      neuteredOrSpayed: json['neutered_or_spayed'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
