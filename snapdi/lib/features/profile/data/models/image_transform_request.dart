import 'package:json_annotation/json_annotation.dart';

part 'image_transform_request.g.dart';

@JsonSerializable()
class ImageTransformRequest {
  final int? width;
  final int? height;
  final String? crop;
  final String? gravity;
  final int? quality;
  final String? format;
  final bool? autoOptimize;

  ImageTransformRequest({
    this.width,
    this.height,
    this.crop,
    this.gravity,
    this.quality,
    this.format,
    this.autoOptimize,
  });

  factory ImageTransformRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageTransformRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ImageTransformRequestToJson(this);
}
