import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/conversation_model.dart';
import '../../../models/message_model.dart';
import '../../../models/user_models.dart';

class MessageRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<UserModel>> getUsers() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('user_connection')
        .select('friend_id, user!user_connection_friend_id_fkey(*)')
        .eq('user_id', currentUserId)
        .eq('status', 'accepted');

    final List<UserModel> users = response
        .map((json) => UserModel.fromJson(json['user']))
        .toList();

    return users;
  }

  // Lấy tin nhắn cho một người dùng cụ thể
  Future<List<MessageModel>> getMessagesForUser(String userId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('message')
        .select()
        .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('sent_at', ascending: true);

    return response.map((json) => MessageModel.fromJson(json)).toList();
  }

  // Lấy danh sách cuộc trò chuyện
  Future<List<ConversationModel>> getChats() async {
    final users = await getUsers();
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final List<ConversationModel> chats = [];
    for (final user in users) {
      final messages = await getMessagesForUser(user.id);
      final lastMessage = messages.isNotEmpty ? messages.last : null;
      final unreadCount = messages
          .where((m) => m.receiverId == currentUserId && !m.isRead)
          .length;

      chats.add(ConversationModel(
        userId: user.id,
        name: user.fullName,
        avatarUrl: user.avatarUrl,
        lastMessage: lastMessage?.content,
        lastMessageTime: lastMessage?.sentAt,
        hasUnreadMessages: unreadCount > 0,
        unreadMessagesCount: unreadCount,
      ));
    }

    return chats;
  }

  // Gửi tin nhắn mới
  Future<void> sendMessage(String receiverId, String content) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _supabase.from('message').insert({
      'sender_id': currentUserId,
      'receiver_id': receiverId,
      'content': content,
      'sent_at': DateTime.now().toIso8601String(),
    });
  }

  // Đánh dấu tin nhắn là đã đọc
  Future<void> markMessagesAsRead(String userId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _supabase
        .from('message')
        .update({'is_read': true})
        .eq('receiver_id', currentUserId)
        .eq('sender_id', userId)
        .eq('is_read', false);
  }
  // Trong MessageRepository
  void subscribeToMessages(String userId, Function(MessageModel) onNewMessage) {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    _supabase
        .from('message')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      for (var json in data) {
        final message = MessageModel.fromJson(json);
        if ((message.senderId == userId && message.receiverId == currentUserId) ||
            (message.senderId == currentUserId && message.receiverId == userId)) {
          onNewMessage(message);
        }
      }
    });
  }
}