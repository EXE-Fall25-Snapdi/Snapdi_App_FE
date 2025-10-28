import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/models/photographer_detail_response.dart';
import '../../data/models/photo_portfolio.dart';

abstract class ProfileService {
  Future<Either<Failure, PhotographerDetailResponse>> getPhotographerProfile(
    int userId,
  );
  Future<Either<Failure, List<PhotoPortfolio>>> getMyPortfolios();
  Future<Either<Failure, bool>> updatePhotographerProfile(
    int userId,
    String? description,
    String? workLocation,
  );
}

class ProfileServiceImpl implements ProfileService {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  ProfileServiceImpl({ApiService? apiService, TokenStorage? tokenStorage})
    : _apiService = apiService ?? ApiService(),
      _tokenStorage = tokenStorage ?? TokenStorage.instance;

  @override
  Future<Either<Failure, PhotographerDetailResponse>> getPhotographerProfile(
    int userId,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final response = await _apiService.get(
        '/api/Users/$userId/photographer',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final photographerDetail = PhotographerDetailResponse.fromJson(
          response.data,
        );
        return Right(photographerDetail);
      } else {
        return Left(
          ServerFailure(
            'Failed to get photographer profile: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PhotoPortfolio>>> getMyPortfolios() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final response = await _apiService.get(
        '/api/PhotoPortfolio/my-portfolios',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final portfolios = data
            .map((json) => PhotoPortfolio.fromJson(json))
            .toList();
        return Right(portfolios);
      } else {
        return Left(
          ServerFailure('Failed to get portfolios: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> updatePhotographerProfile(
    int userId,
    String? description,
    String? workLocation,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final Map<String, dynamic> requestBody = {};
      if (description != null) {
        requestBody['description'] = description;
      }
      if (workLocation != null) {
        requestBody['workLocation'] = workLocation;
      }

      final response = await _apiService.patch(
        '/api/Photographer/$userId/profile',
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
            'Failed to update photographer profile: ${response.statusCode}',
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
