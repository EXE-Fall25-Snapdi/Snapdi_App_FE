import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/cloudinary_upload_response.dart';
import '../../data/models/portfolio_create_response.dart';

abstract class PortfolioService {
  Future<Either<Failure, CloudinaryUploadResponse>> uploadImagesToCloudinary(
    List<File> images,
    String uploadType,
  );

  Future<Either<Failure, PortfolioCreateResponse>> createMultiplePortfolios(
    List<String> photoUrls,
  );

  Future<Either<Failure, void>> deletePortfolio(int portfolioId);

  Future<Either<Failure, void>> deleteFromCloudinary(String publicId);
}

class PortfolioServiceImpl implements PortfolioService {
  final _apiService = ApiService();
  final _tokenStorage = TokenStorage.instance;

  @override
  Future<Either<Failure, CloudinaryUploadResponse>> uploadImagesToCloudinary(
    List<File> images,
    String uploadType,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      // Create multipart files
      List<MultipartFile> files = [];
      for (var image in images) {
        files.add(
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        );
      }

      final formData = FormData.fromMap({
        'files': files,
        'uploadType': uploadType,
      });

      final response = await _apiService.dio.post(
        '/api/Cloudinary/upload-multiple',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final uploadResponse = CloudinaryUploadResponse.fromJson(response.data);
      return Right(uploadResponse);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to upload images: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PortfolioCreateResponse>> createMultiplePortfolios(
    List<String> photoUrls,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final response = await _apiService.dio.post(
        '/api/PhotoPortfolio/multiple',
        data: {'photoUrls': photoUrls},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final createResponse = PortfolioCreateResponse.fromJson(response.data);
      return Right(createResponse);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure('Failed to create portfolios: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deletePortfolio(int portfolioId) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      await _apiService.dio.delete(
        '/api/PhotoPortfolio/$portfolioId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to delete portfolio: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFromCloudinary(String publicId) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      await _apiService.dio.delete(
        '/api/Cloudinary/delete',
        queryParameters: {'publicId': publicId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure('Failed to delete from Cloudinary: ${e.toString()}'),
      );
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
