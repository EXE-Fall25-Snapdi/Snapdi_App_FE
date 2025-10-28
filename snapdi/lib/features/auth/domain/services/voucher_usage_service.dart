import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_service.dart';
import '../entities/voucher_usage.dart';

abstract class VoucherUsageService {
  Future<Either<Failure, int>> countVoucherUsage({required int voucherId});
  Future<Either<Failure, Unit>> applyVoucher({
    required int bookingId,
    required String code,
  });
  Future<Either<Failure, Unit>> addVoucherUsage({required VoucherUsage voucherUsage});
}

class VoucherUsageServiceImpl implements VoucherUsageService {
  final ApiService _apiService;

  VoucherUsageServiceImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<Either<Failure, int>> countVoucherUsage({required int voucherId}) async {
    try {
      final response = await _apiService.get('/api/VoucherUsages/count?voucherId=$voucherId');

      if (response.statusCode == 200 && response.data != null) {
        final count = response.data['count'] as int;
        return Right(count);
      } else {
        return Left(ServerFailure('Failed to get voucher usage count: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error while counting voucher usage: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> applyVoucher({
    required int bookingId,
    required String code,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/VoucherUsages/apply',
        data: {'bookingId': bookingId, 'code': code},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return const Right(unit);
      } else {
        return Left(ServerFailure('Failed to apply voucher: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error while applying voucher: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addVoucherUsage({required VoucherUsage voucherUsage}) async {
    try {
      final response = await _apiService.post(
        '/api/VoucherUsages',
        data: voucherUsage.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(unit);
      } else {
        return Left(ServerFailure('Failed to add voucher usage: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error while adding voucher usage: ${e.toString()}'));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure('Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String errorMessage = 'Server error occurred';
        final responseData = error.response?.data;

        if (responseData is Map<String, dynamic>) {
          errorMessage =
              responseData['message']?.toString() ?? responseData['error']?.toString() ?? errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }

        switch (statusCode) {
          case 400:
            return ValidationFailure(errorMessage);
          case 401:
          case 403:
            return AuthenticationFailure(errorMessage);
          case 404:
            return ServerFailure('Endpoint not found');
          case 500:
          default:
            return ServerFailure(errorMessage);
        }

      case DioExceptionType.cancel:
        return NetworkFailure('Request was cancelled');

      case DioExceptionType.connectionError:
        if (error.message?.contains('timeout') == true) {
          return NetworkFailure(
            'Connection timeout. Server may be down. Please try again later.',
          );
        }
        return NetworkFailure('No internet connection. Please check your network.');

      case DioExceptionType.badCertificate:
        return NetworkFailure('SSL certificate error');

      case DioExceptionType.unknown:
        if (error.message?.contains('timeout') == true) {
          return NetworkFailure('Request timeout. Server may be slow or unavailable.');
        }
        return NetworkFailure('Network error: ${error.message ?? "Unknown error"}');
    }
  }
}
