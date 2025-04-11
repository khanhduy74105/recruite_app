import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/user_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application/models/experience_model.dart';
import 'package:flutter_application/models/education_model.dart';
import 'package:flutter_application/models/skill_model.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:flutter_application/models/job_application_model.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  Future<void> fetchProfile(String userId) async {
    try {
      emit(ProfileLoading());

      final supabase = Supabase.instance.client;

      // Fetch user data
      final userResponse = await supabase
          .from('user')
          .select()
          .eq('id', userId)
          .single();

      // Fetch experiences
      final experiencesResponse = await supabase
          .from('experience')
          .select()
          .eq('user_id', userId);

      // Fetch educations
      final educationsResponse = await supabase
          .from('education')
          .select()
          .eq('user_id', userId);

      // Fetch skills
      final skillsResponse = await supabase
          .from('user_skill')
          .select('skill(*), level')
          .eq('user_id', userId);

      // Fetch posts
      final postsResponse = await supabase
          .from('post')
          .select()
          .eq('creator_id', userId);

      // Fetch job applications
      final jobApplicationsResponse = await supabase
          .from('job_application')
          .select()
          .eq('user_id', userId);

      // Construct the UserModel
      final user = UserModel(
        id: userResponse['id'],
        resume: userResponse['resume'],
        email: userResponse['email'],
        createdAt: userResponse['created_at'] != null
            ? DateTime.parse(userResponse['created_at'])
            : null,
        phone: userResponse['phone'],
        bio: userResponse['bio'],
        role: userResponse['role'] != null
            ? userRoleFromString(userResponse['role'])
            : null,
        headline: userResponse['headline'],
        location: userResponse['location'],
        avatarUrl: userResponse['avatar_url'],
        fullName: 'Unknown', // Assuming username maps to fullName
        experiences: experiencesResponse
            .map((e) => ExperienceModel.fromJson(e))
            .toList(),
        educations: educationsResponse
            .map((e) => EducationModel.fromJson(e))
            .toList(),
        skills: skillsResponse.map((e) => SkillModel.fromJson({
          'id': e['skill']['id'],
          'title': e['skill']['title'],
          'description': e['skill']['description'],
          'level': e['level'],
        })).toList(),
        posts: postsResponse.map((e) => PostModel.fromJson(e)).toList(),
        jobApplications: jobApplicationsResponse
            .map((e) => JobApplicationModel.fromJson(e))
            .toList(),
      );

      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> updateAvatar(String userId, ImageSource source) async {
    try {
      emit(AvatarUpdating());

      // Pick image from gallery or camera
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) {
        emit(AvatarUpdateError('No image selected'));
        return;
      }

      final supabase = Supabase.instance.client;

      // Ensure user is authenticated
      final session = supabase.auth.currentSession;
      if (session == null) {
        emit(AvatarUpdateError('User not authenticated'));
        return;
      }

      // Upload image to Supabase Storage
      final file = File(pickedFile.path);
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage
          .from('avatars')
          .upload(fileName, file);

      // Get the public URL of the uploaded image
      final avatarUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      // Update user_info table with the new avatar URL
      await supabase
          .from('user_info')
          .update({'avatar_url': avatarUrl})
          .eq('user_id', userId);

      emit(AvatarUpdated(avatarUrl));

      // Refresh the profile to reflect the updated avatar
      await fetchProfile(userId);
    } catch (e) {
      emit(AvatarUpdateError('Failed to update avatar: $e'));
    }
  }

  Future<void> updateExperiences(String userId, List<ExperienceModel> experiences) async {
    try {
      emit(ProfileLoading());

      final supabase = Supabase.instance.client;

      // Map experiences to Supabase format
      final List<Map<String, dynamic>> expData = experiences.map((exp) => exp.toJson()).toList();

      // Clear existing experiences
      await supabase
          .from('experience') // Use 'experience' table as per fetchProfile
          .delete()
          .eq('user_id', userId);

      // Insert new experiences if any
      if (expData.isNotEmpty) {
        await supabase
            .from('experience')
            .insert(expData);
      }

      // Re-fetch profile to update state
      final userResponse = await supabase
          .from('user')
          .select('''
            *,
            experience (*),
            post (*),
            education (*),
            user_skill (skill(*), level),
            job_application (*)
          ''')
          .eq('id', userId)
          .single();

      final experiencesResponse = userResponse['experience'] ?? [];
      final postsResponse = userResponse['post'] ?? [];
      final educationsResponse = userResponse['education'] ?? [];
      final skillsResponse = userResponse['user_skill'] ?? [];
      final jobApplicationsResponse = userResponse['job_application'] ?? [];

      final user = UserModel(
        id: userResponse['id'],
        resume: userResponse['resume'],
        email: userResponse['email'],
        createdAt: userResponse['created_at'] != null
            ? DateTime.parse(userResponse['created_at'])
            : null,
        phone: userResponse['phone'],
        bio: userResponse['bio'],
        role: userResponse['role'] != null
            ? userRoleFromString(userResponse['role'])
            : null,
        headline: userResponse['headline'],
        location: userResponse['location'],
        avatarUrl: userResponse['avatar_url'],
        fullName: 'Unknown',
        experiences: experiencesResponse
            .map((e) => ExperienceModel.fromJson(e))
            .toList(),
        educations: educationsResponse
            .map((e) => EducationModel.fromJson(e))
            .toList(),
        skills: skillsResponse.map((e) => SkillModel.fromJson({
          'id': e['skill']['id'],
          'title': e['skill']['title'],
          'description': e['skill']['description'],
          'level': e['level'],
        })).toList(),
        posts: postsResponse.map((e) => PostModel.fromJson(e)).toList(),
        jobApplications: jobApplicationsResponse
            .map((e) => JobApplicationModel.fromJson(e))
            .toList(),
      );

      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError('Failed to update experiences: $e'));
    }
  }
}