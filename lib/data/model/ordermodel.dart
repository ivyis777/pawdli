
class OrderItem {
  final int orderItemId;
  final int productId;
  final String productName;
  final List<String> productImages;
  final String? productImage;
  final int variantId;
  final String? variantName;
  final List<String> variantImages;
  final int quantity;
  final double price;
  final double totalPrice;

  OrderItem({
    required this.orderItemId,
    required this.productId,
    required this.productName,
    required this.productImages,
    this.productImage, 
    required this.variantId,
    this.variantName,
    required this.variantImages,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: json['order_item_id'] ?? 0,
      productId: json['product'] ?? 0,
      productName: json['product_name'] ?? "",
      productImages: json['product_images'] != null
          ? List<String>.from(json['product_images'])
          : [],
      productImage: json['product_image'],
      variantId: json['variant'] ?? 0,
      variantName: json['variant_name'],
      variantImages: json['variant_product_images'] != null
          ? List<String>.from(json['variant_product_images'])
          : [],
      quantity: json['quantity'] ?? 1,
      price: double.tryParse("${json['price']}") ?? 0.0,
      totalPrice: double.tryParse("${json['total_price']}") ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        "order_item_id": orderItemId,
        "product": productId,
        "product_name": productName,
        "product_images": productImages,
        "product_image": productImage,
        "variant": variantId,
        "variant_name": variantName,
        "variant_product_images": variantImages,
        "quantity": quantity,
        "price": price,
        "total_price": totalPrice,
      };
}

class Order {
  final int orderId;
  final int? user;
  final double totalAmount;
  final double appliedDiscount;
  final double taxAmount;
  final double shippingCharge;
  final double finalAmount;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String orderStatus;
  final String? paymentProof;
  final String? orderNotes;
  final String? shippingAddress;
  final String? billingAddress;
  final String? trackingNumber;
  final String? courierName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    this.user,
    required this.totalAmount,
    required this.appliedDiscount,
    required this.taxAmount,
    required this.shippingCharge,
    required this.finalAmount,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.orderStatus,
    this.paymentProof,
    this.orderNotes,
    this.shippingAddress,
    this.billingAddress,
    this.trackingNumber,
    this.courierName,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> parsedItems = [];

    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return Order(
      orderId: json['order_id'] ?? 0,
      user: json['user'],
      totalAmount: double.tryParse("${json['total_amount']}") ?? 0.0,
      appliedDiscount: double.tryParse("${json['applied_discount']}") ?? 0.0,
      taxAmount: double.tryParse("${json['tax_amount']}") ?? 0.0,
      shippingCharge: double.tryParse("${json['shipping_charge']}") ?? 0.0,
      finalAmount: double.tryParse("${json['final_amount']}") ?? 0.0,
      razorpayOrderId: json['razorpay_order_id'],
      razorpayPaymentId: json['razorpay_payment_id'],
      orderStatus: (json['order_status'] ?? "pending").toLowerCase(),
      paymentProof: json['payment_proof'],
      orderNotes: json['order_notes'],
      shippingAddress: json['shipping_address'],
      billingAddress: json['billing_address'],
      trackingNumber: json['tracking_number'],
      courierName: json['courier_name'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] == true,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "user": user,
        "total_amount": totalAmount,
        "applied_discount": appliedDiscount,
        "tax_amount": taxAmount,
        "shipping_charge": shippingCharge,
        "final_amount": finalAmount,
        "razorpay_order_id": razorpayOrderId,
        "razorpay_payment_id": razorpayPaymentId,
        "order_status": orderStatus,
        "payment_proof": paymentProof,
        "order_notes": orderNotes,
        "shipping_address": shippingAddress,
        "billing_address": billingAddress,
        "tracking_number": trackingNumber,
        "courier_name": courierName,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "is_active": isActive,
        "items": items.map((e) => e.toJson()).toList(),
      };

  // ---------------- COPY WITH ----------------
  Order copyWith({
    String? orderStatus,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Order(
      orderId: orderId,
      user: user,
      totalAmount: totalAmount,
      appliedDiscount: appliedDiscount,
      taxAmount: taxAmount,
      shippingCharge: shippingCharge,
      finalAmount: finalAmount,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentProof: paymentProof,
      orderNotes: orderNotes,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      trackingNumber: trackingNumber,
      courierName: courierName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      items: items,
    );
  }
}
