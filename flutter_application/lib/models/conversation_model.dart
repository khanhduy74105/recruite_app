// File: lib/models/chat_model.dart
class ConversationModel {
  final String userId; // Unique identifier for the user/conversation
  final String name; // User's name
  final String? avatarUrl; // User's avatar
  final String? lastMessage; // Last message content
  final DateTime? lastMessageTime; // Time of last message
  final bool hasUnreadMessages; // Whether there are unread messages
  final int unreadMessagesCount; // Number of unread messages

  ConversationModel({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.hasUnreadMessages = false,
    this.unreadMessagesCount = 0,
  });

  // From JSON (for backend integration)
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      hasUnreadMessages: json['has_unread_messages'] as bool? ?? false,
      unreadMessagesCount: json['unread_messages_count'] as int? ?? 0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'avatar_url': avatarUrl,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'has_unread_messages': hasUnreadMessages,
      'unread_messages_count': unreadMessagesCount,
    };
  }
}