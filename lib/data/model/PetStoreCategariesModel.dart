class PetStoreCategoriesModel {
  String? message;
  List<Data>? data;
  int? status;

  PetStoreCategoriesModel({this.message, this.data, this.status});

  PetStoreCategoriesModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List)
          .map((v) => Data.fromJson(v))
          .toList();
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['message'] = message;
    if (data != null) {
      result['data'] = data!.map((v) => v.toJson()).toList();
    }
    result['status'] = status;
    return result;
  }
}

class Data {
  int? storeCategoryId;
  String? name;
  String? image;
  String? imageUrl;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? updatedBy;
  bool? isActive;

  Data({
    this.storeCategoryId,
    this.name,
    this.image,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.isActive,
  });

  Data.fromJson(Map<String, dynamic> json) {
    storeCategoryId = json['store_category_id'];
    name = json['name'];
    image = json['image'];
    imageUrl = json['image_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['store_category_id'] = storeCategoryId;
    result['name'] = name;
    result['image'] = image;
    result['image_url'] = imageUrl;
    result['created_at'] = createdAt;
    result['updated_at'] = updatedAt;
    result['created_by'] = createdBy;
    result['updated_by'] = updatedBy;
    result['is_active'] = isActive;
    return result;
  }
}
