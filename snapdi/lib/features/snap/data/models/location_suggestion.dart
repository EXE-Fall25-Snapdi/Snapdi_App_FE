class LocationSuggestion {
  final String displayName;
  final double lat;
  final double lon;
  final String? city;
  final String? country;
  final String type;

  LocationSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
    this.city,
    this.country,
    required this.type,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      city: json['address']?['city'] ?? 
            json['address']?['town'] ?? 
            json['address']?['village'] ??
            json['address']?['state'],
      country: json['address']?['country'],
      type: json['type'] ?? '',
    );
  }

  String get shortName {
    if (city != null) {
      final parts = displayName.split(',');
      return parts.isNotEmpty ? parts[0].trim() : displayName;
      
    }
    return city!;
  }
}
