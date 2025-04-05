import 'dart:convert';
import 'dart:io';

import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/models/comment_model.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  final String modelName = 'post_comment';

  Future<CommentModel> createComment(CommentModel comment) async {
    try {
      final inserted = await supabase.from(modelName).insert({
        'post_id': comment.postId,
        'user_id': comment.creator.id,
        'content': comment.content,
        'parent_comment_id': comment.parentCommentId,
        'image_urls': jsonEncode(comment.imageUrls),
        'mention_user_id': comment.mentionUser?.id,
      }).select('''
      *,
        user:user_id(*),
        mention_user:mention_user_id(*)
      ''');

      if (inserted.isEmpty) {
        throw Exception('Failed to create comment');
      }
      CommentModel createdComment = CommentModel.fromJson(inserted[0]);

      return createdComment;
    } catch (e, s) {
      print('Error creating comment: $e\n$s');
      throw e.toString();
    }
  }

  Future<CommentModel> editComment(CommentModel comment) async {
    try {
      final updated = await supabase
          .from(modelName)
          .update({
            'content': comment.content,
            'image_urls': jsonEncode(comment.imageUrls),
            'mention_user_id': comment.mentionUser?.id,
            'likes': jsonEncode(comment.likes),
          })
          .eq('id', comment.id)
          .select('''
            *,
            user:user_id(*),
            mention_user:mention_user_id(*)
          ''');

      if (updated.isEmpty) {
        throw Exception('Failed to update comment');
      }
      CommentModel updatedComment = CommentModel.fromJson(updated[0]);

      return updatedComment;
    } catch (e, s) {
      print('Error updating comment: $e\n$s');
      throw e.toString();
    }
  }

  Future<List<CommentModel>> fetchComments(String postId) async {
    try {
      final response = await supabase
          .from(modelName)
          .select('''
            *,
            user:user_id(*),
            mention_user:mention_user_id(*),
            replies:post_comment!parent_comment_id(
              *,
              user:user_id(*),
              mention_user:mention_user_id(*)
            )
          ''')
          .eq('post_id', postId)
          .filter('parent_comment_id', 'is', 'null')
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      List<CommentModel> comments = (response as List<dynamic>)
          .map((comment) => CommentModel.fromJson(comment))
          .toList();

      return comments;
    } catch (e, s) {
      print('Error fetching comments: $e\n$s');
      throw e.toString();
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      await supabase.from(modelName).delete().eq('id', commentId);
      return true;
    } catch (e, s) {
      print('Error deleting comment: $e\n$s');
      throw e.toString();
    }
  }
}
