import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application/models/education_model.dart';
import 'package:flutter_application/models/experience_model.dart';
import 'package:flutter_application/models/job_application_model.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:flutter_application/models/skill_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/user_models.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final _supabase = Supabase.instance.client;

  Future<void> fetchProfile(String userId) async {
    try {
      emit(ProfileLoading());

      final response = await _supabase.from('user').select('''
            *,
            experience(*),
            education(*),
            post!post_creator_id_fkey(*,
              job: job!post_job_fkey ( 
              *,
              user: creator(
                *
              )
            )
            ),
            job_application(*)
          ''').eq('id', userId).single();

      final user = _mapResponseToUserModel(response);
      emit(ProfileLoaded(user));
    } catch (e, s) {
      print('Error fetching profile: $e\n$s');
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> updateAvatar(String userId, ImageSource source) async {
    try {
      emit(AvatarUpdating());

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) {
        emit(AvatarUpdateError('No image selected'));
        return;
      }

      final session = _supabase.auth.currentSession;
      if (session == null) {
        emit(AvatarUpdateError('User not authenticated'));
        return;
      }

      final file = File(pickedFile.path);
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from('avatars').upload(fileName, file);

      final avatarUrl =
          _supabase.storage.from('avatars').getPublicUrl(fileName);

      await _supabase
          .from('user_info')
          .update({'avatar_url': avatarUrl}).eq('user_id', userId);

      emit(AvatarUpdated(avatarUrl));
      await fetchProfile(userId);
    } catch (e) {
      emit(AvatarUpdateError('Failed to update avatar: $e'));
    }
  }

  Future<void> updateExperiences(
      String userId, List<ExperienceModel> experiences) async {
    try {
      emit(ProfileUpdating('Updating experiences...'));

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
      emit(ProfileUpdating('Updating educations...'));

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
      emit(ProfileUpdating('Updating headline...'));

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
      emit(ProfileUpdating('Updating location...'));

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
