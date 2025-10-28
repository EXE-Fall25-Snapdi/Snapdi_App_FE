class ManualPaymentRequest {
  final int bookingId;
  final int feePolicyId;

  ManualPaymentRequest({
    required this.bookingId,
    required this.feePolicyId,
  });
  

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'feePolicyId': feePolicyId,
  };
}
