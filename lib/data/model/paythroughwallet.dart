class PayThroughWalletModel {
  String? message;
  String? paymentMethod;
  String? amount;
  String? status;
  String? previousBalance;
  String? currentBalance;

  PayThroughWalletModel(
      {this.message,
      this.paymentMethod,
      this.amount,
      this.status,
      this.previousBalance,
      this.currentBalance});

  PayThroughWalletModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    paymentMethod = json['payment_method'];
    amount = json['amount'];
    status = json['status'];
    previousBalance = json['previous_balance'];
    currentBalance = json['current_balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['payment_method'] = this.paymentMethod;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['previous_balance'] = this.previousBalance;
    data['current_balance'] = this.currentBalance;
    return data;
  }
}
