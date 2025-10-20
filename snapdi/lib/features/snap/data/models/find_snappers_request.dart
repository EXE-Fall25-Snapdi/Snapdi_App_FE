class FindSnappersRequest {
  final String city;
  final String level;
  final List<int> styleIds;
  final bool isAvailable;
  final int page;
  final int pageSize;
  final String sortBy;
  final String sortDirection;

  FindSnappersRequest({
    required this.city,
    this.level = 'Người Mới',
    this.styleIds = const [],
    this.isAvailable = true,
    this.page = 1,
    this.pageSize = 3,
    this.sortBy = 'rating',
    this.sortDirection = 'desc',
  });

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'level': level,
      'styleIds': styleIds,
      'isAvailable': isAvailable,
      'page': page,
      'pageSize': pageSize,
      'sortBy': sortBy,
      'sortDirection': sortDirection,
    };
  }
}
