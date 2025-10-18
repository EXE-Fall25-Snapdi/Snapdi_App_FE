import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'photographer_sign_up_response.g.dart';

@JsonSerializable()
class PhotographerSignUpResponse {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'user')
  final User user;

  @JsonKey(name: 'accessToken')
  final String? accessToken;

  @JsonKey(name: 'refreshToken')
  final String? refreshToken;

  const PhotographerSignUpResponse({
    this.message,
    required this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory PhotographerSignUpResponse.fromJson(Map<String, dynamic> json) =>
      _$PhotographerSignUpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PhotographerSignUpResponseToJson(this);

  @override
  String toString() {
    return 'PhotographerSignUpResponse(message: $message, user: ${user.name}, hasTokens: ${accessToken != null})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotographerSignUpResponse &&
        other.message == message &&
        other.user == user &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => Object.hash(message, user, accessToken, refreshToken);
}
