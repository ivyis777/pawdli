class CouponModel {
  final String code;
  final String discountType; // percentage | flat
  final double discountValue;
  final double? maxDiscountAmount;
  final double? minOrderAmount;

  CouponModel({
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    this.minOrderAmount,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      code: json['code'],
      discountType: json['discount_type'],
      discountValue: double.tryParse(
              json['discount_value'].toString()) ??
          0.0,
      maxDiscountAmount: json['max_discount_amount'] != null
          ? double.tryParse(
              json['max_discount_amount'].toString())
          : null,
      minOrderAmount: json['min_order_amount'] != null
          ? double.tryParse(
              json['min_order_amount'].toString())
          : null,
    );
  }
}
