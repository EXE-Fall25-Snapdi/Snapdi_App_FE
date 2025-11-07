import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/constants/environment.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../features/auth/domain/services/auth_service.dart';
import '../models/review_model.dart';

class ReviewService {
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
      final refreshResult = await _authService.refreshToken();

      return refreshResult.fold(
        (failure) {
          // Refresh failed, return original 401 response
          return response;
        },
        (loginResponse) async {
          // Refresh succeeded, retry with new token
          return await request(loginResponse.token);
        },
      );
    }

    return response;
  }

  /// Create a review for a completed booking
  Future<Either<Failure, bool>> createReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      HttpOverrides.global = _DevHttpOverrides();

      final response = await _makeAuthenticatedRequest(
        request: (token) async {
          return await http.post(
            Uri.parse('${Environment.apiBaseUrl}/api/Reviews'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'bookingId': bookingId,
              'rating': rating,
              'comment': comment ?? '',
            }),
          );
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Review created successfully: ${response.statusCode}');
        return const Right(true);
      } else if (response.statusCode == 401) {
        // Token refresh failed or still unauthorized
        await _tokenStorage.clearAll();
        return Left(
          AuthenticationFailure(
            'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          ),
        );
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ??
              errorBody['Message'] ??
              'Không thể gửi đánh giá: ${response.statusCode}';
          
          if (response.statusCode == 400) {
            return Left(ValidationFailure(errorMessage));
          } else if (response.statusCode == 404) {
            return Left(ServerFailure('Không tìm thấy đơn đặt chỗ'));
          } else {
            return Left(ServerFailure(errorMessage));
          }
        } catch (e) {
          return Left(
            ServerFailure('Không thể gửi đánh giá: ${response.statusCode}'),
          );
        }
      }
    } catch (e) {
      print('Unexpected error creating review: $e');
      
      if (e.toString().contains('No authentication token')) {
        return Left(
          AuthenticationFailure('Vui lòng đăng nhập để tiếp tục'),
        );
      }
      
      return Left(
        NetworkFailure('Lỗi kết nối: Vui lòng kiểm tra mạng của bạn'),
      );
    }
  }

  /// Check if a booking already has a review
  Future<Either<Failure, bool>> hasReview(int bookingId) async {
    try {
      HttpOverrides.global = _DevHttpOverrides();
      
      final response = await _makeAuthenticatedRequest(
        request: (token) async {
          return await http.get(
            Uri.parse(
              '${Environment.apiBaseUrl}/api/Reviews/booking/$bookingId',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        },
      );

      if (response.statusCode == 200) {
        // Review exists - the API returns the review object
        final jsonResponse = jsonDecode(response.body);
        // If we get a response with reviewId, it means review exists
        return Right(jsonResponse['reviewId'] != null);
      } else if (response.statusCode == 401) {
        await _tokenStorage.clearAll();
        return Left(
          AuthenticationFailure('Phiên đăng nhập đã hết hạn'),
        );
      } else if (response.statusCode == 404) {
        // No review found, return false
        return const Right(false);
      } else {
        return const Right(false);
      }
    } catch (e) {
      print('Error checking review: $e');
      // If check fails, assume no review exists and let backend handle duplicates
      return const Right(false);
    }
  }

  /// Get review details for a booking
  Future<Either<Failure, ReviewModel?>> getReview(int bookingId) async {
    try {
      HttpOverrides.global = _DevHttpOverrides();
      
      final response = await _makeAuthenticatedRequest(
        request: (token) async {
          return await http.get(
            Uri.parse(
              '${Environment.apiBaseUrl}/api/Reviews/booking/$bookingId',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final review = ReviewModel.fromJson(jsonResponse);
        return Right(review);
      } else if (response.statusCode == 401) {
        await _tokenStorage.clearAll();
        return Left(
          AuthenticationFailure('Phiên đăng nhập đã hết hạn'),
        );
      } else if (response.statusCode == 404) {
        // No review found
        return const Right(null);
      } else {
        return Left(
          ServerFailure('Không thể tải đánh giá'),
        );
      }
    } catch (e) {
      print('Error getting review: $e');
      return Left(
        NetworkFailure('Lỗi kết nối: Vui lòng kiểm tra mạng của bạn'),
      );
    }
  }

  /// Update an existing review
  Future<Either<Failure, bool>> updateReview({
    required int reviewId,
    required int rating,
    String? comment,
  }) async {
    try {
      HttpOverrides.global = _DevHttpOverrides();

      final response = await _makeAuthenticatedRequest(
        request: (token) async {
          return await http.put(
            Uri.parse('${Environment.apiBaseUrl}/api/Reviews/$reviewId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'rating': rating,
              'comment': comment ?? '',
            }),
          );
        },
      );

      if (response.statusCode == 200) {
        print('Review updated successfully: ${response.statusCode}');
        return const Right(true);
      } else if (response.statusCode == 401) {
        await _tokenStorage.clearAll();
        return Left(
          AuthenticationFailure(
            'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          ),
        );
      } else {
        try {
          final jsonResponse = jsonDecode(response.body);
          final errorMessage = jsonResponse['message'] ?? 
              'Không thể cập nhật đánh giá: ${response.statusCode}';
          
          if (response.statusCode == 400) {
            return Left(ValidationFailure(errorMessage));
          } else if (response.statusCode == 404) {
            return Left(ServerFailure('Không tìm thấy đánh giá'));
          } else {
            return Left(ServerFailure(errorMessage));
          }
        } catch (e) {
          return Left(
            ServerFailure('Không thể cập nhật đánh giá: ${response.statusCode}'),
          );
        }
      }
    } catch (e) {
      print('Unexpected error updating review: $e');
      
      if (e.toString().contains('No authentication token')) {
        return Left(
          AuthenticationFailure('Vui lòng đăng nhập để tiếp tục'),
        );
      }
      
      return Left(
        NetworkFailure('Lỗi kết nối: Vui lòng kiểm tra mạng của bạn'),
      );
    }
  }

  /// Delete a review
  Future<Either<Failure, bool>> deleteReview(int reviewId) async {
    try {
      HttpOverrides.global = _DevHttpOverrides();

      final response = await _makeAuthenticatedRequest(
        request: (token) async {
          return await http.delete(
            Uri.parse('${Environment.apiBaseUrl}/api/Reviews/$reviewId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        },
      );

      if (response.statusCode == 200) {
        print('Review deleted successfully: ${response.statusCode}');
        return const Right(true);
      } else if (response.statusCode == 401) {
        await _tokenStorage.clearAll();
        return Left(
          AuthenticationFailure(
            'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          ),
        );
      } else {
        try {
          final jsonResponse = jsonDecode(response.body);
          final errorMessage = jsonResponse['message'] ?? 
              'Không thể xóa đánh giá: ${response.statusCode}';
          
          if (response.statusCode == 404) {
            return Left(ServerFailure('Không tìm thấy đánh giá'));
          } else {
            return Left(ServerFailure(errorMessage));
          }
        } catch (e) {
          return Left(
            ServerFailure('Không thể xóa đánh giá: ${response.statusCode}'),
          );
        }
      }
    } catch (e) {
      print('Unexpected error deleting review: $e');
      
      if (e.toString().contains('No authentication token')) {
        return Left(
          AuthenticationFailure('Vui lòng đăng nhập để tiếp tục'),
        );
      }
      
      return Left(
        NetworkFailure('Lỗi kết nối: Vui lòng kiểm tra mạng của bạn'),
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
