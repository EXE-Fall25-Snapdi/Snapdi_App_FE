import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../constants/environment.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;

  // Singleton pattern
  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  ApiService._internal() {
    _dio = Dio();
    _setupDio();
  }

  Dio get dio => _dio;

  void _setupDio() {
    // Get base URL from environment
    final baseUrl = Environment.apiBaseUrl;

    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(minutes: 2), // Increased for development
      receiveTimeout: const Duration(minutes: 2), // Increased for development
      sendTimeout: const Duration(minutes: 1),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add authorization token if available
          // TODO: Get token from secure storage
          // final token = await _getAuthToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }

          // Request logging for development
          // print('REQUEST[${options.method}] => ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Response logging for development
          // print('RESPONSE[${response.statusCode}]');
          handler.next(response);
        },
        onError: (error, handler) {
          // Error logging for development
          // print('ERROR[${error.response?.statusCode}]: ${error.message}');
          handler.next(error);
        },
      ),
    );

    // SSL certificate handling for development
    if (baseUrl.contains('localhost') ||
        baseUrl.contains('10.0.2.2') ||
        baseUrl.contains('192.168.') ||
        baseUrl.startsWith('https://192.168.')) {
      // Skip SSL certificate verification for development
      // Note: This is only for development purposes
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
      // SSL certificate verification disabled for development
    }
  }

  // Method to update authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Method to clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Generic GET method
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Generic POST method
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Generic PUT method
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Generic PATCH method
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Generic DELETE method
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
