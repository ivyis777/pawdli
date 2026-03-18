class TransactionsModel {
  final String? message;
  final List<TransactionData>? data;

  TransactionsModel({this.message, this.data});

  factory TransactionsModel.fromJson(Map<String, dynamic> json) {
    return TransactionsModel(
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => TransactionData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

class TransactionData {
  final int? id;
  final String? description;
  final String? transactionId;
  final String? transactionType;
  final bool? isCredit;
  final String? amount;
  final String? date;
  final String? previousBalance;
  final String? currentBalance;
  final String? status;
  final String? paymentMethod;
  final String? transactionReference;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? wallet;

  TransactionData({
    this.id,
    this.description,
    this.transactionId,
    this.transactionType,
    this.isCredit,
    this.amount,
    this.date,
    this.previousBalance,
    this.currentBalance,
    this.status,
    this.paymentMethod,
    this.transactionReference,
    this.createdAt,
    this.updatedAt,
    this.wallet,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['id'],
      description: json['description'],
      transactionId: json['transaction_id'],
      transactionType: json['transaction_type'],
      isCredit: json['is_credit'],
      amount: json['amount'],
      date: json['date'],
      previousBalance: json['previous_balance'],
      currentBalance: json['current_balance'],
      status: json['status'],
      paymentMethod: json['payment_method'],
      transactionReference: json['transaction_reference'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      wallet: json['wallet'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'transaction_id': transactionId,
      'transaction_type': transactionType,
      'is_credit': isCredit,
      'amount': amount,
      'date': date,
      'previous_balance': previousBalance,
      'current_balance': currentBalance,
      'status': status,
      'payment_method': paymentMethod,
      'transaction_reference': transactionReference,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'wallet': wallet,
    };
  }
}
