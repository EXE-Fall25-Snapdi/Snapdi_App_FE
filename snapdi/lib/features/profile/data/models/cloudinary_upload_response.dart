import 'package:json_annotation/json_annotation.dart';

part 'cloudinary_upload_response.g.dart';

@JsonSerializable()
class CloudinaryUploadResponse {
  final List<SuccessfulUpload> successfulUploads;
  final List<FailedUpload> failedUploads;
  final int totalProcessed;
  final int successCount;
  final int failureCount;

  CloudinaryUploadResponse({
    required this.successfulUploads,
    required this.failedUploads,
    required this.totalProcessed,
    required this.successCount,
    required this.failureCount,
  });

  factory CloudinaryUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$CloudinaryUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CloudinaryUploadResponseToJson(this);
}

@JsonSerializable()
class SuccessfulUpload {
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

  SuccessfulUpload({
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

  factory SuccessfulUpload.fromJson(Map<String, dynamic> json) =>
      _$SuccessfulUploadFromJson(json);

  Map<String, dynamic> toJson() => _$SuccessfulUploadToJson(this);
}

@JsonSerializable()
class FailedUpload {
  final String fileName;
  final String error;
  final String? details;

  FailedUpload({required this.fileName, required this.error, this.details});

  factory FailedUpload.fromJson(Map<String, dynamic> json) =>
      _$FailedUploadFromJson(json);

  Map<String, dynamic> toJson() => _$FailedUploadToJson(this);
}
