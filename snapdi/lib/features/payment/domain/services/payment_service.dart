import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/constants/app_constants.dart';
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

      // Attach Authorization header if token available
      final uploadToken = await TokenStorage.instance.getAccessToken();
      if (uploadToken != null && uploadToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $uploadToken';
        print('🔐 Added Authorization header to upload request');
      }
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
  /// Returns the payment status string from server (e.g., 'done', 'pending')
  Future<String> confirmManualPayment(ManualPaymentRequest request) async {
    try {
      final api = ApiService();
      final dio = api.dio;

      // Ensure auth token set in ApiService headers (if available)
      final token = await TokenStorage.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        api.setAuthToken(token);
      }

      // Debug: print token and headers to help diagnose 401
      print('🔐 Stored auth token: ${token == null ? '<null>' : token.substring(0, token.length > 8 ? 8 : token.length) + '...'}');
      print('🔎 Dio headers before request: ${dio.options.headers}');

      // If proofImageUrl is a local file path, send multipart with file using Dio
      final proofPath = request.proofImageUrl;
      Response response;

      // Always send FormData so the server can read form fields (backend expects form data)
      MultipartFile? multipartFile;
      if (proofPath != null && File(proofPath).existsSync()) {
        final filename = proofPath.split(Platform.pathSeparator).last;
        multipartFile = await MultipartFile.fromFile(proofPath, filename: filename);
      }

      final formMap = <String, dynamic>{
        'BookingId': request.bookingId.toString(),
        'Amount': request.amount.toString(),
        'TransactionReference': request.transactionReference ?? '',
      };
      if (multipartFile != null) formMap['proofImage'] = multipartFile;

      final formData = FormData.fromMap(formMap);

      // Note: controller route is api/payments/manual-payment (PaymentsController)
      // Ensure Authorization header is present on the Dio instance and also send in request options
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      print('🔎 Dio headers just before request: ${dio.options.headers}');

      try {
        final reqOptions = token != null && token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null;
        response = await dio.post('/api/payments/manual-payment', data: formData, options: reqOptions);
      } on DioException catch (e) {
        // Provide more context for 401/other failures
        final status = e.response?.statusCode;
        final respData = e.response?.data;
        print('❌ DioException during manual-payment: status=$status, data=$respData, message=${e.message}');
        // If token appears missing, give a specific hint
        if (token == null || token.isEmpty) {
          throw Exception('Unauthorized: no auth token found. Please log in.');
        }
        // Otherwise rethrow with backend response info
        throw Exception('Request failed: status=$status, body=$respData');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final success = data['success'] as bool? ?? true;
        if (!success) throw Exception(data['message'] ?? 'Payment confirmation failed');

        // return server status field if present (status or paymentStatus)
        final status = (data['status'] ?? data['paymentStatus'] ?? data['paymentStatusName']) as String?;
        return status ?? 'pending';
      }

      throw Exception('Payment failed: ${response.statusCode} - ${response.statusMessage}');
    } catch (e) {
      rethrow;
    }
  }

}
