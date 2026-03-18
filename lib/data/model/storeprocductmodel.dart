
class StoreProductModel {
  String? message;
  List<Data>? data;
  int? status;
  int totalStock = 0;
  

  StoreProductModel({this.message, this.data, this.status});

  StoreProductModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    
    final rawData = json['data'];

    if (rawData is List) {
      data = rawData.map((e) => Data.fromJson(e)).toList();
    } else {
      // SAFETY: backend sent wrong structure
      data = [];
    }
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    map['status'] = status;
    return map;
  }
}

class Data {
  int? storeproductId;
  int? selectedVariant;
  String? productName;
  String? productSlug;
  String? productDescription;
  String? productShortDescription;
  List<String>? productImages;
  String? stockKeepingUnit;
  String? regularPrice;
  String? discountedPrice;
  int? stockQuantity;
  String? productWeightKg;
  String? productDimensionsCm;
  String? productBrand;
  String? petType;
  String? ageGroup;
  List<String>? productFeatures;
  bool? isActive;
  bool? isFeatured;
  String? seoMetaTitle;
  String? seoMetaDescription;
  int? storeCategory;
  int? storeSubcategory;
  String? createdAt;
  String? updatedAt;
  CheapestVariant? cheapestVariant;
  bool? isOutOfStock;



  Data({
    this.storeproductId,
    this.selectedVariant,
    this.productName,
    this.productSlug,
    this.productDescription,
    this.productShortDescription,
    this.productImages,
    this.stockKeepingUnit,
    this.regularPrice,
    this.discountedPrice,
    this.stockQuantity,
    this.productWeightKg,
    this.productDimensionsCm,
    this.productBrand,
    this.petType,
    this.ageGroup,
    this.productFeatures,
    this.isActive,
    this.isFeatured,
    this.seoMetaTitle,
    this.seoMetaDescription,
    this.storeCategory,
    this.storeSubcategory,
    this.createdAt,
    this.updatedAt,
    this.cheapestVariant,
    this.isOutOfStock
  });

  Data.fromJson(Map<String, dynamic> json) {
    storeproductId = json['storeproduct_id'];
    selectedVariant = json['selected_variant'];
    productName = json['product_name'];
    productSlug = json['product_slug'];
    productDescription = json['product_description'];
    productShortDescription = json['product_short_description'];

    // ✅ HANDLE BOTH product_image (single) + product_images (list)

if (json['product_images'] != null && json['product_images'] is List) {
  productImages = List<String>.from(json['product_images']);
} 
else if (json['product_image'] != null) {
  productImages = [json['product_image']]; // convert single → list
} 
else {
  productImages = [];
}

    stockKeepingUnit = json['stock_keeping_unit'];
    regularPrice = json['regular_price'];
    discountedPrice = json['discounted_price'];
    stockQuantity = json['stock_quantity'];
    productWeightKg = json['product_weight_kg'];
    productDimensionsCm = json['product_dimensions_cm'];
    productBrand = json['product_brand'];
    petType = json['pet_type'];
    ageGroup = json['age_group'];

    if (json['product_features'] != null) {
      try {
        productFeatures = List<String>.from(json['product_features']);
      } catch (e) {
        productFeatures = json['product_features'] is List
    ? List<String>.from(json['product_features'])
    : [];

      }
    }

    isActive = json['is_active'];
    isFeatured = json['is_featured'];
    seoMetaTitle = json['seo_meta_title'];
    seoMetaDescription = json['seo_meta_description'];
    storeCategory = json['store_category'];
    storeSubcategory = json['store_subcategory'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    if (json['cheapest_variant'] != null) {
      cheapestVariant =
          CheapestVariant.fromJson(json['cheapest_variant']);
    }
    isOutOfStock = json['is_out_of_stock'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['storeproduct_id'] = storeproductId;
    map['selected_variant'] = selectedVariant;
    map['product_name'] = productName;
    map['product_slug'] = productSlug;
    map['product_description'] = productDescription;
    map['product_short_description'] = productShortDescription;
    map['product_images'] = productImages;
    map['stock_keeping_unit'] = stockKeepingUnit;
    map['regular_price'] = regularPrice;
    map['discounted_price'] = discountedPrice;
    map['stock_quantity'] = stockQuantity;
    map['product_weight_kg'] = productWeightKg;
    map['product_dimensions_cm'] = productDimensionsCm;
    map['product_brand'] = productBrand;
    map['pet_type'] = petType;
    map['age_group'] = ageGroup;
    map['product_features'] = productFeatures;
    map['is_active'] = isActive;
    map['is_featured'] = isFeatured;
    map['seo_meta_title'] = seoMetaTitle;
    map['seo_meta_description'] = seoMetaDescription;
    map['store_category'] = storeCategory;
    map['store_subcategory'] = storeSubcategory;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['cheapest_variant'] = cheapestVariant;
    map['is_out_of_stock'] = isOutOfStock;


    return map;
  }

  double get displayPrice {
  if (cheapestVariant != null) {
    return cheapestVariant!.discountedPrice ??
           cheapestVariant!.regularPrice;
  }

  // fallback (safety)
  return double.tryParse(discountedPrice ?? regularPrice ?? '0') ?? 0;
}

bool get hasDiscount {
  if (cheapestVariant == null) return false;

  final d = cheapestVariant!.discountedPrice;
  return d != null && d < cheapestVariant!.regularPrice;
}

}

class CheapestVariant {
  final int variantId;
  final String? variantName;
  final double regularPrice;
  final double? discountedPrice;

  CheapestVariant({
    required this.variantId,
    this.variantName,
    required this.regularPrice,
    this.discountedPrice,
  });

  factory CheapestVariant.fromJson(Map<String, dynamic> json) {
    return CheapestVariant(
      variantId: json['variant_id'],
      variantName: json['variant_name'],
      regularPrice: (json['regular_price'] as num).toDouble(),
      discountedPrice: json['discounted_price'] != null
          ? (json['discounted_price'] as num).toDouble()
          : null,
    );
  }
}

