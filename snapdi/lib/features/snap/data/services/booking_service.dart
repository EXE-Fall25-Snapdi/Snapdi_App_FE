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
            message: errorBody['message'] ?? 'Failed to create booking: ${response.statusCode}',
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
}
