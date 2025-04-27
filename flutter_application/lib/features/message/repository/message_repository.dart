import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/conversation_model.dart';
import '../../../models/message_model.dart';
import '../../../models/user_models.dart';

class MessageRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ConversationModel>> getChats() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('message')
        .select()
        .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId');

    final messages = response.map((json) => MessageModel.fromJson(json)).toList();

    final Set<String> chatUserIds = {};
    for (final message in messages) {
      if (message.senderId == currentUserId) {
        chatUserIds.add(message.receiverId);
      } else if (message.receiverId == currentUserId) {
        chatUserIds.add(message.senderId);
      }
    }

    final Map<String, ConversationModel> conversationsMap = {};

    for (final userId in chatUserIds) {
      final userResponse = await _supabase
          .from('user')
          .select()
          .eq('id', userId)
          .single();

      final user = UserModel.fromJson(userResponse);

      final userMessages = messages.where((m) =>
      (m.senderId == currentUserId && m.receiverId == userId) ||
          (m.senderId == userId && m.receiverId == currentUserId)
      ).toList();

      userMessages.sort((a, b) => b.sentAt.compareTo(a.sentAt));

      final lastMessage = userMessages.isNotEmpty ? userMessages.first : null;
      final unreadCount = userMessages
          .where((m) => m.receiverId == currentUserId && !m.isRead)
          .length;

      conversationsMap[userId] = ConversationModel(
        userId: userId,
        name: user.fullName,
        avatarUrl: user.avatarUrl,
        lastMessage: lastMessage?.content,
        lastMessageTime: lastMessage?.sentAt,
        hasUnreadMessages: unreadCount > 0,
        unreadMessagesCount: unreadCount,
      );
    }

    return conversationsMap.values.toList();
  }

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
      'is_read': false,
    });
  }

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

  void subscribeToMessages(String userId, Function(MessageModel) onMessageUpdate) {
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
          onMessageUpdate(message);
        }
      }
    });
  }
}