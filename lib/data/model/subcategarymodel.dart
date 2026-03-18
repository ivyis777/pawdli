class SubCategoriesModel {
  String? message;
  List<Data>? data;
  int? status;

  SubCategoriesModel({this.message, this.data, this.status});


  factory SubCategoriesModel.fromJson(Map<String, dynamic> json) {
    return SubCategoriesModel(
      message: json['message'],
      data: json['data'] != null
          ? List<Data>.from(json['data'].map((v) => Data.fromJson(v)))
          : null,
      status: json['status'],
    );
  }

  // Method to serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.map((v) => v.toJson()).toList(),
      'status': status,
    };
  }
}
class Data {
  int? subcategoryId;
  String? name;
  String? image;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? updatedBy;
  bool? isActive;
  int? category;

  Data({
    this.subcategoryId,
    this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.isActive,
    this.category,
    
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      subcategoryId: json['subcategory_id'],
      name: json['name'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      isActive: json['is_active'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subcategory_id': subcategoryId,
      'name': name,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'is_active': isActive,
      'category': category,
    };
  }
}

class Age {
  int? years;
  int? months;
  int? days;
  String? date;

  Age({this.years, this.months, this.days, this.date});

  factory Age.fromJson(Map<String, dynamic> json) {
    return Age(
      years: json['years'],
      months: json['months'],
      days: json['days'],
      date: json['date'],
    );
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

