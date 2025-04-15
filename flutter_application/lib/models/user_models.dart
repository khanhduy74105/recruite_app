import 'dart:convert';

import 'package:flutter_application/models/experience_model.dart';
import 'package:flutter_application/models/education_model.dart';
import 'package:flutter_application/models/skill_model.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:flutter_application/models/job_application_model.dart';

enum UserRole { admin, user, recruiter }

UserRole userRoleFromString(String role) {
  switch (role) {
    case 'admin':
      return UserRole.admin;
    case 'user':
      return UserRole.user;
    case 'recruiter':
      return UserRole.recruiter;
    default:
      throw Exception('Unknown user role: $role');
  }
}

String userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'admin';
    case UserRole.user:
      return 'user';
    case UserRole.recruiter:
      return 'recruiter';
  }
}

class UserModel {
  final String id;
  final String? resume;
  final String email;
  final DateTime? createdAt;
  final String? phone;
  final String? bio;
  final UserRole? role;
  final String? headline;
  final String? location;
  final String? avatarUrl;
  final String fullName;
  final List<ExperienceModel> experiences; // Added
  final List<EducationModel> educations; // Added
  final List<SkillModel> skills; // Added
  final List<PostModel> posts; // Added
  final List<JobApplicationModel> jobApplications; // Added

  UserModel({
    required this.id,
    this.resume,
    required this.email,
    this.createdAt,
    this.phone,
    this.bio,
    this.role,
    this.headline,
    this.location,
    this.avatarUrl,
    required this.fullName,
    required this.experiences,
    required this.educations,
    required this.skills,
    required this.posts,
    required this.jobApplications,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      resume: json['resume'],
      email: json['email'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      phone: json['phone'],
      bio: json['bio'],
      role: json['role'] != null ? userRoleFromString(json['role']) : null,
      headline: json['headline'],
      location: json['location'],
      avatarUrl: json['avatar_url'],
      fullName: json['full_name'],
      experiences: (json['experiences'] as List<dynamic>?)
          ?.map((e) => ExperienceModel.fromJson(e))
          .toList() ??
          [],
      educations: (json['educations'] as List<dynamic>?)
          ?.map((e) => EducationModel.fromJson(e))
          .toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => SkillModel.fromJson(e))
          .toList() ??
          [],
      posts: (json['posts'] as List<dynamic>?)
          ?.map((e) => PostModel.fromJson(e))
          .toList() ??
          [],
      jobApplications: (json['job_applications'] as List<dynamic>?)
          ?.map((e) => JobApplicationModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resume': resume,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
      'phone': phone,
      'bio': bio,
      'role': role != null ? userRoleToString(role!) : null,
      'headline': headline,
      'location': location,
      'avatar_url': avatarUrl,
      'full_name': fullName,
      'experiences': experiences.map((e) => e.toJson()).toList(),
      'educations': educations.map((e) => e.toJson()).toList(),
      'skills': skills.map((e) => e.toJson()).toList(),
      'posts': posts.map((e) => e.toJson()).toList(),
      'job_applications': jobApplications.map((e) => e.toJson()).toList(),
    };
  }

  // Optional: Add a copyWith method for immutability
  UserModel copyWith({
    String? id,
    String? resume,
    String? email,
    DateTime? createdAt,
    String? phone,
    String? bio,
    UserRole? role,
    String? headline,
    String? location,
    String? avatarUrl,
    String? fullName,
    List<ExperienceModel>? experiences,
    List<EducationModel>? educations,
    List<SkillModel>? skills,
    List<PostModel>? posts,
    List<JobApplicationModel>? jobApplications,
    int? connectionCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      resume: resume ?? this.resume,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      headline: headline ?? this.headline,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fullName: fullName ?? this.fullName,
      experiences: experiences ?? this.experiences,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      posts: posts ?? this.posts,
      jobApplications: jobApplications ?? this.jobApplications,
    );
  }
}