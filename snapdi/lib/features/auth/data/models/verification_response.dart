class VerificationResponse {
  final String message;

  const VerificationResponse({required this.message});

  /// Factory constructor for creating a new VerificationResponse instance from a map
  factory VerificationResponse.fromJson(Map<String, dynamic> json) =>
      VerificationResponse(message: json['message'] as String);

  /// Method for converting VerificationResponse instance to a map
  Map<String, dynamic> toJson() => {'message': message};

  @override
  String toString() {
    return 'VerificationResponse(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationResponse && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
