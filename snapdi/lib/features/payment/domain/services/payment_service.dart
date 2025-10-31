import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  Future<int> confirmManualPayment(ManualPaymentRequest request) async {
    try {
      // 1) Lấy token từ secure storage, fallback SharedPreferences
      final secureToken = await TokenStorage.instance.getAccessToken();
      final prefs = await SharedPreferences.getInstance();
      final legacyToken = prefs.getString(AppConstants.authTokenKey);
      final token = (secureToken?.isNotEmpty == true) ? secureToken : legacyToken;

      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized: no auth token found');
      }
      print('🔐 Using auth token: ${token.substring(0, min(12, token.length))}...');

      // 2) Gắn Authorization vào Dio
      final dio = ApiService().dio;
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Content-Type'] = 'application/json';

      // 3) Gửi JSON (không multipart)
      final response = await dio.post(
        '/api/payments/confirm-manual-payment',
        data: {
          'bookingId': request.bookingId,
          'feePolicyId': request.feePolicyId, // cố định = 1 từ màn hình
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final paymentId = data['paymentId'] as int?;
      if (paymentId == null) {
        throw Exception('paymentId not found in response');
      }
      return paymentId;
      }
      throw Exception('Payment failed: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ DioException during manual-payment: status=${e.response?.statusCode}, data=${e.response?.data}, message=${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error confirming manual payment: $e');
      rethrow;
    }
  }


  Future<bool> confirmPaid(ManualPaymentRequest request, int paymentId) async {
    try {
      // 1) Lấy token từ secure storage, fallback SharedPreferences
      final secureToken = await TokenStorage.instance.getAccessToken();
      final prefs = await SharedPreferences.getInstance();
      final legacyToken = prefs.getString(AppConstants.authTokenKey);
      final token = (secureToken?.isNotEmpty == true) ? secureToken : legacyToken;

      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized: no auth token found');
      }
      print('🔐 Using auth token: ${token.substring(0, min(12, token.length))}...');

      // 2) Gắn Authorization vào Dio
      final dio = ApiService().dio;
      dio.options.headers['Authorization'] = 'Bearer $token';

      // 3) Gửi JSON (không multipart)
      final response = await dio.put(
        '/api/payments/confirm-paid',
        queryParameters: {'paymentId': paymentId},
        data: {
          'bookingId': request.bookingId,
          'feePolicyId': request.feePolicyId, // cố định = 1 từ màn hình
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return (data['success'] as bool?) ?? false;
      }
      throw Exception('Payment failed: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ DioException during manual-payment: status=${e.response?.statusCode}, data=${e.response?.data}, message=${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error confirming manual payment: $e');
      rethrow;
    }
  }

  Future<bool> CancelManualPayment(ManualPaymentRequest request, int paymentId) async {
    try {
      // 1) Lấy token từ secure storage, fallback SharedPreferences
      final secureToken = await TokenStorage.instance.getAccessToken();
      final prefs = await SharedPreferences.getInstance();
      final legacyToken = prefs.getString(AppConstants.authTokenKey);
      final token = (secureToken?.isNotEmpty == true) ? secureToken : legacyToken;

      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized: no auth token found');
      }
      print('🔐 Using auth token: ${token.substring(0, min(12, token.length))}...');

      // 2) Gắn Authorization vào Dio
      final dio = ApiService().dio;
      dio.options.headers['Authorization'] = 'Bearer $token';

      // 3) Gửi JSON (không multipart)
      final response = await dio.put(
        '/api/payments/cancel-manual-payment?paymentId=$paymentId',
        data: {
          'bookingId': request.bookingId,
          'feePolicyId': request.feePolicyId, // cố định = 1 từ màn hình
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return (data['success'] as bool?) ?? false;
      }
      throw Exception('Payment failed: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ DioException during manual-payment: status=${e.response?.statusCode}, data=${e.response?.data}, message=${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error confirming manual payment: $e');
      rethrow;
    }
  }

  Future<String> createPayOSPayment({
    required int bookingId,
  }) async {
    try {
      // 1) Lấy token từ secure storage, fallback SharedPreferences
      final secureToken = await TokenStorage.instance.getAccessToken();
      final prefs = await SharedPreferences.getInstance();
      final legacyToken = prefs.getString(AppConstants.authTokenKey);
      final token = (secureToken?.isNotEmpty == true) ? secureToken : legacyToken;

      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized: no auth token found');
      }
      print('🔐 Using auth token for PayOS: ${token.substring(0, min(12, token.length))}...');

      // 2) Gắn Authorization vào Dio
      final dio = ApiService().dio;
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Content-Type'] = 'application/json';

      print('💳 Creating PayOS payment for booking: $bookingId');

      // 3) Gửi request tạo PayOS payment - chỉ cần bookingId
      final response = await dio.post(
        '/api/Payments/payos/create-payment',
        data: {
          'bookingId': bookingId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        print('✅ PayOS response: $data');

        // Lấy paymentUrl từ response
        final paymentUrl = data['paymentUrl'] as String?;
        final success = data['success'] as bool?;
        final message = data['message'] as String?;

        if (success == true && paymentUrl != null && paymentUrl.isNotEmpty) {
          print('✅ PayOS payment URL created: $paymentUrl');
          print('📝 Message: $message');
          return paymentUrl;
        } else {
          throw Exception('Không tìm thấy paymentUrl trong response hoặc success = false');
        }
      } else {
        throw Exception('PayOS payment creation failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException during PayOS create-payment: status=${e.response?.statusCode}, data=${e.response?.data}, message=${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized (401). Token missing/expired. Please login again.');
      }
      rethrow;
    } catch (e) {
      print('❌ Error creating PayOS payment: $e');
      rethrow;
    }
  }

}
