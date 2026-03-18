class PaymentVerificationModel {
  String? message;
  String? paymentId;
  String? orderId;
  int? bookingId;
  String? date;
  String? status;
  double? amount; 
  String? paymentMethod;

  PaymentVerificationModel({
    this.message,
    this.paymentId,
    this.orderId,
    this.bookingId,
    this.date,
    this.status,
    this.amount,
    this.paymentMethod,
  });

  PaymentVerificationModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    paymentId = json['payment_id'];
    orderId = json['order_id'].toString();
    bookingId = json['booking_id'];
    date = json['date'];
    status = json['status'];
    amount = json['amount'] != null
        ? double.tryParse(json['amount'].toString()) ?? 0.0
        : 0.0; // ✅ Ensure proper parsing
    paymentMethod = json['payment_method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    data['payment_id'] = paymentId;
    data['order_id'] = orderId;
    data['booking_id'] = bookingId;
    data['date'] = date;
    data['status'] = status;
    data['amount'] = amount;
    data['payment_method'] = paymentMethod;
    return data;
  }

  void operator [](String other) {}
}
