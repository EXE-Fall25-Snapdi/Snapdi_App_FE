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
    // Handle direct response structure (without "success" wrapper)
    if (json.containsKey('snappers')) {
      return FindSnappersResponse(
        success: true,
        data: FindSnappersData.fromJson(json),
      );
    }
    
    return FindSnappersResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? FindSnappersData.fromJson(json['data']) : null,
    );
  }
}

class FindSnappersData {
  final List<SnapperInfo> snappers;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final int availableCount;
  final String? summary;

  FindSnappersData({
    required this.snappers,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.availableCount,
    this.summary,
  });

  factory FindSnappersData.fromJson(Map<String, dynamic> json) {
    return FindSnappersData(
      snappers: (json['snappers'] as List?)
              ?.map((item) => SnapperInfo.fromJson(item))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 50,
      totalPages: json['totalPages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      availableCount: json['availableCount'] ?? 0,
      summary: json['summary'],
    );
  }
  
  // Compatibility getter for old code
  List<SnapperInfo> get items => snappers;
}

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
}

class StyleInfo {
  final int styleId;
  final String styleName;

  StyleInfo({
    required this.styleId,
    required this.styleName,
  });

  factory StyleInfo.fromJson(Map<String, dynamic> json) {
    return StyleInfo(
      styleId: json['styleId'] ?? 0,
      styleName: json['styleName'] ?? '',
    );
  }
}

class SnapperInfo {
  final int userId;
  final String name;
  final String email;
  final String? phone;
  final String? locationCity;
  final String? locationAddress;
  final String? avatarUrl;
  final bool isActive;
  final bool isVerify;
  final String levelPhotographer;
  final bool isAvailable;
  final double avgRating;
  final String? yearsOfExperience;
  final String? equipmentDescription;
  final String? description;
  final double photoPrice;
  final String workLocation;
  final List<PhotoType> photoTypes;
  final List<StyleInfo> styles;
  final int portfolioCount;
  final List<String> portfolioUrls;

  SnapperInfo({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.locationCity,
    this.locationAddress,
    this.avatarUrl,
    required this.isActive,
    required this.isVerify,
    required this.levelPhotographer,
    required this.isAvailable,
    required this.avgRating,
    this.yearsOfExperience,
    this.equipmentDescription,
    this.description,
    required this.photoPrice,
    required this.workLocation,
    required this.photoTypes,
    required this.styles,
    required this.portfolioCount,
    required this.portfolioUrls,
  });

  factory SnapperInfo.fromJson(Map<String, dynamic> json) {
    return SnapperInfo(
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      locationCity: json['locationCity'],
      locationAddress: json['locationAddress'],
      avatarUrl: json['avatarUrl'],
      isActive: json['isActive'] ?? false,
      isVerify: json['isVerify'] ?? false,
      levelPhotographer: json['levelPhotographer'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      yearsOfExperience: json['yearsOfExperience'],
      equipmentDescription: json['equipmentDescription'],
      description: json['description'],
      photoPrice: (json['photoPrice'] ?? 0).toDouble(),
      workLocation: json['workLocation'] ?? '',
      photoTypes: (json['photoTypes'] as List?)
              ?.map((item) => PhotoType.fromJson(item))
              .toList() ??
          [],
      styles: (json['styles'] as List?)
              ?.map((item) => StyleInfo.fromJson(item))
              .toList() ??
          [],
      portfolioCount: json['portfolioCount'] ?? 0,
      portfolioUrls: (json['portfolioUrls'] as List?)
              ?.map((url) => url.toString())
              .toList() ??
          [],
    );
  }
  
  // Compatibility getters for old code
  String get fullName => name;
  String get level => levelPhotographer;
  double get rating => avgRating;
  int get reviewCount => 0; // Not in API response, default to 0
}
