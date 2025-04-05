import 'user_models.dart';

import 'dart:convert';

class CommentModel {
  String id;
  String postId;
  UserModel creator;
  String content;
  String? parentCommentId;
  List<String> imageUrls;
  UserModel? mentionUser;
  DateTime? createdAt;
  List<String> likes;
  List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.postId,
    required this.creator,
    required this.content,
    this.parentCommentId,
    this.imageUrls = const [],
    this.mentionUser,
    this.likes = const [],
    this.replies = const [],
    this.createdAt,
  });

  // Setters
  set setId(String value) => id = value;
  set setPostId(String value) => postId = value;
  set setCreator(UserModel value) => creator = value;
  set setContent(String value) => content = value;
  set setParentCommentId(String? value) => parentCommentId = value;
  set setImageUrls(List<String> value) => imageUrls = value;
  set setMentionUser(UserModel? value) => mentionUser = value;
  set setCreatedAt(DateTime? value) => createdAt = value;
  set setLikes(List<String> value) => likes = value;
  set setReplies(List<CommentModel> value) => replies = value;

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
      likes: (jsonDecode(json['likes']) as List<dynamic>).cast<String>(),
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList()
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
      'likes': jsonEncode(likes),
      'replies': replies?.map((e) => e.toJson()).toList(),
    };
  }
}
