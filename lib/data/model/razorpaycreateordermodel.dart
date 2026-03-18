class RazorpayCreateRequestModel {
  String paymentTransactionId;
  double amount;

  RazorpayCreateRequestModel({
    required this.paymentTransactionId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      "payment_transaction_id": paymentTransactionId,
      "amount": amount,
    };
  }
}

class RazorpayCreateResponseModel {
  String? message;
  String? razorpayOrderId;
  double? amount;
  String? currency;
  String? orderId;

  RazorpayCreateResponseModel({
    this.message,
    this.razorpayOrderId,
    this.amount,
    this.currency,
    this.orderId,
  });

  factory RazorpayCreateResponseModel.fromJson(Map<String, dynamic> json) {
    return RazorpayCreateResponseModel(
      message: json['message'],
      razorpayOrderId: json['razorpay_order_id']?.toString(), // ✅ safe
      amount: json['amount']?.toDouble(),
      currency: json['currency'],
      orderId: json['order_id']?.toString(), // ✅ FIX
    );
  }
}

