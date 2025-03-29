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
  static Future<List<String>> upload(List<File> files) async {
    try {
      List<String> urls = [];
      for (File file in files) {
        String fileExtension = file.path.split('.').last;
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.hashCode}.$fileExtension';
        Uint8List fileBytes = await file.readAsBytes();
        await Supabase.instance.client.storage.from(bucketName).uploadBinary(
              fileName,
              fileBytes,
              fileOptions: FileOptions(contentType: 'image/$fileExtension'),
            );
        urls.add(fileName);
      }
      return urls;
    } catch (e) {
      print('Error uploading files: $e');
      return [];
    }
  }

  static String getUrl(String fileName) {
    try {
      final String url = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);
      return url;
    } catch (e) {
      return '';
    }
  }
}
