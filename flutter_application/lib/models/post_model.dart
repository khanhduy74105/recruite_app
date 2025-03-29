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

  // Factory method to create a PostModel from JSON
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
      job: json['job'] != null ? JobModel.fromJson(json['job']) : null,
      creator: json['creator'] != null ? UserModel.fromJson(json['creator']) : null,
    );
  }

  // Method to convert a PostModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'content': content,
      'image_links': imageLinks,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
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
}