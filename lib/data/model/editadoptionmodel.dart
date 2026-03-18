class Editadoptionmodel {
  final String? message;
  final UserAdoptionData? data;
  final int? status;

  Editadoptionmodel({this.message, this.data, this.status});

  factory Editadoptionmodel.fromJson(Map<String, dynamic> json) {
    return Editadoptionmodel(
      message: json['message'],
      data: json['data'] != null ? UserAdoptionData.fromJson(json['data']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
      'status': status,
    };
  }
}

class UserAdoptionData {
  final int? id;
  final String? message;
  final String? mobileNumber;
  final bool isAvailable;
  final bool isFree;
  final bool isPaid;
  final bool isSoldout;
  final String? requestedAt;
  final int? requestedBy;
  final dynamic category;
  final dynamic subcategory;
  final String? age;
  final String? gender;
  final String? location;
  final String? name;
  final dynamic preferences;
  final String? weight;
  final double? height;
  final String? microchipNumber;
  final int? owner;
  final String? petProfileImage;
  final String? description;
  final String? dateOfBirth;
  final bool isNeuteredOrSpayed;
  final String? createdAt;
  final String? updatedAt;

  UserAdoptionData({
    this.id,
    this.message,
    this.mobileNumber,
    bool? isAvailable,
    bool? isFree,
    bool? isPaid,
    bool? isSoldout,
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
    this.description,
    this.dateOfBirth,
    bool? neuteredOrSpayed,
    this.createdAt,
    this.updatedAt,
  }) : 
    isAvailable = isAvailable ?? false,
    isFree = isFree ?? false,
    isPaid = isPaid ?? false,
    isSoldout = isSoldout ?? false,
    isNeuteredOrSpayed = neuteredOrSpayed ?? false;

  factory UserAdoptionData.fromJson(Map<String, dynamic> json) {
    return UserAdoptionData(
      id: json['id'],
      message: json['message'],
      mobileNumber: json['mobile_number'],
      isAvailable: json['is_available'],
      isFree: json['is_free'],
      isPaid: json['is_paid'],
      isSoldout: json['is_soldout'],
      requestedAt: json['requested_at'],
      requestedBy: json['requested_by'],
      category: json['category'],
      subcategory: json['subcategory'],
      age: json['age'],
      gender: json['gender'],
      location: json['location'],
      name: json['name'],
      preferences: json['preferences'],
      weight: json['weight'],
      height: (json['height'] is int) ? (json['height'] as int).toDouble() : json['height'],
      microchipNumber: json['microchip_number'],
      owner: json['owner'],
      petProfileImage: json['pet_profile_image'],
      description: json['description'],
      dateOfBirth: json['date_of_birth'],
      neuteredOrSpayed: json['neutered_or_spayed'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
      'requested_at': requestedAt,
      'requested_by': requestedBy,
      'category': category,
      'subcategory': subcategory,
      'age': age,
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
      'neutered_or_spayed': isNeuteredOrSpayed,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}