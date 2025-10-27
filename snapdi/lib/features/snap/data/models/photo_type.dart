class PhotoType {
  final int photoTypeId;
  final String photoTypeName;
  final double photoPrice;
  final int time;

  PhotoType({
    required this.photoTypeId,
    required this.photoTypeName,
    required this.photoPrice,
    required this.time,
  });

  factory PhotoType.fromJson(Map<String, dynamic> json) {
    return PhotoType(
      photoTypeId: json['photoTypeId'] ?? 0,
      photoTypeName: json['photoTypeName'] ?? '',
      photoPrice: (json['photoPrice'] != null)
          ? double.parse(json['photoPrice'].toString())
          : 0.0,
      time: json['time'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photoTypeId': photoTypeId,
      'photoTypeName': photoTypeName,
      'photoPrice': photoPrice,
      'time': time,
    };
  }
}
