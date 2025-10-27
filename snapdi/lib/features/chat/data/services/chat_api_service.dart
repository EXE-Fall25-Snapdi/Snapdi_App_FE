import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../models/conversation.dart';

abstract class ChatApiService {
  Future<Either<Failure, List<ConversationDto>>> getMyConversations();
  Future<Either<Failure, List<MessageDto>>> getConversationMessages(
    int conversationId, {
    int? beforeMessageId,
    int take = 50,
  });
  Future<Either<Failure, int>> createOrGetConversationWithUser(int otherUserId);
  Future<Either<Failure, MessageDto>> sendMessage(
    int conversationId,
    String content,
  );
}

class ChatApiServiceImpl implements ChatApiService {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;
  final AuthService _authService;

  ChatApiServiceImpl({
    ApiService? apiService,
    TokenStorage? tokenStorage,
    AuthService? authService,
  }) : _apiService = apiService ?? ApiService(),
       _tokenStorage = tokenStorage ?? TokenStorage.instance,
       _authService = authService ?? AuthServiceImpl();

  /// Get valid token with automatic refresh if expired
  Future<String?> _getValidToken() async {
    String? token = await _tokenStorage.getAccessToken();
    if (token == null) {
      return null;
    }
    return token;
  }

  /// Make authenticated request with automatic token refresh on 401
  Future<Either<Failure, Response>> _makeAuthenticatedRequest({
    required Future<Response> Function(String token) request,
  }) async {
    String? token = await _getValidToken();

    if (token == null) {
      return Left(AuthenticationFailure('No access token found'));
    }

    try {
      // First attempt
      Response response = await request(token);
      return Right(response);
    } on DioException catch (e) {
      // If 401, try to refresh token and retry
      if (e.response?.statusCode == 401) {
        print('Token expired (401), attempting refresh...');

        final refreshResult = await _authService.refreshToken();

        return refreshResult.fold(
          (failure) {
            // Refresh failed, return authentication error
            print('Token refresh failed: ${failure.message}');
            return Left(
              AuthenticationFailure('Session expired. Please login again.'),
            );
          },
          (loginResponse) async {
            // Refresh succeeded, retry with new token
            print('Token refreshed successfully, retrying request...');
            try {
              final retryResponse = await request(loginResponse.token);
              return Right(retryResponse);
            } on DioException catch (retryError) {
              return Left(_handleDioError(retryError));
            }
          },
        );
      }

      // Not a 401 error, handle normally
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ConversationDto>>> getMyConversations() async {
    final result = await _makeAuthenticatedRequest(
      request: (token) async {
        return await _apiService.get(
          '/api/conversations',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );
      },
    );

    return result.fold((failure) => Left(failure), (response) {
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        final conversations = data
            .map(
              (json) => ConversationDto.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        return Right(conversations);
      } else {
        return Left(
          ServerFailure('Failed to get conversations: ${response.statusCode}'),
        );
      }
    });
  }

  @override
  Future<Either<Failure, List<MessageDto>>> getConversationMessages(
    int conversationId, {
    int? beforeMessageId,
    int take = 50,
  }) async {
    final queryParams = <String, dynamic>{'take': take};
    if (beforeMessageId != null) {
      queryParams['beforeMessageId'] = beforeMessageId;
    }

    final result = await _makeAuthenticatedRequest(
      request: (token) async {
        return await _apiService.get(
          '/api/conversations/$conversationId/messages',
          queryParameters: queryParams,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );
      },
    );

    return result.fold((failure) => Left(failure), (response) {
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        final messages = data
            .map((json) => MessageDto.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(messages);
      } else {
        return Left(
          ServerFailure('Failed to get messages: ${response.statusCode}'),
        );
      }
    });
  }

  @override
  Future<Either<Failure, int>> createOrGetConversationWithUser(
    int otherUserId,
  ) async {
    final result = await _makeAuthenticatedRequest(
      request: (token) async {
        return await _apiService.post(
          '/api/conversations/with-user/$otherUserId',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );
      },
    );

    return result.fold((failure) => Left(failure), (response) {
      if (response.statusCode == 200 && response.data != null) {
        final conversationId = response.data['conversationId'] as int;
        return Right(conversationId);
      } else {
        return Left(
          ServerFailure(
            'Failed to create conversation: ${response.statusCode}',
          ),
        );
      }
    });
  }

  @override
  Future<Either<Failure, MessageDto>> sendMessage(
    int conversationId,
    String content,
  ) async {
    final result = await _makeAuthenticatedRequest(
      request: (token) async {
        return await _apiService.post(
          '/api/conversations/$conversationId/messages',
          data: {'content': content},
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );
      },
    );

    return result.fold((failure) => Left(failure), (response) {
      if (response.statusCode == 200 && response.data != null) {
        final message = MessageDto.fromJson(
          response.data as Map<String, dynamic>,
        );
        return Right(message);
      } else {
        return Left(
          ServerFailure('Failed to send message: ${response.statusCode}'),
        );
      }
    });
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
      case DioExceptionType.connectionError:
        return NetworkFailure('Network connection error');
      case DioExceptionType.badCertificate:
        return NetworkFailure('SSL certificate error');
      case DioExceptionType.unknown:
        return NetworkFailure('Network error occurred');
    }
  }
}
