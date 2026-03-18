import '../../../data/model/cartviewmodel.dart';

extension DataCopy on Data {
  Data copyWithData({
    int? cartId,
    int? user,
    int? storeProduct,
    String? storeProductName,
    int? storeProductVariant,
    String? variantName,
    int? quantity,
    String? priceAtAdded,
    String? appliedDiscount,
    String? subtotal,
    bool? isCheckedOut,
    String? addedAt,
    String? updatedAt,
    bool? isActive,
  }) {
    return Data(
      cartId: cartId ?? this.cartId,
      user: user ?? this.user,
      storeProduct: storeProduct ?? this.storeProduct,
      storeProductName: storeProductName ?? this.storeProductName,
      storeProductVariant: storeProductVariant ?? this.storeProductVariant,
      variantName: variantName ?? this.variantName,
      quantity: quantity ?? this.quantity,
      priceAtAdded: priceAtAdded ?? this.priceAtAdded,
      appliedDiscount: appliedDiscount ?? this.appliedDiscount,
      subtotal: subtotal ?? this.subtotal,
      isCheckedOut: isCheckedOut ?? this.isCheckedOut,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
