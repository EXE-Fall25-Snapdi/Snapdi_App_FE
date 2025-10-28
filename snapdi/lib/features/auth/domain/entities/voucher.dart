class Voucher {
  final int voucherId;
  final String code;
  final String? description;
  final String? discountType;
  final double discountValue;
  final double? maxDiscount;
  final double? minSpend;
  final DateTime startDate;
  final DateTime endDate;
  final int? usageLimit;
  final bool isActive;

  const Voucher({
    required this.voucherId,
    required this.code,
    this.description,
    this.discountType,
    required this.discountValue,
    this.maxDiscount,
    this.minSpend,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    required this.isActive,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      voucherId: json['voucherId'],
      code: json['code'],
      description: json['description'],
      discountType: json['discountType'],
      discountValue: (json['discountValue'] as num).toDouble(),
      maxDiscount: json['maxDiscount'] != null ? (json['maxDiscount'] as num).toDouble() : null,
      minSpend: json['minSpend'] != null ? (json['minSpend'] as num).toDouble() : null,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      usageLimit: json['usageLimit'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voucherId': voucherId,
      'code': code,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'maxDiscount': maxDiscount,
      'minSpend': minSpend,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'usageLimit': usageLimit,
      'isActive': isActive,
    };
  }
}
