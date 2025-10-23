import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/storage/token_storage.dart';
import '../../../../core/constants/environment.dart';
import '../../../auth/domain/services/auth_service.dart';

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
    } catch (e, stackTrace) {
      if (e.toString().contains('TOKEN_EXPIRED')) {
        print('PhotographerService: Token expired, attempting refresh...');
        
        // Try to refresh the token
        final refreshResult = await _authService.refreshToken();
        
        return refreshResult.fold(
          (failure) {
            print('PhotographerService: Token refresh failed - ${failure.message}');
            return false;
          },
          (loginResponse) {
            print('PhotographerService: Token refreshed successfully, retrying request...');
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
      
      print('PhotographerService: Status update failed - $e');
      print('Stack trace: $stackTrace');
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

      print('PhotographerService: Updating status for photographer #$photographerId');
      print('PhotographerService: Request body - $requestBody');

      final response = await client.patch(
        Uri.parse('${Environment.apiBaseUrl}/api/Photographer/$photographerId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('PhotographerService: Response status - ${response.statusCode}');

      // Handle success status codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('PhotographerService: Status updated successfully');
        return true;
      } else if (response.statusCode == 401) {
        print('PhotographerService: Unauthorized - token may be expired');
        throw Exception('TOKEN_EXPIRED');
      } else {
        print('PhotographerService: Request failed with status ${response.statusCode}');
        print('PhotographerService: Response body - ${response.body}');
        throw Exception('Status update failed with code ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      if (e.toString().contains('TOKEN_EXPIRED')) {
        rethrow; // Let the parent method handle token expiration
      }
      
      print('PhotographerService: Error in _performStatusUpdate - $e');
      print('Stack trace: $stackTrace');
      rethrow; // Rethrow to provide meaningful error to caller
    } finally {
      client.close();
    }
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
