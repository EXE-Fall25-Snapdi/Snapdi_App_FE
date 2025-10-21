import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../data/models/manual_payment_request.dart';

class PaymentService {
  static const String baseUrl = 'http://your-backend-ip:port/api';
  // TODO: Thay đổi baseUrl theo môi trường
  // Development: 'http://10.0.2.2:8080/api' (Android Emulator)
  // Production: 'https://snapdi-api.com/api'
  
  /// Upload ảnh hóa đơn lên server
  /// Returns: URL của ảnh đã upload
  Future<String> uploadProofImage(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/payment/upload-proof');
      
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'proofImage', // Key name backend expect
          imageFile.path,
        ));

      // Thêm headers nếu cần authentication
      // final token = await _getAuthToken();
      // request.headers['Authorization'] = 'Bearer $token';

      print('🚀 Uploading image to: $uri');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 Upload status: ${response.statusCode}');
      print('📝 Upload response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Xử lý các cấu trúc response khác nhau
        String? imageUrl;
        
        if (data.containsKey('imageUrl')) {
          imageUrl = data['imageUrl'] as String?;
        } else if (data.containsKey('data')) {
          imageUrl = data['data']['imageUrl'] as String?;
        } else if (data.containsKey('url')) {
          imageUrl = data['url'] as String?;
        }
        
        if (imageUrl != null && imageUrl.isNotEmpty) {
          print('✅ Upload success: $imageUrl');
          return imageUrl;
        } else {
          throw Exception('Không tìm thấy URL ảnh trong response');
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Upload error: $e');
      rethrow;
    }
  }

  /// Xác nhận thanh toán thủ công
  /// Returns: true nếu thành công
  Future<bool> confirmManualPayment(ManualPaymentRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/payment/manual-payment');
      
      print('🚀 Confirming payment to: $uri');
      print('📦 Request data: ${request.toJson()}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Thêm auth token nếu cần
          // 'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode(request.toJson()),
      );

      print('📊 Payment status: ${response.statusCode}');
      print('📝 Payment response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Kiểm tra success
        final success = data['success'] as bool? ?? true;
        
        if (success) {
          print('✅ Payment confirmed successfully');
          return true;
        } else {
          final message = data['message'] as String? ?? 'Payment confirmation failed';
          throw Exception(message);
        }
      } else {
        throw Exception('Payment failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Payment error: $e');
      rethrow;
    }
  }

}
