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
  final SearchCenter? searchCenter;
  final double? radiusInKm;

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
    this.searchCenter,
    this.radiusInKm,
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
      searchCenter: json['searchCenter'] != null 
          ? SearchCenter.fromJson(json['searchCenter']) 
          : null,
      radiusInKm: json['radiusInKm']?.toDouble(),
    );
  }
  
  // Compatibility getter for old code
  List<SnapperInfo> get items => snappers;
}

class SearchCenter {
  final double latitude;
  final double longitude;

  SearchCenter({
    required this.latitude,
    required this.longitude,
  });

  factory SearchCenter.fromJson(Map<String, dynamic> json) {
    return SearchCenter(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}

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
  final String workLocation;
  final List<PhotoType> photoTypes;
  final List<StyleInfo> styles;
  final int portfolioCount;
  final List<String> portfolioUrls;
  final CurrentLocation? currentLocation;
  final double? distanceInKm;

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
    required this.workLocation,
    required this.photoTypes,
    required this.styles,
    required this.portfolioCount,
    required this.portfolioUrls,
    this.currentLocation,
    this.distanceInKm,
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
      currentLocation: json['currentLocation'] != null
          ? CurrentLocation.fromJson(json['currentLocation'])
          : null,
      distanceInKm: json['distanceInKm']?.toDouble(),
    );
  }
  
  // Compatibility getters for old code
  String get fullName => name;
  String get level => levelPhotographer;
  double get rating => avgRating;
  int get reviewCount => 0; // Not in API response, default to 0
}

class CurrentLocation {
  final double latitude;
  final double longitude;

  CurrentLocation({
    required this.latitude,
    required this.longitude,
  });

  factory CurrentLocation.fromJson(Map<String, dynamic> json) {
    return CurrentLocation(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}
