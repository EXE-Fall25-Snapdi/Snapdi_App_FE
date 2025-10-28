import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/environment.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../features/auth/domain/services/auth_service.dart';
import '../models/booking_request.dart';
import '../models/booking_response.dart';
import '../models/booking_list_response.dart';

class BookingService {
  final TokenStorage _tokenStorage = TokenStorage.instance;
  final AuthService _authService = AuthServiceImpl();

  /// Get valid token with automatic refresh if expired
  Future<String?> _getValidToken() async {
    String? token = await _tokenStorage.getAccessToken();

    if (token == null) {
      return null;
    }

    return token;
  }

  /// Retry request with token refresh on 401
  Future<http.Response> _makeAuthenticatedRequest({
    required Future<http.Response> Function(String token) request,
  }) async {
    String? token = await _getValidToken();

    if (token == null) {
      throw Exception('No authentication token available');
    }

    // First attempt
    http.Response response = await request(token);

    // If 401, try to refresh token and retry
    if (response.statusCode == 401) {
      print('Token expired (401), attempting refresh...');

      final refreshResult = await _authService.refreshToken();

      return refreshResult.fold(
        (failure) {
          // Refresh failed, return original 401 response
          print('Token refresh failed: ${failure.message}');
          return response;
        },
        (loginResponse) async {
          // Refresh succeeded, retry with new token
          print('Token refreshed successfully, retrying request...');
          return await request(loginResponse.token);
        },
      );
    }

    return response;
  }

  Future<BookingResponse> createBooking(BookingRequest request) async {
    try {
      HttpOverrides.global = _DevHttpOverrides();

      final response = await _makeAuthenticatedRequest(
        request: (token) async {
          
          return await http.post(
            Uri.parse('${Environment.apiBaseUrl}/api/Booking'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(request.toJson()),
          );
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return BookingResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Token refresh failed or still unauthorized
        await _tokenStorage.clearAll();
        return BookingResponse(
          success: false,
          message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        );
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return BookingResponse(
            success: false,
            message:
                errorBody['message'] ??
                errorBody['Message'] ??
                'Không thể tạo đặt chỗ: ${response.statusCode}',
          );
        } catch (e) {
          return BookingResponse(
            success: false,
            message: 'Không thể tạo đặt chỗ: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error creating booking: $e');
      return BookingResponse(
        success: false,
        message: 'Lỗi khi tạo đặt chỗ: ${e.toString()}',
      );
    }
  }

  Future<BookingResponse> updateBookingStatus(
    int bookingId,
    int statusId,
  ) async {
    try {
      HttpOverrides.global = _DevHttpOverrides();

      final response = await _makeAuthenticatedRequest(
        request: (token) async {
          return await http.put(
            Uri.parse(
              '${Environment.apiBaseUrl}/api/Booking/$bookingId/status',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(statusId),
          );
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return BookingResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await _tokenStorage.clearAll();
        return BookingResponse(
          success: false,
          message: 'Phiên đăng nhập đã hết hạn',
        );
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return BookingResponse(
            success: false,
            message:
                errorBody['message'] ??
                'Không thể cập nhật trạng thái: ${response.statusCode}',
          );
        } catch (e) {
          return BookingResponse(
            success: false,
            message: 'Không thể cập nhật trạng thái: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return BookingResponse(success: false, message: 'Lỗi: ${e.toString()}');
    }
  }

  Future<BookingResponse> updatePhotoLink(
      int bookingId,
      String photoLink,
      ) async {
    try {
      HttpOverrides.global = _DevHttpOverrides();

      final Map<String, dynamic> requestBody = {
        'photoLink': photoLink,
      };

      final response = await _makeAuthenticatedRequest(
        request: (token) async {
          return await http.put(
            Uri.parse(
              '${Environment.apiBaseUrl}/api/Booking/$bookingId/photoLink',
            ),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(requestBody),
          );
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return BookingResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await _tokenStorage.clearAll();
        return BookingResponse(
          success: false,
          message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        );
      } else if (response.statusCode == 404) {
        return BookingResponse(
            success: false,
            message: 'Không tìm thấy đặt lịch với ID $bookingId.');
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return BookingResponse(
            success: false,
            message: errorBody['message'] ??
                'Không thể cập nhật link ảnh: Lỗi ${response.statusCode}',
          );
        } catch (e) {
          return BookingResponse(
            success: false,
            message: 'Không thể cập nhật link ảnh: Lỗi ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return BookingResponse(success: false, message: 'Lỗi kết nối: ${e.toString()}');
    }
  }

  Future<BookingListResponse?> getMyBookings({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      HttpOverrides.global = _DevHttpOverrides();

      final response = await _makeAuthenticatedRequest(
        request: (token) async {
          final uri = Uri.parse('${Environment.apiBaseUrl}/api/Booking/me')
              .replace(
                queryParameters: {
                  'page': page.toString(),
                  'pageSize': pageSize.toString(),
                },
              );

          return await http.get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return BookingListResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await _tokenStorage.clearAll();
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting bookings: $e');
      return null;
    }
  }

  Future<BookingResponse> getBookingById(int bookingId) async {
    try {
      HttpOverrides.global = _DevHttpOverrides();

      final response = await _makeAuthenticatedRequest(
        request: (token) async {
          return await http.get(
            Uri.parse('${Environment.apiBaseUrl}/api/Booking/$bookingId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return BookingResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await _tokenStorage.clearAll();
        return BookingResponse(
          success: false,
          message: 'Phiên đăng nhập đã hết hạn',
        );
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return BookingResponse(
            success: false,
            message:
                errorBody['message'] ??
                'Không thể lấy thông tin đặt chỗ: ${response.statusCode}',
          );
        } catch (e) {
          return BookingResponse(
            success: false,
            message: 'Không thể lấy thông tin đặt chỗ: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return BookingResponse(success: false, message: 'Lỗi: ${e.toString()}');
    }
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
