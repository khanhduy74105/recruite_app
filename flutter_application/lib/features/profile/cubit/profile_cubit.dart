import 'dart:io';

import 'package:bloc/bloc.dart' show Cubit;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application/models/education_model.dart';
import 'package:flutter_application/models/experience_model.dart';
import 'package:flutter_application/models/job_application_model.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:flutter_application/models/skill_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../models/user_connection.dart';
import '../../../models/user_models.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final _supabase = Supabase.instance.client;

  Future<void> fetchProfile(String userId, {String? viewerId}) async {
    try {
      emit(ProfileLoading());

      final response = await _supabase.from('user').select('''
  *,
  experience(*),
  education(*),
  post!post_creator_id_fkey(*,
    creator: user!post_creator_id_fkey(*),
    job: job!post_job_fkey(*)
  ),
  job_application(*)
''').eq('id', userId).single();

      final user = _mapResponseToUserModel(response);

      ConnectionStatus? connectionStatus;
      if (viewerId != null && viewerId != userId) {
        final connectionResponse = await _supabase
            .from('user_connection')
            .select()
            .or('and(user_id.eq.$viewerId,friend_id.eq.$userId),and(user_id.eq.$userId,friend_id.eq.$viewerId)')
            .maybeSingle();

        if (connectionResponse != null) {
          connectionStatus = ConnectionStatus.values.firstWhere(
            (e) => e.toString().split('.').last == connectionResponse['status'],
            orElse: () => ConnectionStatus.pending,
          );
        }
      }

      emit(ProfileLoaded(user, connectionStatus));
    } catch (e, s) {
      if (kDebugMode) {
        print('Error fetching profile: $e\n$s');
      }
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> createConnection(String userId, String friendId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        emit(const ProfileError('User not authenticated'));
        return;
      }

      final connection = UserConnection(
        id: const Uuid().v4(),
        userId: currentUserId,
        friendId: friendId,
        senderId: currentUserId,
        status: ConnectionStatus.pending,
      );

      await _supabase.from('user_connection').insert(connection.toJson());
      await fetchProfile(friendId, viewerId: currentUserId);
    } catch (e) {
      emit(ProfileError('Failed to create connection: $e'));
    }
  }

  Future<void> deleteConnection(String userId, String friendId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        emit(const ProfileError('User not authenticated'));
        return;
      }

      await _supabase.from('user_connection').delete().or(
          'and(user_id.eq.$currentUserId,friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.$currentUserId)');

      await fetchProfile(friendId, viewerId: currentUserId);
    } catch (e) {
      emit(ProfileError('Failed to delete connection: $e'));
    }
  }

  Future<void> updateAvatar(String userId, ImageSource source) async {
    try {
      emit(AvatarUpdating());
      print('Starting avatar update for user: $userId');

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      print('Picked file: $pickedFile');
      if (pickedFile == null) {
        emit(const ProfileError('No image selected'));
        return;
      }

      final session = _supabase.auth.currentSession;
      print('Session: $session');
      if (session == null) {
        emit(const ProfileError('User not authenticated'));
        return;
      }

      final file = File(pickedFile.path);
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('Uploading to avatars/$fileName');
      await _supabase.storage.from('avatars').upload(fileName, file);

      final avatarUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      print('Avatar URL: $avatarUrl');

      print('Updating database with URL: $avatarUrl');
      await _supabase
          .from('user')
          .update({'avatar_url': avatarUrl}).eq('id', userId);

      emit(AvatarUpdated(avatarUrl));
      print('Avatar updated successfully');
      await fetchProfile(userId);
    } catch (e) {
      print('Error in updateAvatar: $e');
      emit(ProfileError('Failed to update avatar: $e'));
    }
  }

  Future<void> updateExperiences(
      String userId, List<ExperienceModel> experiences) async {
    try {
      emit(const ProfileUpdating('Updating experiences...'));

      final expData =
          experiences.map((exp) => exp.toJson()..['user_id'] = userId).toList();

      await _supabase.from('experience').delete().eq('user_id', userId);
      if (expData.isNotEmpty) {
        await _supabase.from('experience').insert(expData);
      }

      await fetchProfile(userId);
    } catch (e) {
      emit(ProfileError('Failed to update experiences: $e'));
    }
  }

  Future<void> updateEducations(
      String userId, List<EducationModel> educations) async {
    try {
      emit(const ProfileUpdating('Updating educations...'));

      final eduData =
          educations.map((edu) => edu.toJson()..['user_id'] = userId).toList();

      await _supabase.from('education').delete().eq('user_id', userId);
      if (eduData.isNotEmpty) {
        await _supabase.from('education').insert(eduData);
      }

      await fetchProfile(userId);
    } catch (e) {
      emit(ProfileError('Failed to update educations: $e'));
    }
  }

  Future<void> updateBio(String userId, String bio) async {
    try {
      emit(const ProfileUpdating('Updating bio...'));

      await _supabase.from('user').update({'bio': bio}).eq('id', userId);

      await fetchProfile(userId);
    } catch (e) {
      emit(ProfileError('Failed to update bio: $e'));
    }
  }

  Future<void> updateHeadline(String userId, String headline) async {
    try {
      emit(const ProfileUpdating('Updating headline...'));

      await _supabase
          .from('user')
          .update({'headline': headline}).eq('id', userId);

      await fetchProfile(userId);
    } catch (e) {
      emit(ProfileError('Failed to update headline: $e'));
    }
  }

  Future<void> updateLocation(String userId, String location) async {
    try {
      emit(const ProfileUpdating('Updating location...'));

      await _supabase
          .from('user')
          .update({'location': location}).eq('id', userId);

      await fetchProfile(userId);
    } catch (e) {
      emit(ProfileError('Failed to update location: $e'));
    }
  }

  UserModel _mapResponseToUserModel(Map<String, dynamic> response) {
    return UserModel(
      id: response['id'],
      resume: response['resume'],
      email: response['email'],
      createdAt: response['created_at'] != null
          ? DateTime.parse(response['created_at'])
          : null,
      phone: response['phone'],
      bio: response['bio'],
      role: response['role'] != null
          ? userRoleFromString(response['role'])
          : null,
      headline: response['headline'],
      location: response['location'],
      avatarUrl: response['avatar_url'],
      fullName: response['full_name'] ?? 'Unknown',
      experiences: (response['experience'] as List<dynamic>? ?? [])
          .map((e) => ExperienceModel.fromJson(e))
          .toList(),
      educations: (response['education'] as List<dynamic>? ?? [])
          .map((e) => EducationModel.fromJson(e))
          .toList(),
      skills: (response['user_skill'] as List<dynamic>? ?? []).map((e) {
        return SkillModel.fromJson({
          'id': e['skill']['id'],
          'title': e['skill']['title'],
          'description': e['skill']['description'],
          'level': e['level'],
        });
      }).toList(),
      posts: (response['post'] as List<dynamic>? ?? [])
          .map((e) => PostModel.fromJson(e))
          .toList(),
      jobApplications: (response['job_application'] as List<dynamic>? ?? [])
          .map((e) => JobApplicationModel.fromJson(e))
          .toList(),
    );
  }

}
