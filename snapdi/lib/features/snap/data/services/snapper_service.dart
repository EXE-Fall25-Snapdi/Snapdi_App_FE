import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/environment.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/find_snappers_request.dart';
import '../models/find_snappers_response.dart';

class SnapperService {
  final http.Client _client = http.Client();

  Future<FindSnappersResponse> findSnappers(FindSnappersRequest request) async {
    try {
      final token = await TokenStorage.instance.getAccessToken();
      final requestBody = jsonEncode(request.toJson());
      
      final response = await _client.post(
        Uri.parse('${Environment.apiBaseUrl}/api/Users/snappers/find'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return FindSnappersResponse.fromJson(jsonResponse);
      } else {
        return FindSnappersResponse(
          success: false,
          message: 'Failed to find snappers: ${response.statusCode}',
        );
      }
    } catch (e) {
      return FindSnappersResponse(
        success: false,
        message: 'Error finding snappers: $e',
      );
    }
  }
}
