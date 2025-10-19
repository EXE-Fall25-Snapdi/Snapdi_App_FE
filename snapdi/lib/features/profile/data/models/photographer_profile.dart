import 'package:json_annotation/json_annotation.dart';

part 'photographer_profile.g.dart';

@JsonSerializable()
class PhotographerProfile {
  @JsonKey(name: 'userId')
  final int userId;

  @JsonKey(name: 'equipmentDescription')
  final String? equipmentDescription;

  @JsonKey(name: 'yearsOfExperience')
  final String? yearsOfExperience;

  @JsonKey(name: 'avgRating')
  final double? avgRating;

  @JsonKey(name: 'isAvailable')
  final bool isAvailable;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'levelPhotographer')
  final String? levelPhotographer;

  const PhotographerProfile({
    required this.userId,
    this.equipmentDescription,
    this.yearsOfExperience,
    this.avgRating,
    required this.isAvailable,
    this.description,
    this.levelPhotographer,
  });

  factory PhotographerProfile.fromJson(Map<String, dynamic> json) =>
      _$PhotographerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$PhotographerProfileToJson(this);
}
