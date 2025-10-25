import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';
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

  ChatApiServiceImpl({ApiService? apiService, TokenStorage? tokenStorage})
      : _apiService = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorage.instance;

  @override
  Future<Either<Failure, List<ConversationDto>>> getMyConversations() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final response = await _apiService.get(
        '/api/conversations',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        final conversations = data
            .map((json) => ConversationDto.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(conversations);
      } else {
        return Left(
          ServerFailure('Failed to get conversations: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MessageDto>>> getConversationMessages(
    int conversationId, {
    int? beforeMessageId,
    int take = 50,
  }) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final queryParams = <String, dynamic>{
        'take': take,
      };
      if (beforeMessageId != null) {
        queryParams['beforeMessageId'] = beforeMessageId;
      }

      final response = await _apiService.get(
        '/api/conversations/$conversationId/messages',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

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
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> createOrGetConversationWithUser(
    int otherUserId,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final response = await _apiService.post(
        '/api/conversations/with-user/$otherUserId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final conversationId = response.data['conversationId'] as int;
        return Right(conversationId);
      } else {
        return Left(
          ServerFailure('Failed to create conversation: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MessageDto>> sendMessage(
    int conversationId,
    String content,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        return Left(AuthenticationFailure('No access token found'));
      }

      final response = await _apiService.post(
        '/api/conversations/$conversationId/messages',
        data: {'content': content},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final message = MessageDto.fromJson(response.data as Map<String, dynamic>);
        return Right(message);
      } else {
        return Left(
          ServerFailure('Failed to send message: ${response.statusCode}'),
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

