import 'package:json_annotation/json_annotation.dart';

part 'sign_up_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SignUpRequest {
  @JsonKey(name: 'name')
  final String name;
  
  @JsonKey(name: 'email')
  final String email;
  
  @JsonKey(name: 'phone', includeIfNull: false)
  final String? phone;
  
  @JsonKey(name: 'password')
  final String password;
  
  @JsonKey(name: 'roleId')
  final int roleId;
  
  @JsonKey(name: 'locationAddress', includeIfNull: false)
  final String? locationAddress;
  
  @JsonKey(name: 'locationCity', includeIfNull: false)
  final String? locationCity;
  
  @JsonKey(name: 'avatarUrl', includeIfNull: false)
  final String? avatarUrl;

  const SignUpRequest({
    required this.name,
    required this.email,
    this.phone,
    required this.password,
    required this.roleId,
    this.locationAddress,
    this.locationCity,
    this.avatarUrl,
  });

  factory SignUpRequest.fromJson(Map<String, dynamic> json) => _$SignUpRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$SignUpRequestToJson(this);
}