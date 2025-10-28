class FindSnappersRequest {
  final String workLocation;
  final String? level;
  final List<int> photoTypeIds;
  final List<int> styleIds;
  final bool isAvailable;
  final int? minPrice;
  final int? maxPrice;
  final int page;
  final int pageSize;
  final String sortBy;
  final String sortDirection;
  final double? latitude;
  final double? longitude;
  final int? radiusInKm;

  FindSnappersRequest({
    required this.workLocation,
    this.level,
    this.photoTypeIds = const [],
    this.styleIds = const [],
    this.isAvailable = true,
    this.minPrice,
    this.maxPrice,
    this.page = 1,
    this.pageSize = 50,
    this.sortBy = 'name',
    this.sortDirection = 'desc',
    this.latitude,
    this.longitude,
    this.radiusInKm = 100,
  });

  Map<String, dynamic> toJson() {
    return {
      'workLocation': workLocation,
      if (level != null) 'level': level,
      'photoTypeIds': photoTypeIds,
      'styleIds': styleIds,
      'isAvailable': isAvailable,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      'page': page,
      'pageSize': pageSize,
      'sortBy': sortBy,
      'sortDirection': sortDirection,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radiusInKm != null) 'radiusInKm': radiusInKm,
    };
  }
}
