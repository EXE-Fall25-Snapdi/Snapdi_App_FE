import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/data/models/user.dart';
import '../../data/models/conversation.dart';
import '../../data/services/chat_api_service.dart';
import '../../data/services/signalr_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String? otherUserName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatApiServiceImpl _chatApiService = ChatApiServiceImpl();
  final SignalRService _signalRService = SignalRService();
  final TokenStorage _tokenStorage = TokenStorage.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  List<MessageDto> _messages = [];
  User? _currentUser;
  bool _isLoading = true;
  bool _isSending = false;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadCurrentUser();
    await _loadMessages();
    await _connectSignalR();
    _setupMessageListener();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userInfoJson = await _tokenStorage.getUserInfo();
      if (userInfoJson != null) {
        final userMap = jsonDecode(userInfoJson);
        setState(() {
          _currentUser = User.fromJson(userMap);
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _chatApiService.getConversationMessages(
      widget.conversationId,
      take: 50,
    );

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load messages: ${failure.message}')),
          );
        }
      },
      (messages) {
        setState(() {
          _messages = messages.reversed.toList(); // Reverse to show oldest first
          _isLoading = false;
        });
        _scrollToBottom();
      },
    );
  }

  Future<void> _connectSignalR() async {
    try {
      if (!_signalRService.isConnected) {
        await _signalRService.connect();
      }
      await _signalRService.joinConversation(widget.conversationId);
    } catch (e) {
      print('Error connecting to SignalR: $e');
      // Continue without SignalR - messages will still work via REST API
    }
  }

  void _setupMessageListener() {
    _messageSubscription = _signalRService.onMessageReceived.listen((message) {
      if (message.conversationId == widget.conversationId) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    _messageController.clear();

    final result = await _chatApiService.sendMessage(
      widget.conversationId,
      content,
    );

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message: ${failure.message}')),
          );
          _messageController.text = content; // Restore message on failure
        }
        setState(() {
          _isSending = false;
        });
      },
      (message) {
        // Message will be received via SignalR, no need to add manually
        // unless SignalR is not connected
        if (!_signalRService.isConnected) {
          setState(() {
            _messages.add(message);
          });
          _scrollToBottom();
        }
        setState(() {
          _isSending = false;
        });
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _signalRService.leaveConversation(widget.conversationId);
    _messageSubscription?.cancel();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName ?? 'Chat',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _signalRService.isConnected ? 'Online' : 'Offline',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet.\nSend a message to start the conversation.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == _currentUser?.userId;
                          return MessageBubble(
                            message: message,
                            isMe: isMe,
                          );
                        },
                      ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

