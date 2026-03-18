class SingleCategoryModel {
  int? petId;
  String? categoryName;
  String? subcategoryName;
  String? name;
  int? age; // still kept for backward compatibility
  Age? ageDetails; // new structured age field
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

  SingleCategoryModel({
    this.petId,
    this.categoryName,
    this.subcategoryName,
    this.name,
    this.age,
    this.ageDetails,
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

  SingleCategoryModel.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    categoryName = json['category_name'];
    subcategoryName = json['subcategory_name'];
    name = json['name'];

    // Age handling
    final ageField = json['age'];
    if (ageField is Map) {
      ageDetails = Age.fromJson(Map<String, dynamic>.from(ageField));
    } else if (ageField is int) {
      age = ageField;
    } else if (ageField is double) {
      age = ageField.toInt();
    }

    gender = json['gender'];
    weight = (json['weight'] is int)
        ? (json['weight'] as int).toDouble()
        : json['weight'] as double?;
    height = (json['height'] is int)
        ? (json['height'] as int).toDouble()
        : json['height'] as double?;
    preferences = json['preferences'] != null
        ? Preferences.fromJson(json['preferences'])
        : null;
    microchipNumber = json['microchip_number'];
    location = json['location'];
    description = json['description'];
    petProfileImage = json['pet_profile_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isActive = json['is_active'] is bool
        ? json['is_active']
        : json['is_active'].toString() == 'true';
    dateOfBirth = json['date_of_birth'];
    neuteredOrSpayed = json['neutered_or_spayed'] is bool
        ? json['neutered_or_spayed']
        : json['neutered_or_spayed'].toString() == 'true';

    category = json['category'] is int
        ? json['category']
        : (json['category'] is Map ? json['category']['id'] : null);

    subcategory = json['subcategory'] is int
        ? json['subcategory']
        : (json['subcategory'] is Map ? json['subcategory']['id'] : null);

    owner = json['owner'] is int
        ? json['owner']
        : (json['owner'] is Map ? json['owner']['id'] : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['category_name'] = categoryName;
    data['subcategory_name'] = subcategoryName;
    data['name'] = name;

    // Age serialization
    if (ageDetails != null) {
      data['age'] = ageDetails!.toJson();
    } else {
      data['age'] = age;
    }

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
  int? days;

  Age({this.years, this.months, this.days});

  factory Age.fromJson(Map<String, dynamic> json) {
    return Age(
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

class Preferences {
  String? likes;
  String? dislikes;

  Preferences({this.likes, this.dislikes});

  Preferences.fromJson(Map<String, dynamic> json) {
    likes = json['likes'];
    dislikes = json['dislikes'];
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'dislikes': dislikes,
    };
  }
}
