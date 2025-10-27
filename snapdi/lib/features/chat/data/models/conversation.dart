class ConversationDto {
  final int conversationId;
  final String type;
  final DateTime createAt;
  final int? lastReadMessageId;
  final int unreadCount;
  final String? lastMessageContent;
  final DateTime? lastMessageTime;
  final List<ConversationParticipantDto> participants;

  ConversationDto({
    required this.conversationId,
    required this.type,
    required this.createAt,
    this.lastReadMessageId,
    required this.unreadCount,
    this.lastMessageContent,
    this.lastMessageTime,
    required this.participants,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    return ConversationDto(
      conversationId: json['conversationId'] as int,
      type: json['type'] as String? ?? '',
      createAt: DateTime.parse(json['createAt'] as String),
      lastReadMessageId: json['lastReadMessageId'] as int?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      lastMessageContent: json['lastMessageContent'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => ConversationParticipantDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'type': type,
      'createAt': createAt.toIso8601String(),
      'lastReadMessageId': lastReadMessageId,
      'unreadCount': unreadCount,
      'lastMessageContent': lastMessageContent,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'participants': participants.map((e) => e.toJson()).toList(),
    };
  }
}

class ConversationParticipantDto {
  final int userId;
  final String username;
  final String? avatar;
  final DateTime joinedAt;

  ConversationParticipantDto({
    required this.userId,
    required this.username,
    this.avatar,
    required this.joinedAt,
  });

  factory ConversationParticipantDto.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantDto(
      userId: json['userId'] as int,
      username: json['username'] as String? ?? '',
      avatar: json['avatar'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}

class MessageDto {
  final int messageId;
  final int conversationId;
  final int senderId;
  final String? content;
  final DateTime sendAt;

  MessageDto({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    this.content,
    required this.sendAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      messageId: json['messageId'] as int,
      conversationId: json['conversationId'] as int,
      senderId: json['senderId'] as int,
      content: json['content'] as String?,
      sendAt: DateTime.parse(json['sendAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'sendAt': sendAt.toIso8601String(),
    };
  }
}

