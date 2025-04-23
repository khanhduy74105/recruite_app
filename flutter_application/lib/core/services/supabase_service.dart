import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_application/core/constants/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static String bucketName = 'images';
  static init() async {
    await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseKey);
  }

  static SupabaseStorageClient get storage => Supabase.instance.client.storage;
  static Future<List<String>> upload(List<File> files, {String? bucket}) async {
    try {
      List<String> urls = [];
      for (File file in files) {
        String fileExtension = file.path.split('.').last;
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.hashCode}.$fileExtension';
        Uint8List fileBytes = await file.readAsBytes();
        await Supabase.instance.client.storage.from(bucket ?? bucketName).uploadBinary(
              fileName,
              fileBytes,
              fileOptions: FileOptions(contentType: 'image/$fileExtension'),
            );
        urls.add(fileName);
      }
      return urls;
    } catch (e, s) {
      print('Error uploading files: $e $s');
      return [];
    }
  }

  static void delete(String fileName) async {
    try {
      await Supabase.instance.client.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  static String getUrl(String fileName, {String? bucket}) {
    try {
      final String url = Supabase.instance.client.storage
          .from(bucket ?? bucketName)
          .getPublicUrl(fileName);
      return url;
    } catch (e) {
      return '';
    }
  }

  static String getCurrentUserId() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      return user.id;
    } else {
      throw Exception('User not logged in');
    }
  }
}
