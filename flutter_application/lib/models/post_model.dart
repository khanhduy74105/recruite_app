import 'dart:convert';

import 'package:flutter_application/models/job_model.dart';
import 'package:flutter_application/models/user_models.dart';

class PostModel {
  final String id;
  final String creatorId;
  String content;
  List<String> imageLinks;
  final DateTime createdAt;
  List<String> likes;
  List<String> comments;
  String visibility; // e.g., "public", "connections", "private"
  JobModel? job; // Optional job reference
  UserModel? creator; // Optional user reference

  PostModel({
    required this.id,
    required this.creatorId,
    required this.content,
    required this.imageLinks,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.visibility,
    this.job,
    this.creator,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      creatorId: json['creator_id'],
      content: json['content'],
      imageLinks: List<String>.from(jsonDecode(json['image_links']) ?? []),
      createdAt: DateTime.parse(json['created_at']),
      likes: List<String>.from(jsonDecode(json['likes'] ?? '[]')),
      comments: List<String>.from(jsonDecode(json['comments'] ?? '[]')),
      visibility: json['visibility'],
      job: json['job'] != null
          ? JobModel.fromJson(Map<String, dynamic>.from(json['job'] as Map))
          : null,
      creator: json['creator'] != null
          ? UserModel.fromJson(Map<String, dynamic>.from(json['creator'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'content': content,
      'image_links': jsonEncode(imageLinks),
      'created_at': createdAt.toIso8601String(),
      'likes': jsonEncode(likes),
      'comments': jsonEncode(comments),
      'visibility': visibility,
    };
  }

  set setContent(String newContent) => content = newContent;
  set setImageLinks(List<String> newImageLinks) => imageLinks = newImageLinks;
  set setLikes(List<String> newLikes) => likes = newLikes;
  set setComments(List<String> newComments) => comments = newComments;
  set setVisibility(String newVisibility) => visibility = newVisibility;
  set setJob(JobModel? newJob) => job = newJob;
  set setCreator(UserModel? newCreator) => creator = newCreator;

  PostModel copyWith({
    String? id,
    String? creatorId,
    String? content,
    List<String>? imageLinks,
    DateTime? createdAt,
    List<String>? likes,
    List<String>? comments,
    String? visibility,
    JobModel? job,
    UserModel? creator,
  }) {
    return PostModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      content: content ?? this.content,
      imageLinks: imageLinks ?? this.imageLinks,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      visibility: visibility ?? this.visibility,
      job: job ?? this.job,
      creator: creator ?? this.creator,
    );
  }
}