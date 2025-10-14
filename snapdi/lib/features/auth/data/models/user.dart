import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'userId')
  final int userId;

  @JsonKey(name: 'roleId')
  final int roleId;

  @JsonKey(name: 'roleName')
  final String roleName;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'isActive')
  final bool isActive;

  @JsonKey(name: 'isVerify')
  final bool isVerify;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'locationAddress')
  final String? locationAddress;

  @JsonKey(name: 'locationCity')
  final String? locationCity;

  @JsonKey(name: 'avatarUrl')
  final String? avatarUrl;

  const User({
    required this.userId,
    required this.roleId,
    required this.roleName,
    required this.name,
    required this.email,
    this.phone,
    required this.isActive,
    required this.isVerify,
    required this.createdAt,
    this.locationAddress,
    this.locationCity,
    this.avatarUrl,
  });

  /// Factory constructor for creating a new User instance from a map
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Method for converting User instance to a map
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Create a copy of User with some fields replaced
  User copyWith({
    int? userId,
    int? roleId,
    String? roleName,
    String? name,
    String? email,
    String? phone,
    bool? isActive,
    bool? isVerify,
    DateTime? createdAt,
    String? locationAddress,
    String? locationCity,
    String? avatarUrl,
  }) {
    return User(
      userId: userId ?? this.userId,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      isVerify: isVerify ?? this.isVerify,
      createdAt: createdAt ?? this.createdAt,
      locationAddress: locationAddress ?? this.locationAddress,
      locationCity: locationCity ?? this.locationCity,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, name: $name, email: $email, roleName: $roleName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.userId == userId &&
        other.roleId == roleId &&
        other.roleName == roleName &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.isActive == isActive &&
        other.isVerify == isVerify &&
        other.createdAt == createdAt &&
        other.locationAddress == locationAddress &&
        other.locationCity == locationCity &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      roleId,
      roleName,
      name,
      email,
      phone,
      isActive,
      isVerify,
      createdAt,
      locationAddress,
      locationCity,
      avatarUrl,
    );
  }
}
