import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_service.dart';
import '../../data/models/login_request.dart';
import '../../data/models/login_response.dart';

abstract class AuthService {
  Future<Either<Failure, LoginResponse>> login({
    required String emailOrPhone,
    required String password,
  });
}

class AuthServiceImpl implements AuthService {
  final ApiService _apiService;

  AuthServiceImpl({ApiService? apiService}) 
    : _apiService = apiService ?? ApiService();

  @override
  Future<Either<Failure, LoginResponse>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final loginRequest = LoginRequest(
        emailOrPhone: emailOrPhone,
        password: password,
      );

      final response = await _apiService.post(
        '/api/auth/login',
        data: loginRequest.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data);
        return Right(loginResponse);
      } else {
        return Left(ServerFailure(
          'Login failed with status: ${response.statusCode}',
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(
        'Unexpected error during login: ${e.toString()}',
      ));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure(
          'Connection timeout. Please check your internet connection.',
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        
        // Safely extract error message from response
        String errorMessage = 'Server error occurred';
        final responseData = error.response?.data;
        
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message']?.toString() ?? 
                        responseData['error']?.toString() ?? 
                        errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        switch (statusCode) {
          case 400:
            return ValidationFailure(errorMessage);
          case 401:
            return AuthenticationFailure(errorMessage);
          case 403:
            return AuthenticationFailure(errorMessage);
          case 404:
            return ServerFailure('Login endpoint not found');
          case 500:
          default:
            return ServerFailure(errorMessage);
        }
      
      case DioExceptionType.cancel:
        return NetworkFailure('Request was cancelled');
      
      case DioExceptionType.connectionError:
        // Check if it's a timeout error based on the message
        if (error.message?.contains('timeout') == true) {
          return NetworkFailure(
            'Connection timeout. Please check if the server is running or try again later.',
          );
        }
        return NetworkFailure(
          'No internet connection. Please check your network settings.',
        );
      
      case DioExceptionType.badCertificate:
        return NetworkFailure('SSL certificate error');
      
      case DioExceptionType.unknown:
        // Check if it's a timeout error
        if (error.message?.contains('timeout') == true || 
            error.message?.contains('took longer') == true) {
          return NetworkFailure(
            'Request timeout. The server may be slow or unavailable. Please try again.',
          );
        }
        return NetworkFailure(
          'Network error: ${error.message ?? "Unknown error"}',
        );
    }
  }
}