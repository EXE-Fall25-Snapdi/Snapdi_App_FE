class ManualPaymentRequest {
  final int bookingId;
  final String? transactionReference;
  final String? proofImageUrl;
  final double amount;

  ManualPaymentRequest({
    required this.bookingId,
    required this.amount,
    this.transactionReference,
    this.proofImageUrl,
  });

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'transactionReference': transactionReference,
    'proofImageUrl': proofImageUrl,
    'amount': amount,
  };
}
