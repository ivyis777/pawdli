class PetsListModel {
  int? status;
  String? message;
  List<Data>? data;

  PetsListModel({this.status, this.message, this.data});

  PetsListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class Data {
  int? petId;
  String? categoryName;
  String? subcategoryName;
  String? name;
  Age? age; // Updated here
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
  bool? neuteredOrSpayed;
  int? category;
  int? subcategory;
  int? owner;

  Data({
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

  Data.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    categoryName = json['category_name'];
    subcategoryName = json['subcategory_name'];
    name = json['name'];
    age = json['age'] != null ? Age.fromJson(json['age']) : null; // updated
    gender = json['gender'];
    weight = json['weight'];
    height = json['height'];
    preferences = json['preferences'] != null
        ? Preferences.fromJson(json['preferences'])
        : null;
    microchipNumber = json['microchip_number'];
    location = json['location'];
    description = json['description'];
    petProfileImage = json['pet_profile_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isActive = json['is_active'];
    dateOfBirth = json['date_of_birth'];
    neuteredOrSpayed = json['neutered_or_spayed'];
    category = json['category'];
    subcategory = json['subcategory'];
    owner = json['owner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['category_name'] = categoryName;
    data['subcategory_name'] = subcategoryName;
    data['name'] = name;
    if (age != null) data['age'] = age!.toJson(); // updated
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
    data['neutered_or_spayed'] = neuteredOrSpayed;
    data['category'] = category;
    data['subcategory'] = subcategory;
    data['owner'] = owner;
    return data;
  }
}
class Age {
  int? years;
  int? months;
  int? days; // Optional days field
  String? date; // New field for age as of a specific date

  Age({this.years, this.months, this.days, this.date});

  Age.fromJson(Map<String, dynamic> json) {
    years = json['years'];
    months = json['months'];
    days = json['days'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    return {
      'years': years,
      'months': months,
      'days': days,
      'date': date,
    };
  }
}



class Preferences {
  String? likes;
  String? dislikes;
  String? food;

  Preferences({this.likes, this.dislikes, this.food});

  Preferences.fromJson(Map<String, dynamic> json) {
    likes = json['likes'];
    dislikes = json['dislikes'];
    food = json['food'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['likes'] = this.likes;
    data['dislikes'] = this.dislikes;
    data['food'] = this.food;
    return data;
  }
}
