class StoreProductVariant {
  final int variantId;
  final int storeProductId;
  final String? variantName;
  final String? variantSku;
  final String? regularPrice;
  final String? discountedPrice;
  final String? productWeightKg;
  final String? productDimensionsCm;
  final List<String> productImages;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  // 🔥 NEW INVENTORY FIELDS
  int quantityInStock;
  int quantityReserved;
  int lowStockThreshold;

  StoreProductVariant({
    required this.variantId,
    required this.storeProductId,
    this.variantName,
    this.variantSku,
    this.regularPrice,
    this.discountedPrice,
    this.productWeightKg,
    this.productDimensionsCm,
    required this.productImages,
    required this.isActive,
    this.createdAt,
    this.updatedAt,

    // NEW
    this.quantityInStock = 0,
    this.quantityReserved = 0,
    this.lowStockThreshold = 0,
  });

  factory StoreProductVariant.fromJson(Map<String, dynamic> json) {
    return StoreProductVariant(
      variantId: int.tryParse(json['variant_id']?.toString() ?? '0') ?? 0,
      storeProductId: int.tryParse(json['storeproduct']?.toString() ?? '0') ?? 0,

      variantName: json['variant_name']?.toString(),
      variantSku: json['variant_sku']?.toString(),
      regularPrice: json['regular_price']?.toString(),
      discountedPrice: json['discounted_price']?.toString(),
      productWeightKg: json['product_weight_kg']?.toString(),
      productDimensionsCm: json['product_dimensions_cm']?.toString(),

      productImages: json['product_images'] != null
          ? List<String>.from(
              (json['product_images'] as List).map((e) => e.toString()),
            )
          : <String>[],

      isActive: json['is_active'] == true,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// ⭐ helper → available stock
  int get availableStock => quantityInStock - quantityReserved;
}
