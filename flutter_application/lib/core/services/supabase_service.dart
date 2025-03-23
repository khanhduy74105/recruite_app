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
        String fileName = file.path.split('/').last;
        Uint8List fileBytes = await file.readAsBytes();
        await Supabase.instance.client.storage.from(bucketName).uploadBinary(
              fileName,
              fileBytes,
              fileOptions: const FileOptions(contentType: 'image/png'),
            );
        urls.add(fileName);
      }
      return urls;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
