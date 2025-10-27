class PhotoType {
  final int photoTypeId;
  final String photoTypeName;

  PhotoType({
    required this.photoTypeId,
    required this.photoTypeName,
  });

  factory PhotoType.fromJson(Map<String, dynamic> json) {
    return PhotoType(
      photoTypeId: json['photoTypeId'] ?? 0,
      photoTypeName: json['photoTypeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photoTypeId': photoTypeId,
      'photoTypeName': photoTypeName,
    };
  }
}
