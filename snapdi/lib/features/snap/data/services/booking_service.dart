import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/environment.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/booking_request.dart';
import '../models/booking_response.dart';
import '../models/booking_list_response.dart';

class BookingService {
  final TokenStorage _tokenStorage = TokenStorage.instance;

  Future<BookingResponse> createBooking(BookingRequest request) async {
    try {
      final token = await _tokenStorage.getAccessToken();

      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'No authentication token found',
        );
      }

      final requestBody = jsonEncode(request.toJson());

      final response = await http.post(
        Uri.parse('${Environment.apiBaseUrl}/api/Booking'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return BookingResponse.fromJson(jsonResponse);
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return BookingResponse(
            success: false,
            message:
                errorBody['message'] ??
                'Failed to create booking: ${response.statusCode}',
          );
        } catch (e) {
          return BookingResponse(
            success: false,
            message: 'Failed to create booking: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Error creating booking: ${e.toString()}',
      );
    }
  }

  Future<BookingResponse> updateBookingStatus(
    int bookingId,
    int statusId,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'No authentication token found',
        );
      }

      // Bypass SSL certificate verification for development (same pattern as other services)
      HttpOverrides.global = _DevHttpOverrides();

      final requestBody = jsonEncode(statusId);

      final response = await http.put(
        Uri.parse('${Environment.apiBaseUrl}/api/Booking/$bookingId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return BookingResponse.fromJson(jsonResponse);
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return BookingResponse(
            success: false,
            message:
                errorBody['message'] ??
                'Failed to update booking status: ${response.statusCode}',
          );
        } catch (e) {
          return BookingResponse(
            success: false,
            message: 'Failed to update booking status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Error updating booking status: ${e.toString()}',
      );
    }
  }

  /// Get bookings for the currently authenticated user.
  /// The API endpoint is GET /api/Booking/me and returns a paged result with items + paging metadata.
  Future<BookingListResponse?> getMyBookings({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return null;
      }

      // Bypass SSL certificate verification for development
      HttpOverrides.global = _DevHttpOverrides();

      final uri = Uri.parse('${Environment.apiBaseUrl}/api/Booking/me').replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return BookingListResponse.fromJson(jsonResponse);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get a single booking by id: GET /api/Booking/{id}
  Future<BookingResponse> getBookingById(int bookingId) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'No authentication token found',
        );
      }

      // Bypass SSL certificate verification for development
      HttpOverrides.global = _DevHttpOverrides();

      final response = await http.get(
        Uri.parse('${Environment.apiBaseUrl}/api/Booking/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return BookingResponse.fromJson(jsonResponse);
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return BookingResponse(
            success: false,
            message:
                errorBody['message'] ??
                'Failed to fetch booking: ${response.statusCode}',
          );
        } catch (e) {
          return BookingResponse(
            success: false,
            message: 'Failed to fetch booking: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Error fetching booking: ${e.toString()}',
      );
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
