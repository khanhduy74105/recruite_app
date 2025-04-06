import 'package:flutter_application/models/user_connection.dart';
import 'package:flutter_application/models/user_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    try {
      AuthResponse authResponse = await supabase.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: 'io.supabase.flutterquickstart://signup-callback/');

      if (authResponse.user != null) {
        await supabase.from('user').insert(
          {
            'id': authResponse.user!.id,
            'email': email,
            'full_name': email.split('@')[0],
          },
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      AuthResponse authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        final response =
            await supabase.from('user').select().eq('email', email);
        print(response);
        if (response.isEmpty) {
          throw Exception('User not found');
        }
        return UserModel.fromJson(response[0]);
      } else {
        return null;
      }
    } catch (e, s) {
      print(s);
      throw e.toString();
    }
  }

  Future<List<UserModel>> getUsersNotFriend() async {
    try {
      String currentId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('user')
          .select('*')
          .neq('id', currentId)
          .not(
              'id',
              'in',
              await supabase
                  .from('user_connection')
                  .select('*')
                  .or('user_id.eq.$currentId,friend_id.eq.$currentId')
                  .or('status.eq.pending,status.eq.accepted')
                  .then((res) => res.map((x) {
                    if (x['friend_id'] == currentId) {
                      return x['user_id'];
                    } else {
                      return x['friend_id'];
                    }
                  }).toList()));
      return response.map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<UserModel>> getFriends() async {
    try {
      String currentId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('user')
          .select('*')
          .neq('id', currentId)
          .not(
              'id',
              'in',
              await supabase
                  .from('user_connection')
                  .select('*')
                  .or('user_id.eq.$currentId,friend_id.eq.$currentId')
                  .eq('status', 'accepted')
                  .then((res) => res.map((x) {
                    if (x['friend_id'] == currentId) {
                      return x['user_id'];
                    } else {
                      return x['friend_id'];
                    }
                  }).toList()));

      return response.map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }
}
