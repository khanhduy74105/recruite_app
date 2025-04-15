import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../models/user_models.dart';

class SettingsState {
  final UserModel user;
  final bool isDarkMode;
  final bool isLoading;
  final String? error;

  SettingsState({
    required this.user,
    this.isDarkMode = false,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    UserModel? user,
    bool? isDarkMode,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      user: user ?? this.user,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  final supabase = Supabase.instance.client;

  SettingsCubit()
      : super(SettingsState(
          user: UserModel(
            id: const Uuid().v4(),
            resume: const Uuid().v4(),
            email: 'john.doe@example.com',
            createdAt: DateTime.now(),
            phone: '+1 555-123-4567',
            bio: 'Passionate developer with 5+ years in tech.',
            role: UserRole.user,
            headline: 'Building the future, one line at a time',
            location: 'San Francisco, CA',
            avatarUrl: 'https://via.placeholder.com/150',
            fullName: 'John Doe',
            experiences: [],
            educations: [],
            skills: [],
            posts: [],
            jobApplications: [],
          ),
          isDarkMode: false,
        ));

  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response =
            await supabase.from('user').select().eq('id', userId).single();
        final user = UserModel.fromJson(response);
        emit(state.copyWith(user: user, isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateField(String field, String value) async {
    emit(state.copyWith(isLoading: true));
    try {
      final updatedUser = state.user.copyWith(
        email: field == 'email' ? value : state.user.email,
        phone: field == 'phone' ? value : state.user.phone,
        bio: field == 'bio' ? value : state.user.bio,
        headline: field == 'headline' ? value : state.user.headline,
        location: field == 'location' ? value : state.user.location,
        avatarUrl: field == 'avatar_url' ? value : state.user.avatarUrl,
        fullName: field == 'full_name' ? value : state.user.fullName,
      );

      await supabase.from('user').update({
        field: value,
      }).eq('id', state.user.id);

      emit(state.copyWith(user: updatedUser, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateRole(UserRole role) async {
    emit(state.copyWith(isLoading: true));
    try {
      final updatedUser = state.user.copyWith(role: role);

      await supabase.from('user').update({
        'role': userRoleToString(role),
      }).eq('id', state.user.id);

      emit(state.copyWith(user: updatedUser, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> toggleNotifications(bool value) async {
    emit(state.copyWith(isLoading: true));
    try {
      await supabase.from('user').update({
        'notifications': value,
      }).eq('id', state.user.id);

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    emit(state.copyWith(isDarkMode: value));
  }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      emit(state.copyWith(
        user: UserModel(
          id: const Uuid().v4(),
          resume: const Uuid().v4(),
          email: '',
          fullName: '',
          experiences: [],
          educations: [],
          skills: [],
          posts: [],
          jobApplications: [],
        ),
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
