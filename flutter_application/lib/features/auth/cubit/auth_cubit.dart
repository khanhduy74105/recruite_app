import 'package:flutter_application/features/auth/repository/auth_repository.dart';
import 'package:flutter_application/models/user_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitial());
  final authRepository = AuthRepository();
  static AuthCubit get(context) => BlocProvider.of(context);
  void checkCurrentUser() async {
    final response = await Supabase.instance.client
        .from('user')
        .select()
        .eq('email', Supabase.instance.client.auth.currentUser!.email!);
    if (response.isNotEmpty) {
      UserModel? user = UserModel.fromJson(response[0]);
      emit(AuthLoggedIn(user));
    } else {
      emit(AuthInitial());
    }
  }

  void signUp({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      await authRepository.signUp(
        email: email,
        password: password,
      );

      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void login({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final userModel = await authRepository.login(
        email: email,
        password: password,
      );

      if (userModel == null) {
        throw Exception('User not found');
      }

      emit(AuthLoggedIn(userModel));
    } catch (e) {
      print('ctach error: $e');
      emit(AuthError(e.toString()));
    }
  }
}
