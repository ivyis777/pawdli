class StoreProductInventory {
  final int inventoryId;
  final int storeProductVariant;
  final String variantName;
  final int quantityInStock;
  final int quantityReserved;

  StoreProductInventory({
    required this.inventoryId,
    required this.storeProductVariant,
    required this.variantName,
    required this.quantityInStock,
    required this.quantityReserved,
  });

  factory StoreProductInventory.fromJson(Map<String, dynamic> json) {
    return StoreProductInventory(
      inventoryId: json['inventory_id'],
      storeProductVariant: json['store_product_variant'],
      variantName: json['variant_name'],
      quantityInStock: json['quantity_in_stock'],
      quantityReserved: json['quantity_reserved'],
    );
  }
}
