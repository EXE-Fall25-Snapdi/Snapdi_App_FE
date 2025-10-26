import 'package:json_annotation/json_annotation.dart';

part 'current_location.g.dart';

@JsonSerializable()
class CurrentLocation {
  @JsonKey(name: 'latitude')
  final double latitude;

  @JsonKey(name: 'longitude')
  final double longitude;

  const CurrentLocation({
    required this.latitude,
    required this.longitude,
  });

  factory CurrentLocation.fromJson(Map<String, dynamic> json) =>
      _$CurrentLocationFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentLocationToJson(this);

  @override
  String toString() => 'CurrentLocation(latitude: $latitude, longitude: $longitude)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrentLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
