import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'sign_up_response.g.dart';

@JsonSerializable()
class SignUpResponse {
  @JsonKey(name: 'message')
  final String? message;
  
  @JsonKey(name: 'user')
  final User user;
  
  @JsonKey(name: 'accessToken')
  final String? accessToken;
  
  @JsonKey(name: 'refreshToken')
  final String? refreshToken;

  const SignUpResponse({
    this.message,
    required this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) => _$SignUpResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$SignUpResponseToJson(this);
}