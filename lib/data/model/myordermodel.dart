import 'dart:convert';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));
String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  int orderId;
  int user;
  String totalAmount;
  String appliedDiscount;
  String taxAmount;
  String shippingCharge;
  String finalAmount;
  String? razorpayOrderId;
  String? razorpayPaymentId;
  String? razorpaySignature;
  String orderStatus;
  String? paymentProof;
  String? orderNotes;
  String? shippingAddress;
  String? billingAddress;
  String? trackingNumber;
  String? courierName;
  DateTime createdAt;
  DateTime updatedAt;
  bool isActive;
  List<OrderItem> items;

  Order({
    required this.orderId,
    required this.user,
    required this.totalAmount,
    required this.appliedDiscount,
    required this.taxAmount,
    required this.shippingCharge,
    required this.finalAmount,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.orderStatus,
    required this.paymentProof,
    required this.orderNotes,
    required this.shippingAddress,
    required this.billingAddress,
    required this.trackingNumber,
    required this.courierName,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json["order_id"],
        user: json["user"],
        totalAmount: json["total_amount"],
        appliedDiscount: json["applied_discount"],
        taxAmount: json["tax_amount"],
        shippingCharge: json["shipping_charge"],
        finalAmount: json["final_amount"],
        razorpayOrderId: json["razorpay_order_id"],
        razorpayPaymentId: json["razorpay_payment_id"],
        razorpaySignature: json["razorpay_signature"],
        orderStatus: json["order_status"],
        paymentProof: json["payment_proof"],
        orderNotes: json["order_notes"],
        shippingAddress: json["shipping_address"],
        billingAddress: json["billing_address"],
        trackingNumber: json["tracking_number"],
        courierName: json["courier_name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        isActive: json["is_active"],
        items:
            List<OrderItem>.from(json["items"].map((x) => OrderItem.fromJson(x))),
      );

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
        "razorpay_signature": razorpaySignature,
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
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class OrderItem {
  int orderItemId;
  int order;
  int product;
  String productName;
  List<String> productImages;
  int variant;
  String variantName;
  List<String> variantImages;
  int quantity;
  String price;
  String totalPrice;
  String? itemNotes;

  OrderItem({
    required this.orderItemId,
    required this.order,
    required this.product,
    required this.productName,
    required this.productImages,
    required this.variant,
    required this.variantName,
    required this.variantImages,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.itemNotes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        orderItemId: json["order_item_id"],
        order: json["order"],
        product: json["product"],
        productName: json["product_name"],
        productImages: List<String>.from(json["product_images"].map((x) => x)),
        variant: json["variant"],
        variantName: json["variant_name"],
        variantImages:
            List<String>.from(json["variant_product_images"].map((x) => x)),
        quantity: json["quantity"],
        price: json["price"],
        totalPrice: json["total_price"],
        itemNotes: json["item_notes"],
      );

  Map<String, dynamic> toJson() => {
        "order_item_id": orderItemId,
        "order": order,
        "product": product,
        "product_name": productName,
        "product_images": productImages,
        "variant": variant,
        "variant_name": variantName,
        "variant_product_images": variantImages,
        "quantity": quantity,
        "price": price,
        "total_price": totalPrice,
        "item_notes": itemNotes,
      };
}
