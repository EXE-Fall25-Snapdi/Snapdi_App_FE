import 'package:json_annotation/json_annotation.dart';

part 'update_user_request.g.dart';

@JsonSerializable()
class UpdateUserRequest {
  final String name;
  final String phone;
  final String? locationAddress;
  final String? locationCity;
  final String? avatarUrl;
  final bool? isActive;
  final bool? isVerify;

  UpdateUserRequest({
    required this.name,
    required this.phone,
    this.locationAddress,
    this.locationCity,
    this.avatarUrl,
    this.isActive,
    this.isVerify,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}
