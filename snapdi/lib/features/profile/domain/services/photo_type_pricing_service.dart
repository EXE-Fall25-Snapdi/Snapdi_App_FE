import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/models/photo_type_with_pricing.dart';
import '../../../auth/data/models/photographer_photo_type.dart';

abstract class PhotoTypePricingService {
  Future<Either<Failure, List<PhotoTypeWithPricing>>> getMyPhotoTypes();
  Future<Either<Failure, bool>> updatePhotoTypePrices(
    List<PhotographerPhotoType> prices,
  );
}

class PhotoTypePricingServiceImpl implements PhotoTypePricingService {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  PhotoTypePricingServiceImpl({
    ApiService? apiService,
    TokenStorage? tokenStorage,
  }) : _apiService = apiService ?? ApiService(),
       _tokenStorage = tokenStorage ?? TokenStorage.instance;

  @override
  Future<Either<Failure, List<PhotoTypeWithPricing>>> getMyPhotoTypes() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final response = await _apiService.get(
        '/api/PhotographerPhotoType/my-photo-types',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final photoTypes = data
            .map((json) => PhotoTypeWithPricing.fromJson(json))
            .toList();
        return Right(photoTypes);
      } else {
        return Left(
          ServerFailure('Failed to get photo types: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> updatePhotoTypePrices(
    List<PhotographerPhotoType> prices,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final requestBody = prices.map((p) => p.toJson()).toList();

      final response = await _apiService.put(
        '/api/PhotographerPhotoType/update-prices',
        data: requestBody,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return Left(
          ServerFailure(
            'Failed to update photo type prices: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return AuthenticationFailure('Unauthorized');
        } else if (statusCode == 404) {
          return ServerFailure('Resource not found');
        }
        return ServerFailure(
          'Server error: ${error.response?.data?['message'] ?? 'Unknown error'}',
        );
      case DioExceptionType.cancel:
        return ServerFailure('Request cancelled');
      default:
        return NetworkFailure('Network error occurred');
    }
  }
}
