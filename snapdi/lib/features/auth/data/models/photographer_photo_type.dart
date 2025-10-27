import 'package:json_annotation/json_annotation.dart';

part 'photographer_photo_type.g.dart';

@JsonSerializable()
class PhotographerPhotoType {
  @JsonKey(name: 'photoTypeId')
  final int photoTypeId;

  @JsonKey(name: 'photoPrice')
  final double photoPrice;

  @JsonKey(name: 'time')
  final int time;

  const PhotographerPhotoType({
    required this.photoTypeId,
    required this.photoPrice,
    required this.time,
  });

  factory PhotographerPhotoType.fromJson(Map<String, dynamic> json) =>
      _$PhotographerPhotoTypeFromJson(json);

  Map<String, dynamic> toJson() => _$PhotographerPhotoTypeToJson(this);

  @override
  String toString() =>
      'PhotographerPhotoType(photoTypeId: $photoTypeId, photoPrice: $photoPrice, time: $time)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotographerPhotoType &&
        other.photoTypeId == photoTypeId &&
        other.photoPrice == photoPrice &&
        other.time == time;
  }

  @override
  int get hashCode => Object.hash(photoTypeId, photoPrice, time);
}
