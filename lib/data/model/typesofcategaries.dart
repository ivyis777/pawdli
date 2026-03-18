class AllCategoriesModel {
  String? message;
  List<Data>? data;
  int? status;

  AllCategoriesModel({this.message, this.data, this.status});

  AllCategoriesModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = List<Data>.from(json['data'].map((v) => Data.fromJson(v)));
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['message'] = message;
    if (data != null) {
      json['data'] = data!.map((v) => v.toJson()).toList();
    }
    json['status'] = status;
    return json;
  }
}

class Data {
  int? categoryId;
  String? name;
  String? description;
  String? image; // ✅ Added image field
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? updatedBy;
  bool? isActive;

  Data({
    this.categoryId,
    this.name,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.isActive,
  });

  Data.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    name = json['name'];
    description = json['description'];
    image = json['image']; // ✅ Parsing image
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['category_id'] = categoryId;
    json['name'] = name;
    json['description'] = description;
    json['image'] = image; // ✅ Serializing image
    json['created_at'] = createdAt;
    json['updated_at'] = updatedAt;
    json['created_by'] = createdBy;
    json['updated_by'] = updatedBy;
    json['is_active'] = isActive;
    return json;
  }
}
