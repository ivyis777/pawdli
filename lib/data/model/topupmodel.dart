class TopUPModel {
  String? message;
  String? orderId;
  double? amount; 
  int? userId;

  TopUPModel({this.message, this.orderId, this.amount, this.userId});

  TopUPModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    orderId = json['order_id'];
    amount = json['amount']?.toDouble(); 
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = this.message;
    data['order_id'] = this.orderId;
    data['amount'] = this.amount;
    data['user_id'] = this.userId;
    return data;
  }
}
