import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {}

class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(EditProfileInitial());

  Future<void> updateProfile({
    required String userId,
    String? bio,
    String? headline,
    String? location,
    String? avatarUrl,
  }) async {
    try {
      emit(EditProfileLoading());

      final supabase = Supabase.instance.client;

      // Update user table
      final userUpdates = {
        if (bio != null) 'bio': bio,
        if (headline != null) 'headline': headline,
        if (location != null) 'location': location,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      if (userUpdates.isNotEmpty) {
        await supabase.from('user').update(userUpdates).eq('id', userId);
      }

      emit(EditProfileSuccess());
    } catch (e) {
      emit(EditProfileError('Failed to update profile: $e'));
    }
  }
}