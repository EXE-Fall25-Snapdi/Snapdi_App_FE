import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'token')
  final String token;

  @JsonKey(name: 'refreshToken')
  final String refreshToken;

  @JsonKey(name: 'user')
  final User user;

  const LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  /// Factory constructor for creating a new LoginResponse instance from a map
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  /// Method for converting LoginResponse instance to a map
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @override
  String toString() {
    return 'LoginResponse(token: ${token.substring(0, 10)}..., user: ${user.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponse &&
        other.token == token &&
        other.refreshToken == refreshToken &&
        other.user == user;
  }

  @override
  int get hashCode => token.hashCode ^ refreshToken.hashCode ^ user.hashCode;
}
