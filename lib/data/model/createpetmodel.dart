class CreatePetModel {
  String? message;
  Data? data;

  CreatePetModel({this.message, this.data});

  CreatePetModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }}
class Data {
  int? petId;
  String? name;
  Age? age;
  String? breed;
  String? gender;
  double? weight;
  double? height;
  Preferences? preferences;
  String? microchipNumber;
  String? location;
  String? description;
  String? petProfileImage; 
  String? createdAt;
  String? updatedAt;
  bool? isActive;
  String? dateOfBirth;
  int? category;
  int? subcategory;
  int? owner;
  int? createdBy;
  int? updatedBy;

  Data({
    this.petId,
    this.name,
    this.age,
    this.breed,
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
    this.category,
    this.subcategory,
    this.owner,
    this.createdBy,
    this.updatedBy,
  });

  Data.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    name = json['name'];
    age = json['age'] != null ? Age.fromJson(json['age']) : null;
    breed = json['breed'];
    gender = json['gender'];
    weight = (json['weight'] is int) ? (json['weight'] as int).toDouble() : json['weight'];
    height = (json['height'] is int) ? (json['height'] as int).toDouble() : json['height'];
    preferences = json['preferences'] != null ? Preferences.fromJson(json['preferences']) : null;
    microchipNumber = json['microchip_number'];
    location = json['location'];
    description = json['description'];
    petProfileImage = json['pet_profile_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isActive = json['is_active'];
    dateOfBirth = json['date_of_birth'];
    category = json['category'];
    subcategory = json['subcategory'];
    owner = json['owner'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['name'] = name;
    if (age != null) {
      data['age'] = age!.toJson();
    }
    data['breed'] = breed;
    data['gender'] = gender;
    data['weight'] = weight;
    data['height'] = height;
    if (preferences != null) {
      data['preferences'] = preferences!.toJson();
    }
    data['microchip_number'] = microchipNumber;
    data['location'] = location;
    data['description'] = description;
    data['pet_profile_image'] = petProfileImage;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_active'] = isActive;
    data['date_of_birth'] = dateOfBirth;
    data['category'] = category;
    data['subcategory'] = subcategory;
    data['owner'] = owner;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    return data;
  }
}


class Age {
  int? years;
  int? months;

  Age({this.years, this.months});

  Age.fromJson(Map<String, dynamic> json) {
    years = json['years'];
    months = json['months'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['years'] = years;
    data['months'] = months;
    return data;
  }
}

class Preferences {
  String? food;
  String? toys;

  Preferences({this.food, this.toys});

  Preferences.fromJson(Map<String, dynamic> json) {
    food = json['food'];
    toys = json['toys'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['food'] = this.food;
    data['toys'] = this.toys;
    return data;
  }
  
}
