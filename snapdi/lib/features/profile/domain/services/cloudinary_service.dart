import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/cloudinary_single_upload_response.dart';

abstract class CloudinaryService {
  Future<Either<Failure, CloudinarySingleUploadResponse>> uploadSingleImage(
    File image, {
    required String uploadType,
    String? publicId,
    bool overwrite = true,
  });

  Future<Either<Failure, CloudinaryDeleteResponse>> deleteImage(
    String publicId,
  );

  Future<Either<Failure, String>> getTransformedImageUrl(
    String publicId, {
    int? width,
    int? height,
    String? crop,
    String? gravity,
    int? quality,
    String? format,
    bool autoOptimize = true,
  });
}

class CloudinaryServiceImpl implements CloudinaryService {
  final _apiService = ApiService();
  final _tokenStorage = TokenStorage.instance;

  @override
  Future<Either<Failure, CloudinarySingleUploadResponse>> uploadSingleImage(
    File image, {
    required String uploadType,
    String? publicId,
    bool overwrite = true,
  }) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
        'uploadType': uploadType,
        if (publicId != null) 'publicId': publicId,
        'overwrite': overwrite,
      });

      final response = await _apiService.dio.post(
        '/api/Cloudinary/upload',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final uploadResponse = CloudinarySingleUploadResponse.fromJson(
        response.data,
      );
      return Right(uploadResponse);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to upload image: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CloudinaryDeleteResponse>> deleteImage(
    String publicId,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final response = await _apiService.dio.delete(
        '/api/Cloudinary/delete',
        queryParameters: {'publicId': publicId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final deleteResponse = CloudinaryDeleteResponse.fromJson(response.data);
      return Right(deleteResponse);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to delete image: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> getTransformedImageUrl(
    String publicId, {
    int? width,
    int? height,
    String? crop,
    String? gravity,
    int? quality,
    String? format,
    bool autoOptimize = true,
  }) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final transformOptions = {
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (crop != null) 'crop': crop,
        if (gravity != null) 'gravity': gravity,
        if (quality != null) 'quality': quality,
        if (format != null) 'format': format,
        'autoOptimize': autoOptimize,
      };

      final response = await _apiService.dio.post(
        '/api/Cloudinary/transform-url',
        queryParameters: {'publicId': publicId},
        data: transformOptions,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // API trả về object {"url": "..."}
      final url = response.data is Map
          ? response.data['url'] as String
          : response.data as String;
      return Right(url);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure('Failed to get transformed URL: ${e.toString()}'),
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
