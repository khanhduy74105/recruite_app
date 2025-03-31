import 'dart:convert';
import 'dart:io';

import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  PostRepository._privateConstructor();
  static final PostRepository _instance = PostRepository._privateConstructor();
  factory PostRepository() {
    return _instance;
  }

  Future<bool> createPost({
    required String creatorId,
    required String content,
    required String visibility,
    required List<File> imageLinks,
    String? jobId,
  }) async {
    try {
      List<String> urls = await SupabaseService.upload(imageLinks);

      await supabase.from('post').insert({
        'job': jobId,
        'creator_id': creatorId,
        'content': content,
        'visibility': visibility,
        'image_links': jsonEncode(urls),
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> editPost(PostModel post) async {
    try {
      await supabase.from('post').update({
        'content': post.content,
        'visibility': post.visibility,
        'image_links': jsonEncode(post.imageLinks),
        'job': post.job?.id,
        'likes': jsonEncode(post.likes),
      }).eq('id', post.id);

      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      await supabase.from('post').delete().eq('id', postId);
      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await supabase
          .from('post')
          .select('''
            *,
            creator: user!post_creator_id_fkey (
              *
            ),
            job: job!post_job_fkey ( 
              *
            )
          ''')
          .order('created_at', ascending: false);
      List<PostModel> posts = (response as List)
          .map((post) => PostModel.fromJson(post))
          .toList();
      return posts;
    } catch (e) {
      throw e.toString();
    }
  }
}
