import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/environment.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/booking_request.dart';
import '../models/booking_response.dart';

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

      final response = await http.post(
        Uri.parse('${Environment.apiBaseUrl}/api/Booking'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return BookingResponse(
          success: true,
          message: 'Booking created successfully',
          data: jsonResponse,
        );
      } else {
        final errorBody = jsonDecode(response.body);
        return BookingResponse(
          success: false,
          message: errorBody['message'] ?? 'Failed to create booking',
        );
      }
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Error creating booking: ${e.toString()}',
      );
    }
  }
}
