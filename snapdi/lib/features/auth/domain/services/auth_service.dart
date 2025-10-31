import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/models/login_request.dart';
import '../../data/models/login_response.dart';
import '../../data/models/sign_up_request.dart';
import '../../data/models/sign_up_response.dart';
import '../../data/models/photographer_sign_up_request.dart';
import '../../data/models/photographer_sign_up_response.dart';
import '../../data/models/send_verification_code_request.dart';
import '../../data/models/verify_email_code_request.dart';
import '../../data/models/verification_response.dart';
import '../../data/models/photo_type.dart';
import '../../data/models/style.dart';

abstract class AuthService {
  Future<Either<Failure, LoginResponse>> login({
    required String emailOrPhone,
    required String password,
  });

  Future<Either<Failure, SignUpResponse>> register({
    required SignUpRequest signUpRequest,
  });

  Future<Either<Failure, PhotographerSignUpResponse>> registerPhotographer({
    required PhotographerSignUpRequest photographerSignUpRequest,
  });

  // Email Verification
  Future<Either<Failure, VerificationResponse>> sendVerificationCode({
    required String email,
  });

  Future<Either<Failure, VerificationResponse>> verifyEmailCode({
    required String email,
    required String code,
  });

  Future<Either<Failure, VerificationResponse>> resendVerificationCode({
    required String email,
  });

  // Password Reset
  Future<Either<Failure, VerificationResponse>> forgotPassword({
    required String email,
  });

  Future<Either<Failure, VerificationResponse>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  });

  // Session Management
  Future<bool> storeAuthTokens(LoginResponse loginResponse);
  Future<bool> storeAuthTokensFromSignUp(SignUpResponse signUpResponse);
  Future<bool> storeAuthTokensFromPhotographerSignUp(
    PhotographerSignUpResponse photographerSignUpResponse,
  );
  Future<bool> isLoggedIn();
  Future<String?> getAccessToken();
  Future<Either<Failure, LoginResponse>> refreshToken();
  Future<bool> logout();
  Future<AuthTokens?> getCurrentSession();

  // Photo Types and Styles
  Future<Either<Failure, List<PhotoType>>> getPhotoTypes();
  Future<Either<Failure, List<Style>>> getStyles();

  // User Profile
  Future<Either<Failure, void>> updateAvatar({
    required int userId,
    required String avatarUrl,
  });
}

class AuthServiceImpl implements AuthService {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  AuthServiceImpl({ApiService? apiService, TokenStorage? tokenStorage})
    : _apiService = apiService ?? ApiService(),
      _tokenStorage = tokenStorage ?? TokenStorage.instance;

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
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final loginResponse = LoginResponse.fromJson(response.data);
        return Right(loginResponse);
      } else {
        return Left(
          ServerFailure('Login failed with status: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure('Unexpected error during login: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, SignUpResponse>> register({
    required SignUpRequest signUpRequest,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/auth/register',
        data: signUpRequest.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          final signUpResponse = SignUpResponse.fromJson(response.data);
          return Right(signUpResponse);
        } else {
          return Left(
            ServerFailure(
              'Registration successful but no response data received',
            ),
          );
        }
      } else {
        return Left(
          ServerFailure(
            'Registration failed with status: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure('Unexpected error during registration: ${e.toString()}'),
      );
    }
  }

  @override
  Future<bool> storeAuthTokens(LoginResponse loginResponse) async {
    try {
      final userJson = jsonEncode(loginResponse.user.toJson());

      return await _tokenStorage.storeTokens(
        accessToken: loginResponse.token,
        refreshToken: loginResponse.refreshToken,
        userId: loginResponse.user.userId,
        userInfo: userJson,
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> storeAuthTokensFromSignUp(SignUpResponse signUpResponse) async {
    try {
      if (signUpResponse.accessToken != null &&
          signUpResponse.refreshToken != null) {
        return await _tokenStorage.storeTokens(
          accessToken: signUpResponse.accessToken!,
          refreshToken: signUpResponse.refreshToken!,
          userId: signUpResponse.user.userId,
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await _tokenStorage.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _tokenStorage.getAccessToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, LoginResponse>> refreshToken() async {
    try {
      final currentRefreshToken = await _tokenStorage.getRefreshToken();
      if (currentRefreshToken == null) {
        return const Left(ServerFailure('No refresh token available'));
      }

      final response = await _apiService.post(
        '/api/Auth/refresh-token',
        data: {'refreshToken': currentRefreshToken},
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      await storeAuthTokens(loginResponse);

      return Right(loginResponse);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> logout() async {
    try {
      return await _tokenStorage.clearTokens();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthTokens?> getCurrentSession() async {
    try {
      return await _tokenStorage.getAllTokens();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, PhotographerSignUpResponse>> registerPhotographer({
    required PhotographerSignUpRequest photographerSignUpRequest,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/auth/register-photographer',
        data: photographerSignUpRequest.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null) {
          final photographerSignUpResponse =
              PhotographerSignUpResponse.fromJson(response.data);
          return Right(photographerSignUpResponse);
        } else {
          return Left(
            ServerFailure(
              'Photographer registration successful but no response data received',
            ),
          );
        }
      } else {
        return Left(
          ServerFailure(
            'Photographer registration failed with status: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure(
          'Unexpected error during photographer registration: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<bool> storeAuthTokensFromPhotographerSignUp(
    PhotographerSignUpResponse photographerSignUpResponse,
  ) async {
    try {
      if (photographerSignUpResponse.accessToken != null &&
          photographerSignUpResponse.refreshToken != null) {
        return await _tokenStorage.storeTokens(
          accessToken: photographerSignUpResponse.accessToken!,
          refreshToken: photographerSignUpResponse.refreshToken!,
          userId: photographerSignUpResponse.user.userId,
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, VerificationResponse>> sendVerificationCode({
    required String email,
  }) async {
    try {
      final request = SendVerificationCodeRequest(email: email);
      final response = await _apiService.post(
        '/api/auth/send-verification-code',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        if (response.data != null) {
          final verificationResponse = VerificationResponse.fromJson(
            response.data,
          );
          return Right(verificationResponse);
        } else {
          return Left(
            ServerFailure(
              'Verification code sent but no response data received',
            ),
          );
        }
      } else {
        return Left(
          ServerFailure(
            'Failed to send verification code with status: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure(
          'Unexpected error while sending verification code: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, VerificationResponse>> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final request = VerifyEmailCodeRequest(email: email, code: code);
      final response = await _apiService.post(
        '/api/auth/verify-email-code',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        if (response.data != null) {
          final verificationResponse = VerificationResponse.fromJson(
            response.data,
          );
          return Right(verificationResponse);
        } else {
          return Left(
            ServerFailure(
              'Email verification successful but no response data received',
            ),
          );
        }
      } else {
        return Left(
          ServerFailure(
            'Email verification failed with status: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure(
          'Unexpected error during email verification: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, VerificationResponse>> resendVerificationCode({
    required String email,
  }) async {
    try {
      final request = SendVerificationCodeRequest(email: email);
      final response = await _apiService.post(
        '/api/auth/resend-verification-code',
        data: request.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        if (response.data != null) {
          final verificationResponse = VerificationResponse.fromJson(
            response.data,
          );
          return Right(verificationResponse);
        } else {
          return Left(
            ServerFailure(
              'Verification code resent but no response data received',
            ),
          );
        }
      } else {
        return Left(
          ServerFailure(
            'Failed to resend verification code with status: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure(
          'Unexpected error while resending verification code: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, VerificationResponse>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/Auth/forgot-password',
        data: {'email': email},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        if (response.data != null) {
          final verificationResponse = VerificationResponse.fromJson(
            response.data,
          );
          return Right(verificationResponse);
        } else {
          return Left(
            ServerFailure('No data received from forgot password request'),
          );
        }
      } else {
        return Left(
          ServerFailure(
            'Failed to send password reset code with status: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure(
          'Unexpected error during forgot password: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, VerificationResponse>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/Auth/reset-password',
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        if (response.data != null) {
          final verificationResponse = VerificationResponse.fromJson(
            response.data,
          );
          return Right(verificationResponse);
        } else {
          return Left(
            ServerFailure('No data received from password reset'),
          );
        }
      } else {
        return Left(
          ServerFailure(
            'Failed to reset password with status: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure(
          'Unexpected error during password reset: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PhotoType>>> getPhotoTypes() async {
    try {
      final response = await _apiService.get('/api/PhotoTypes');

      final List<dynamic> data = response.data;
      final photoTypes = data
          .map((item) => PhotoType.fromJson(item as Map<String, dynamic>))
          .toList();

      return Right(photoTypes);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure('Unexpected error loading photo types: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Style>>> getStyles() async {
    try {
      final response = await _apiService.get('/api/Styles');

      final List<dynamic> data = response.data;
      final styles = data
          .map((item) => Style.fromJson(item as Map<String, dynamic>))
          .toList();

      return Right(styles);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure('Unexpected error loading styles: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateAvatar({
    required int userId,
    required String avatarUrl,
  }) async {
    try {
      // Get the access token
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return Left(AuthenticationFailure('No access token available'));
      }

      final response = await _apiService.put(
        '/api/Users/$userId/avatar',
        data: jsonEncode(avatarUrl),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            'Failed to update avatar with status: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure('Unexpected error updating avatar: ${e.toString()}'),
      );
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

        String errorMessage = 'Server error occurred';
        final responseData = error.response?.data;

        if (responseData is Map<String, dynamic>) {
          errorMessage =
              responseData['message']?.toString() ??
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
            'Connection timeout. Please check if the server is running or try again later.',
          );
        }
        return NetworkFailure(
          'No internet connection. Please check your network settings.',
        );

      case DioExceptionType.badCertificate:
        return NetworkFailure('SSL certificate error');

      case DioExceptionType.unknown:
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
