class VerifyEmailCodeRequest {
  final String email;
  final String code;

  const VerifyEmailCodeRequest({required this.email, required this.code});

  /// Factory constructor for creating a new VerifyEmailCodeRequest instance from a map
  factory VerifyEmailCodeRequest.fromJson(Map<String, dynamic> json) =>
      VerifyEmailCodeRequest(
        email: json['email'] as String,
        code: json['code'] as String,
      );

  /// Method for converting VerifyEmailCodeRequest instance to a map
  Map<String, dynamic> toJson() => {'email': email, 'code': code};

  @override
  String toString() {
    return 'VerifyEmailCodeRequest(email: $email, code: ${code.substring(0, 2)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerifyEmailCodeRequest &&
        other.email == email &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(email, code);
}
