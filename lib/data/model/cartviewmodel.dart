class CartViewModel {
  final String? message;
  final List<Data> data;
  final int? status;

  CartViewModel({
    this.message,
    this.data = const [],
    this.status,
  });

  factory CartViewModel.fromJson(Map<String, dynamic> json) {
    return CartViewModel(
      message: json['message'],
      data: (json['data'] as List?)
              ?.map((v) => Data.fromJson(v))
              .toList() ??
          [],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'data': data.map((v) => v.toJson()).toList(),
        'status': status,
      };
}

// ----------------------------------------------------

class Data {
  final int? cartId;
  final int? user;
  final int? storeProduct;
  final String? storeProductName;

  final Map<String, dynamic>? storeProductDetails;
  final Map<String, dynamic>? variantDetails;

  final int? storeProductVariant;
  final String? variantName;
  final int? quantity;
  final String? priceAtAdded;
  final String? appliedDiscount;
  final String? subtotal;
  final bool? isCheckedOut;
  final String? addedAt;
  final String? updatedAt;
  final bool? isActive;

  /// Auto-generated image fields
  final String? productImage;
  final String? variantImage;

  Data({
    this.cartId,
    this.user,
    this.storeProduct,
    this.storeProductName,
    this.storeProductDetails,
    this.variantDetails,
    this.storeProductVariant,
    this.variantName,
    this.quantity,
    this.priceAtAdded,
    this.appliedDiscount,
    this.subtotal,
    this.isCheckedOut,
    this.addedAt,
    this.updatedAt,
    this.isActive,
    this.productImage,
    this.variantImage,
  });

  factory Data.fromJson(Map<String, dynamic> json) {

    final productDetails = json["store_product_details"] ?? {};
    final variantDetails = json["variant_details"] ?? {};

    String? vImage;
    if (variantDetails["product_images"] != null &&
        variantDetails["product_images"] is List &&
        variantDetails["product_images"].isNotEmpty) {
      vImage = variantDetails["product_images"][0];
    }

    String? pImage;
    if (productDetails["product_images"] != null &&
        productDetails["product_images"] is List &&
        productDetails["product_images"].isNotEmpty) {
      pImage = productDetails["product_images"][0];
    }

    return Data(
      cartId: json['cart_id'],
      user: json['user'],
      storeProduct: json['store_product'],
      storeProductName: json['store_product_name'],

      storeProductDetails: productDetails,
      variantDetails: variantDetails,

      storeProductVariant: json['store_product_variant'],
      variantName: json['variant_name'],
      quantity: json['quantity'],
      priceAtAdded: json['price_at_added'],
      appliedDiscount: json['applied_discount'],
      subtotal: json['subtotal'],
      isCheckedOut: json['is_checked_out'],
      addedAt: json['added_at'],
      updatedAt: json['updated_at'],
      isActive: json['is_active'],

      productImage: pImage,
      variantImage: vImage,
    );
  }

  Map<String, dynamic> toJson() => {
        'cart_id': cartId,
        'user': user,
        'store_product': storeProduct,
        'store_product_name': storeProductName,
        'store_product_details': storeProductDetails,
        'variant_details': variantDetails,
        'store_product_variant': storeProductVariant,
        'variant_name': variantName,
        'quantity': quantity,
        'price_at_added': priceAtAdded,
        'applied_discount': appliedDiscount,
        'subtotal': subtotal,
        'is_checked_out': isCheckedOut,
        'added_at': addedAt,
        'updated_at': updatedAt,
        'is_active': isActive,

        'product_image': productImage,
        'variant_image': variantImage,
      };
}
