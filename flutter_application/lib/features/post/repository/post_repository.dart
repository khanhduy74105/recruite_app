import 'dart:convert';
import 'dart:io';

import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<bool> createPost({
    required String creatorId,
    required String content,
    required String visibility,
    required List<File> imageLinks,
  }) async {
    try {
      List<String> urls = await SupabaseService.upload(imageLinks);

      final response = await supabase.from('post').insert({
        'creator_id': creatorId,
        'content': content,
        'visibility': visibility,
        'image_links': jsonEncode(urls),
        'created_at': DateTime.now().toIso8601String(),
      });

      return response.isNotEmpty;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw e.toString();
    }
  }
}
