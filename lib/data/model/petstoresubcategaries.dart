class PetStoreSubCategoriesModel {
  String? message;
  List<SubCategoryData>? data;
  int? status;

  PetStoreSubCategoriesModel({this.message, this.data, this.status});

  PetStoreSubCategoriesModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List)
          .map((v) => SubCategoryData.fromJson(v))
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

class SubCategoryData {
  int? storeSubcategoryId;
  int? storeCategory;
  String? name;
  String? image;
  String? imageUrl;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? updatedBy;
  bool? isActive;

  SubCategoryData({
    this.storeSubcategoryId,
    this.storeCategory,
    this.name,
    this.image,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.isActive,
  });

  SubCategoryData.fromJson(Map<String, dynamic> json) {
    storeSubcategoryId = json['store_subcategory_id'];
    storeCategory = json['store_category'];
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
    result['store_subcategory_id'] = storeSubcategoryId;
    result['store_category'] = storeCategory;
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
