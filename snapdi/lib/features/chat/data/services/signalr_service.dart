import 'dart:async';
import 'package:signalr_core/signalr_core.dart';
import '../../../../core/constants/environment.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/conversation.dart';

class SignalRService {
  static SignalRService? _instance;
  HubConnection? _connection;
  final TokenStorage _tokenStorage = TokenStorage.instance;

  // Stream controllers for real-time events
  final _messageReceivedController = StreamController<MessageDto>.broadcast();
  final _messageReadController = StreamController<Map<String, dynamic>>.broadcast();

  // Singleton pattern
  factory SignalRService() {
    _instance ??= SignalRService._internal();
    return _instance!;
  }

  SignalRService._internal();

  // Getters for streams
  Stream<MessageDto> get onMessageReceived => _messageReceivedController.stream;
  Stream<Map<String, dynamic>> get onMessageRead => _messageReadController.stream;

  // Check if connected
  bool get isConnected => _connection?.state == HubConnectionState.connected;

  // Connect to SignalR hub
  Future<void> connect() async {
    if (_connection?.state == HubConnectionState.connected) {
      print('SignalR: Already connected');
      return;
    }

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      // Get base URL without trailing slash
      String baseUrl = Environment.apiBaseUrl;
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      final hubUrl = '$baseUrl/hubs/chat';
      print('SignalR: Connecting to $hubUrl');

      _connection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            HttpConnectionOptions(
              accessTokenFactory: () async => token,
              transport: HttpTransportType.webSockets,
              skipNegotiation: true,
              logging: (level, message) => print('SignalR: $message'),
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Set up event handlers
      _setupEventHandlers();

      // Start connection
      await _connection!.start();
      print('SignalR: Connected successfully');
    } catch (e) {
      print('SignalR: Error connecting: $e');
      rethrow;
    }
  }

  // Set up SignalR event handlers
  void _setupEventHandlers() {
    // Handle incoming messages
    _connection!.on('messageReceived', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          final message = MessageDto.fromJson(data);
          _messageReceivedController.add(message);
          print('SignalR: Message received - ${message.messageId}');
        } catch (e) {
          print('SignalR: Error parsing message: $e');
        }
      }
    });

    // Handle message read notifications
    _connection!.on('messageRead', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          _messageReadController.add(data);
          print('SignalR: Message read notification');
        } catch (e) {
          print('SignalR: Error parsing message read: $e');
        }
      }
    });

    // Handle reconnection
    _connection!.onreconnecting((error) {
      print('SignalR: Reconnecting... ${error?.toString() ?? ""}');
    });

    _connection!.onreconnected((connectionId) {
      print('SignalR: Reconnected with connectionId: $connectionId');
    });

    _connection!.onclose((error) {
      print('SignalR: Connection closed ${error?.toString() ?? ""}');
    });
  }

  // Join a conversation group
  Future<void> joinConversation(int conversationId) async {
    if (_connection?.state != HubConnectionState.connected) {
      throw Exception('SignalR connection is not established');
    }

    try {
      await _connection!.invoke('JoinConversation', args: [conversationId]);
      print('SignalR: Joined conversation $conversationId');
    } catch (e) {
      print('SignalR: Error joining conversation: $e');
      rethrow;
    }
  }

  // Leave a conversation group
  Future<void> leaveConversation(int conversationId) async {
    if (_connection?.state != HubConnectionState.connected) {
      print('SignalR: Cannot leave conversation - not connected');
      return;
    }

    try {
      await _connection!.invoke('LeaveConversation', args: [conversationId]);
      print('SignalR: Left conversation $conversationId');
    } catch (e) {
      print('SignalR: Error leaving conversation: $e');
    }
  }

  // Send message via SignalR (optional - can use REST API instead)
  Future<void> sendMessage(int conversationId, String content) async {
    if (_connection?.state != HubConnectionState.connected) {
      throw Exception('SignalR connection is not established');
    }

    try {
      await _connection!.invoke('SendMessage', args: [conversationId, content]);
      print('SignalR: Message sent to conversation $conversationId');
    } catch (e) {
      print('SignalR: Error sending message: $e');
      rethrow;
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(int conversationId, int messageId) async {
    if (_connection?.state != HubConnectionState.connected) {
      print('SignalR: Cannot mark as read - not connected');
      return;
    }

    try {
      await _connection!.invoke('MarkRead', args: [conversationId, messageId]);
      print('SignalR: Marked message $messageId as read');
    } catch (e) {
      print('SignalR: Error marking message as read: $e');
    }
  }

  // Disconnect from SignalR hub
  Future<void> disconnect() async {
    if (_connection?.state == HubConnectionState.connected) {
      try {
        await _connection!.stop();
        print('SignalR: Disconnected');
      } catch (e) {
        print('SignalR: Error disconnecting: $e');
      }
    }
  }

  // Dispose resources
  void dispose() {
    disconnect();
    _messageReceivedController.close();
    _messageReadController.close();
    _connection = null;
    _instance = null;
  }
}

