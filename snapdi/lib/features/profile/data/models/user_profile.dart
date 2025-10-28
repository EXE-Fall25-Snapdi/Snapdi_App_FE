import 'package:json_annotation/json_annotation.dart';
import 'photographer_profile.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final int userId;
  final int roleId;
  final String roleName;
  final String name;
  final String email;
  final String phone;
  final bool isActive;
  final bool isVerify;
  final String createdAt;
  final String? locationAddress;
  final String? locationCity;
  final String? avatarUrl;
  
  @JsonKey(name: 'photographerProfile')
  final PhotographerProfile? photographerProfile;

  UserProfile({
    required this.userId,
    required this.roleId,
    required this.roleName,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.isVerify,
    required this.createdAt,
    this.locationAddress,
    this.locationCity,
    this.avatarUrl,
    this.photographerProfile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
