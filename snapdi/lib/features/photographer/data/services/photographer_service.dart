import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/storage/token_storage.dart';
import '../../../../core/constants/environment.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../snap/data/models/pending_booking.dart';

/// Service for photographer-specific API calls
class PhotographerService {
  final TokenStorage _tokenStorage = TokenStorage.instance;
  final AuthService _authService;

  PhotographerService({required AuthService authService})
      : _authService = authService;

  http.Client _createClient() {
    return http.Client();
  }
  /// Update photographer availability status and optionally current location
  /// 
  /// Sample request: 
  /// ```json
  /// {
  ///   "isAvailable": true,
  ///   "currentLocation": {
  ///     "latitude": 10.762622,
  ///     "longitude": 106.660172
  ///   }
  /// }
  /// ```
  Future<bool> updateStatus({
    required int photographerId,
    required bool isAvailable,
    double? latitude,
    double? longitude,
  }) async {
    // Bypass SSL certificate verification for development only
    if (Environment.isDevelopment) {
      HttpOverrides.global = _DevHttpOverrides();
    }
    
    try {
      return await _performStatusUpdate(
        photographerId: photographerId,
        isAvailable: isAvailable,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      if (e.toString().contains('TOKEN_EXPIRED')) {
        
        // Try to refresh the token
        final refreshResult = await _authService.refreshToken();
        
        return refreshResult.fold(
          (failure) {
            return false;
          },
          (loginResponse) {
            // Retry the original request with the new token
            return _performStatusUpdate(
              photographerId: photographerId,
              isAvailable: isAvailable,
              latitude: latitude,
              longitude: longitude,
            );
          },
        );
      }

      return false;
    }
  }

  Future<bool> _performStatusUpdate({
    required int photographerId,
    required bool isAvailable,
    double? latitude,
    double? longitude,
  }) async {
    final client = _createClient();
    
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final Map<String, dynamic> requestBody = {
        'isAvailable': isAvailable,
      };

      // Add location if both latitude and longitude are provided
      if (latitude != null && longitude != null) {
        requestBody['currentLocation'] = {
          'latitude': latitude,
          'longitude': longitude,
        };
      }

      final response = await client.patch(
        Uri.parse('${Environment.apiBaseUrl}/api/Photographer/$photographerId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );


      // Handle success status codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('TOKEN_EXPIRED');
      } else {

        throw Exception('Status update failed with code ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('TOKEN_EXPIRED')) {
        rethrow; // Let the parent method handle token expiration
      }

      rethrow; // Rethrow to provide meaningful error to caller
    } finally {
      client.close();
    }
  }

  /// Get pending bookings for a photographer
  /// 
  /// Returns a list of pending booking requests for the photographer
  Future<PendingBookingResponse?> getPendingBookings({
    required int photographerId,
    int page = 1,
    int pageSize = 10,
  }) async {
    // Bypass SSL certificate verification for development only
    if (Environment.isDevelopment) {
      HttpOverrides.global = _DevHttpOverrides();
    }

    final client = _createClient();

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return null;
      }

      final response = await client.get(
        Uri.parse(
          '${Environment.apiBaseUrl}/api/Booking/photographer/$photographerId/pending?page=$page&pageSize=$pageSize',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );


      // Handle success status codes
      if (response.statusCode >= 200 && response.statusCode < 300) {


        final jsonData = jsonDecode(response.body);
        return PendingBookingResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        return null;
      } else {

        return null;
      }
    } catch (e) {

      return null;
    } finally {
      client.close();
    }
  }

  /// Get current photographer availability status and profile
  /// 
  /// Returns photographer data including isAvailable and levelPhotographer
  Future<PhotographerAvailability?> getAvailability(
      {required int photographerId}) async {
    // Bypass SSL certificate verification for development only
    if (Environment.isDevelopment) {
      HttpOverrides.global = _DevHttpOverrides();
    }

    try {
      return await _performGetAvailability(photographerId: photographerId);
    } catch (e) {
      if (e.toString().contains('TOKEN_EXPIRED') ||
          e.toString().contains('401') ||
          e.toString().contains('bad response')) {

        // Try to refresh the token
        final refreshResult = await _authService.refreshToken();

        return refreshResult.fold(
          (failure) {
            // Check if it's refresh token expiration
            if (failure.message.contains('REFRESH_TOKEN_EXPIRED')) {
              throw Exception('REFRESH_TOKEN_EXPIRED');
            }
            // Throw TOKEN_EXPIRED for other auth failures
            throw Exception('TOKEN_EXPIRED: ${failure.message}');
          },
          (loginResponse) {
            // Retry the original request with the new token
            return _performGetAvailability(photographerId: photographerId);
          },
        );
      }

      return null;
    }
  }

  Future<PhotographerAvailability?> _performGetAvailability(
      {required int photographerId}) async {
    final client = _createClient();

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return null;
      }

      final response = await client.get(
        Uri.parse(
          '${Environment.apiBaseUrl}/api/Photographer/me/availability',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );


      // Handle success status codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);
        return PhotographerAvailability.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('TOKEN_EXPIRED');
      } else {
        return null;
      }
    } catch (e) {
      if (e.toString().contains('TOKEN_EXPIRED')) {
        rethrow; // Let the parent method handle token expiration
      }

      rethrow; // Rethrow to provide meaningful error to caller
    } finally {
      client.close();
    }
  }
}

// Model for photographer availability status
class PhotographerAvailability {
  final int userId;
  final String name;
  final String email;
  final bool isAvailable;
  final double avgRating;
  final String? levelPhotographer;
  final PhotographerLocation? currentLocation;

  PhotographerAvailability({
    required this.userId,
    required this.name,
    required this.email,
    required this.isAvailable,
    required this.avgRating,
    this.levelPhotographer,
    this.currentLocation,
  });

  factory PhotographerAvailability.fromJson(Map<String, dynamic> json) {
    return PhotographerAvailability(
      userId: json['userId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      levelPhotographer: json['levelPhotographer'] as String?,
      currentLocation: json['currentLocation'] != null
          ? PhotographerLocation.fromJson(json['currentLocation'])
          : null,
    );
  }
}

// Model for photographer location
class PhotographerLocation {
  final double latitude;
  final double longitude;

  PhotographerLocation({
    required this.latitude,
    required this.longitude,
  });

  factory PhotographerLocation.fromJson(Map<String, dynamic> json) {
    return PhotographerLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
