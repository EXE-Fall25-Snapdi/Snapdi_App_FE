import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  @JsonKey(name: 'emailOrPhone')
  final String emailOrPhone;
  
  @JsonKey(name: 'password')
  final String password;

  const LoginRequest({
    required this.emailOrPhone,
    required this.password,
  });

  /// Factory constructor for creating a new LoginRequest instance from a map
  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  /// Method for converting LoginRequest instance to a map
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  String toString() {
    return 'LoginRequest(emailOrPhone: $emailOrPhone, password: [HIDDEN])';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginRequest &&
        other.emailOrPhone == emailOrPhone &&
        other.password == password;
  }

  @override
  int get hashCode => emailOrPhone.hashCode ^ password.hashCode;
}