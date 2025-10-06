class SendVerificationCodeRequest {
  final String email;

  const SendVerificationCodeRequest({
    required this.email,
  });

  /// Factory constructor for creating a new SendVerificationCodeRequest instance from a map
  factory SendVerificationCodeRequest.fromJson(Map<String, dynamic> json) => SendVerificationCodeRequest(
    email: json['email'] as String,
  );

  /// Method for converting SendVerificationCodeRequest instance to a map
  Map<String, dynamic> toJson() => {
    'email': email,
  };

  @override
  String toString() {
    return 'SendVerificationCodeRequest(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SendVerificationCodeRequest && other.email == email;
  }

  @override
  int get hashCode => email.hashCode;
}