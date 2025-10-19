import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signalr_core/signalr_core.dart';

class ChatService {
  final String Function() getJwt;
  HubConnection? _connection;

  ChatService({required this.getJwt});

  Future<void> connect() async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final url = '$baseUrl/hubs/chat';
    _connection = HubConnectionBuilder()
        .withUrl(url, HttpConnectionOptions(
          accessTokenFactory: () async => getJwt(),
          transport: HttpTransportType.webSockets,
        ))
        .withAutomaticReconnect()
        .build();

    await _connection!.start();
  }

  Stream<Map<String, dynamic>> onMessageReceived() {
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _connection?.on('messageReceived', (args) {
      if (args != null && args.isNotEmpty && args.first is Map<String, dynamic>) {
        controller.add(args.first as Map<String, dynamic>);
      } else if (args != null && args.isNotEmpty) {
        controller.add(Map<String, dynamic>.from(args.first as dynamic));
      }
    });
    return controller.stream;
  }

  Stream<Map<String, dynamic>> onMessageRead() {
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _connection?.on('messageRead', (args) {
      if (args != null && args.isNotEmpty) {
        controller.add(Map<String, dynamic>.from(args.first as dynamic));
      }
    });
    return controller.stream;
  }

  Future<void> joinConversation(int conversationId) async {
    await _connection?.invoke('JoinConversation', args: [conversationId]);
  }

  Future<void> leaveConversation(int conversationId) async {
    await _connection?.invoke('LeaveConversation', args: [conversationId]);
  }

  Future<void> sendMessage(int conversationId, String content) async {
    await _connection?.invoke('SendMessage', args: [conversationId, content]);
  }

  Future<void> markRead(int conversationId, int messageId) async {
    await _connection?.invoke('MarkRead', args: [conversationId, messageId]);
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }
}


