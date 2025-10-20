import 'package:json_annotation/json_annotation.dart';
import 'photographer_profile.dart';
import 'photo_portfolio.dart';
import '../../../auth/data/models/user.dart';

part 'photographer_detail_response.g.dart';

@JsonSerializable()
class PhotographerDetailResponse extends User {
  @JsonKey(name: 'photographerProfile')
  final PhotographerProfile? photographerProfile;

  @JsonKey(name: 'photoPortfolios')
  final List<PhotoPortfolio>? photoPortfolios;

  const PhotographerDetailResponse({
    required super.userId,
    required super.roleId,
    required super.roleName,
    required super.name,
    required super.email,
    super.phone,
    required super.isActive,
    required super.isVerify,
    required super.createdAt,
    super.locationAddress,
    super.locationCity,
    super.avatarUrl,
    this.photographerProfile,
    this.photoPortfolios,
  });

  factory PhotographerDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$PhotographerDetailResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PhotographerDetailResponseToJson(this);
}
