class StoreCheckoutRequestModel {
  List<int> cartItems;
  String paymentMethod; // wallet | razorpay | cod
  String? couponCode;
  bool useWallet;
  double walletAmountUsed;
    Map<String, dynamic>? shippingAddress; 

  StoreCheckoutRequestModel({
    required this.cartItems,
    required this.paymentMethod,
    this.couponCode,
    required this.useWallet, 
    required this.walletAmountUsed,
    this.shippingAddress, 
  });

  Map<String, dynamic> toJson() {
    return {
      "cart_items": cartItems,
      "payment_method": paymentMethod,
      "coupon_code": couponCode,
      "use_wallet": useWallet,
      "wallet_amount_used": walletAmountUsed,
      "shipping_address": shippingAddress,
    };
  }
}

class StoreCheckoutResponseModel {
  String? message;
  String? orderId;
  String? paymentTransactionId;
  double? razorpayRequired;
  double? walletUsed;
  double? finalAmount;
  String? paymentStatus;

  StoreCheckoutResponseModel({
    this.message,
    this.orderId,
    this.paymentTransactionId,
    this.razorpayRequired,
    this.walletUsed,
    this.finalAmount,
    this.paymentStatus,
  });

  factory StoreCheckoutResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreCheckoutResponseModel(
      message: json['message'],
      orderId: json['order_id']?.toString(), // ✅ int → string safe
      paymentTransactionId:
          json['payment_transaction_id']?.toString(), // ✅ FIX
      razorpayRequired: (json['razorpay_required'] as num?)?.toDouble(),
      walletUsed: (json['wallet_used'] as num?)?.toDouble(),
      finalAmount: (json['final_amount'] as num?)?.toDouble(),
      paymentStatus: json['payment_status'],
    );
  }
}

