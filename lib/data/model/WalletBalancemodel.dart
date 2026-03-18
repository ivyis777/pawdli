class WalletBalanceModel {
  final WalletBalanceData? data;

  WalletBalanceModel({this.data});

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      data: json['data'] != null ? WalletBalanceData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data?.toJson()};
  }
}

class WalletBalanceData {
  final int walletId;
  final int user;
  final String walletBalance;
  final String currency;
  final bool isActive;

  WalletBalanceData({
    required this.walletId,
    required this.user,
    required this.walletBalance,
    required this.currency,
    required this.isActive,
  });

  factory WalletBalanceData.fromJson(Map<String, dynamic> json) {
    return WalletBalanceData(
      walletId: json['wallet_id'] ?? 0,
      user: json['user'] ?? 0,
      walletBalance: json['wallet_balance'] ?? "0",
      currency: json['currency'] ?? "USD",
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'user': user,
      'wallet_balance': walletBalance,
      'currency': currency,
      'is_active': isActive,
    };
  }
}
