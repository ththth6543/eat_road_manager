import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_client.dart';

class StorageService {
  /// Upload a file to specified bucket and return its public URL
  static Future<String> uploadFile({
    required String bucket,
    required String filePath,
    required File file,
  }) async {
    try {
      await supabase.storage.from(bucket).upload(filePath, file);
    } on StorageException catch (e) {
      // 409 means file already exists; we can still return the existing public URL
      if (e.statusCode == '409') {
        debugPrint('$filePath already exists in storage bucket $bucket.');
      } else {
        rethrow;
      }
    }
    return supabase.storage.from(bucket).getPublicUrl(filePath);
  }

  /// Remove a list of file paths from specified bucket
  static Future<void> removeFiles({
    required String bucket,
    required List<String> filePaths,
  }) async {
    if (filePaths.isEmpty) return;
    await supabase.storage.from(bucket).remove(filePaths);
  }

  /// Extract storage path from a Supabase public URL for a given bucket
  static String? extractFilePathFromUrl(String url, String bucket) {
    try {
      final uri = Uri.parse(url);
      final index = uri.pathSegments.indexOf(bucket);
      if (index != -1 && index + 1 < uri.pathSegments.length) {
        return uri.pathSegments.sublist(index + 1).join('/');
      }
    } catch (e) {
      debugPrint('Error extracting file path from URL $url: $e');
    }
    return null;
  }
}
