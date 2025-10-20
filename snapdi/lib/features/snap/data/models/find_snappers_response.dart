class FindSnappersResponse {
  final bool success;
  final String? message;
  final FindSnappersData? data;

  FindSnappersResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory FindSnappersResponse.fromJson(Map<String, dynamic> json) {
    return FindSnappersResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? FindSnappersData.fromJson(json['data']) : null,
    );
  }
}

class FindSnappersData {
  final List<SnapperInfo> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  FindSnappersData({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  factory FindSnappersData.fromJson(Map<String, dynamic> json) {
    return FindSnappersData(
      items: (json['items'] as List?)
              ?.map((item) => SnapperInfo.fromJson(item))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 3,
    );
  }
}

class SnapperInfo {
  final int userId;
  final String fullName;
  final String level;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final String? avatarUrl;

  SnapperInfo({
    required this.userId,
    required this.fullName,
    required this.level,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    this.avatarUrl,
  });

  factory SnapperInfo.fromJson(Map<String, dynamic> json) {
    return SnapperInfo(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      level: json['level'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      avatarUrl: json['avatarUrl'],
    );
  }
}
