import 'package:json_annotation/json_annotation.dart';

part 'cloudinary_single_upload_response.g.dart';

@JsonSerializable()
class CloudinarySingleUploadResponse {
  final String publicId;
  final String url;
  final String secureUrl;
  final String format;
  final int width;
  final int height;
  final int bytes;
  final String resourceType;
  final String createdAt;
  final String signature;
  final String etag;

  CloudinarySingleUploadResponse({
    required this.publicId,
    required this.url,
    required this.secureUrl,
    required this.format,
    required this.width,
    required this.height,
    required this.bytes,
    required this.resourceType,
    required this.createdAt,
    required this.signature,
    required this.etag,
  });

  factory CloudinarySingleUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$CloudinarySingleUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CloudinarySingleUploadResponseToJson(this);
}

@JsonSerializable()
class CloudinaryDeleteResponse {
  final bool success;
  final String result;
  final String publicId;
  final String message;

  CloudinaryDeleteResponse({
    required this.success,
    required this.result,
    required this.publicId,
    required this.message,
  });

  factory CloudinaryDeleteResponse.fromJson(Map<String, dynamic> json) =>
      _$CloudinaryDeleteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CloudinaryDeleteResponseToJson(this);
}
