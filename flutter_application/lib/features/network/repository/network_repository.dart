import 'package:flutter_application/models/user_connection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NetworkRepository {
  static NetworkRepository? _instance;

  NetworkRepository._internal();

  factory NetworkRepository() {
    _instance ??= NetworkRepository._internal();
    return _instance!;
  }

  final SupabaseClient supabase = Supabase.instance.client;

  final String tableName = 'user_connection';

  Future<UserConnection> createConnection(
      String userId, String friendId) async {
    try {
      final existingConnection = await supabase.from(tableName).select().or(
          'and(user_id.eq.$userId,friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.$userId)');

      if (existingConnection.isNotEmpty) {
        await supabase
            .from(tableName)
            .delete()
            .eq('id', existingConnection[0]['id']);
      }

      final response = await supabase
          .from(tableName)
          .insert({
            'user_id': userId,
            'friend_id': friendId,
            'sender_id': userId,
            'status': ConnectionStatus.pending.name,
          })
          .select()
          .single();
      return UserConnection.fromJson(response);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> updateConnection(
      UserConnection connection, ConnectionStatus status) async {
    try {
      await supabase.from(tableName).update({
        'status': status.name,
      }).eq('id', connection.id);
      return true;
    } catch (e) {
      print(e.toString());
      throw e.toString();
    }
  }

  Future<List<UserConnection>> fetchConnections(String userId) async {
    try {
      final response =
          await supabase.from(tableName).select().eq('user_id', userId);
      return (response as List).map((e) => UserConnection.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }
}
