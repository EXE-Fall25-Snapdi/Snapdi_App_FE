import 'package:json_annotation/json_annotation.dart';

part 'photo_type_with_pricing.g.dart';

@JsonSerializable()
class PhotoTypeWithPricing {
  @JsonKey(name: 'photoTypeId')
  final int photoTypeId;

  @JsonKey(name: 'photoTypeName')
  final String photoTypeName;

  @JsonKey(name: 'photoPrice')
  final double? photoPrice;

  @JsonKey(name: 'time')
  final int? time;

  PhotoTypeWithPricing({
    required this.photoTypeId,
    required this.photoTypeName,
    this.photoPrice,
    this.time,
  });

  factory PhotoTypeWithPricing.fromJson(Map<String, dynamic> json) =>
      _$PhotoTypeWithPricingFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoTypeWithPricingToJson(this);

  PhotoTypeWithPricing copyWith({
    int? photoTypeId,
    String? photoTypeName,
    double? photoPrice,
    int? time,
  }) {
    return PhotoTypeWithPricing(
      photoTypeId: photoTypeId ?? this.photoTypeId,
      photoTypeName: photoTypeName ?? this.photoTypeName,
      photoPrice: photoPrice ?? this.photoPrice,
      time: time ?? this.time,
    );
  }
}


