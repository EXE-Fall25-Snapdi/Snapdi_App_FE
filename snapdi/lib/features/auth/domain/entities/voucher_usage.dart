class VoucherUsage {
  final int voucherUsageId;
  final int? bookingId;
  final int? voucherId;
  final int? userId;
  final DateTime usedAt;

  VoucherUsage({
    required this.voucherUsageId,
    this.bookingId,
    this.voucherId,
    this.userId,
    required this.usedAt,
  });

  factory VoucherUsage.fromJson(Map<String, dynamic> json) {
    return VoucherUsage(
      voucherUsageId: json['voucherUsageId'],
      bookingId: json['bookingId'],
      voucherId: json['voucherId'],
      userId: json['userId'],
      usedAt: DateTime.parse(json['usedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voucherUsageId': voucherUsageId,
      'bookingId': bookingId,
      'voucherId': voucherId,
      'userId': userId,
      'usedAt': usedAt.toIso8601String(),
    };
  }
}
