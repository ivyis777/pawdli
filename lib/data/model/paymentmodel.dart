class PaymentModel {
  final int id;
  final String razorpayTransactionId;
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;
  final String amount;
  final String programName;
  final String purpose;
  final String? paymentMethod;
  final DateTime transactionDate;
  final String status;
  final DateTime createdAt;
  final int user;

  PaymentModel({
    required this.id,
    required this.razorpayTransactionId,
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
    required this.amount,
    required this.programName,
    required this.purpose,
    this.paymentMethod,
    required this.transactionDate,
    required this.status,
    required this.createdAt,
    required this.user,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      razorpayTransactionId: json['razorpay_transaction_id'],
      razorpayPaymentId: json['razorpay_payment_id'],
      razorpayOrderId: json['razorpay_order_id'],
      razorpaySignature: json['razorpay_signature'],
      amount: json['amount'],
      programName: json['program_name'],
      purpose: json['purpose'],
      paymentMethod: json['payment_method'],
      transactionDate: DateTime.parse(json['transaction_date']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'],
    );
  }
}
