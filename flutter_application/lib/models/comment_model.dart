import 'user_models.dart';

import 'dart:convert';

class CommentModel {
  final String id;
  final String postId;
  final UserModel creator;
  final String content;
  final String? parentCommentId;
  final List<String> imageUrls;
  final UserModel? mentionUser;
  final DateTime? createdAt;
  final int likes;

  CommentModel({
    required this.id,
    required this.postId,
    required this.creator,
    required this.content,
    this.parentCommentId,
    this.imageUrls = const [],
    this.mentionUser,
    required this.likes,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      creator: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      mentionUser: json['mention_user'] != null
          ? UserModel.fromJson(json['mention_user'] as Map<String, dynamic>)
          : null,
      content: json['content'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      imageUrls:
          (jsonDecode(json['image_urls']) as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['created_at'] as String),
      likes: json['likes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'content': content,
      'user': creator.toJson(),
      'user_id': creator.id,
      'parent_comment_id': parentCommentId,
      'image_urls': jsonEncode(imageUrls),
      'mention_user': mentionUser?.toJson(),
      'mention_user_id': mentionUser?.toJson()['id'],
      'created_at': createdAt?.toIso8601String(),
      'likes': likes,
    };
  }
}
