import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_suggestion.dart';

class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  final http.Client _client = http.Client();

  // Search for locations based on query
  Future<List<LocationSuggestion>> searchLocation(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/search').replace(queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': '5',
          'countrycodes': 'vn', // Limit to Vietnam
        }),
        headers: {
          'User-Agent': 'Snapdi-App/1.0',
          'Accept-Language': 'vi,en',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => LocationSuggestion.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to search location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching location: $e');
    }
  }

  // Reverse geocoding - get address from coordinates
  Future<LocationSuggestion?> reverseGeocode(double lat, double lon) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/reverse').replace(queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'json',
          'addressdetails': '1',
        }),
        headers: {
          'User-Agent': 'Snapdi-App/1.0',
          'Accept-Language': 'vi,en',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LocationSuggestion.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
