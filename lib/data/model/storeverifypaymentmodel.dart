class RazorpayVerifyRequestModel {
  String paymentTransactionId;
  String razorpayOrderId;
  String razorpayPaymentId;
  String razorpaySignature;

  RazorpayVerifyRequestModel({
    required this.paymentTransactionId,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      "payment_transaction_id": paymentTransactionId,
      "razorpay_order_id": razorpayOrderId,
      "razorpay_payment_id": razorpayPaymentId,
      "razorpay_signature": razorpaySignature,
    };
  }
}

class RazorpayVerifyResponseModel {
  String? message;
  String? orderId;
  String? paymentStatus;

  RazorpayVerifyResponseModel({
    this.message,
    this.orderId,
    this.paymentStatus,
  });

  factory RazorpayVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    return RazorpayVerifyResponseModel(
      message: json['message'],
      orderId: json['order_id'],
      paymentStatus: json['payment_status'],
    );
  }
}

