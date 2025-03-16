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
        emailRedirectTo: 'io.supabase.flutterquickstart://signup-callback/'
      );

      if (authResponse.user != null) {
          await supabase.from('user').insert(
          {
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
        final response = await supabase.from('user').select().eq('email', email);
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
}