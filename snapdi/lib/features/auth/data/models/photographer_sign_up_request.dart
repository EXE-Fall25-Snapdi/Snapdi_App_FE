import 'package:json_annotation/json_annotation.dart';

part 'photographer_sign_up_request.g.dart';

@JsonSerializable()
class PhotographerSignUpRequest {
  @JsonKey(name: 'name')
  final String name;
  
  @JsonKey(name: 'email')
  final String email;
  
  @JsonKey(name: 'password')
  final String password;
  
  @JsonKey(name: 'phone', includeIfNull: false)
  final String? phone;
  
  @JsonKey(name: 'locationAddress', includeIfNull: false)
  final String? locationAddress;
  
  @JsonKey(name: 'locationCity')
  final String locationCity;
  
  @JsonKey(name: 'yearsOfExperience')
  final String yearsOfExperience;
  
  @JsonKey(name: 'equipmentDescription')
  final String equipmentDescription;
  
  @JsonKey(name: 'description', includeIfNull: false)
  final String? description;
  
  @JsonKey(name: 'isAvailable', includeIfNull: false)
  final bool? isAvailable;
  
  @JsonKey(name: 'avatarUrl', includeIfNull: false)
  final String? avatarUrl;

  const PhotographerSignUpRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.locationAddress,
    required this.locationCity,
    required this.yearsOfExperience,
    required this.equipmentDescription,
    this.description,
    this.isAvailable,
    this.avatarUrl,
  });

  /// Factory constructor for creating a new PhotographerSignUpRequest instance from a map
  factory PhotographerSignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$PhotographerSignUpRequestFromJson(json);

  /// Method for converting PhotographerSignUpRequest instance to a map
  Map<String, dynamic> toJson() => _$PhotographerSignUpRequestToJson(this);

  @override
  String toString() {
    return 'PhotographerSignUpRequest(name: $name, email: $email, locationCity: $locationCity, yearsOfExperience: $yearsOfExperience)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotographerSignUpRequest &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.phone == phone &&
        other.locationAddress == locationAddress &&
        other.locationCity == locationCity &&
        other.yearsOfExperience == yearsOfExperience &&
        other.equipmentDescription == equipmentDescription &&
        other.description == description &&
        other.isAvailable == isAvailable &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode => Object.hash(
    name,
    email,
    password,
    phone,
    locationAddress,
    locationCity,
    yearsOfExperience,
    equipmentDescription,
    description,
    isAvailable,
    avatarUrl,
  );
}