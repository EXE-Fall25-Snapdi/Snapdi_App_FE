import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/update_user_request.dart';

abstract class UserService {
  Future<Either<Failure, UserProfile>> getCurrentUserProfile();
  Future<Either<Failure, UserProfile>> updateUser(
    int userId,
    UpdateUserRequest request,
  );
}

class UserServiceImpl implements UserService {
  final _apiService = ApiService();
  final _tokenStorage = TokenStorage.instance;

  @override
  Future<Either<Failure, UserProfile>> getCurrentUserProfile() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final response = await _apiService.dio.get(
        '/api/Users/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final userProfile = UserProfile.fromJson(response.data);
      return Right(userProfile);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to get user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUser(
    int userId,
    UpdateUserRequest request,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final response = await _apiService.dio.put(
        '/api/Users/$userId',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final userProfile = UserProfile.fromJson(response.data);
      return Right(userProfile);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to update user: ${e.toString()}'));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Connection timeout');
      case DioExceptionType.badResponse:
        return ServerFailure(error.response?.data['message'] ?? 'Server error');
      case DioExceptionType.cancel:
        return ServerFailure('Request cancelled');
      default:
        return ServerFailure('Network error');
    }
  }
}
