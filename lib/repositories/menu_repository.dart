import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/network/supabase_client.dart';
import '../core/services/storage_service.dart';
import '../models/menu_item.dart';

class MenuRepository {
  final SupabaseClient _client;

  MenuRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Fetch all menu items for a specific store
  Future<List<MenuItem>> fetchMenusByStoreId(dynamic storeId) async {
    final List<dynamic> data = await _client
        .from('menus')
        .select('*')
        .eq('store_id', storeId);

    return data
        .map((item) => MenuItem.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Upload menu image and return public URL
  Future<String> uploadMenuImage({
    required String userId,
    required String storeId,
    required File file,
    required String fileName,
  }) async {
    final filePath = 'menu_images/$userId/$storeId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    return await StorageService.uploadFile(
      bucket: 'menus',
      filePath: filePath,
      file: file,
    );
  }

  /// Delete menu images from storage
  Future<void> deleteMenuImages(List<String> imageUrls) async {
    final List<String> filePaths = [];
    for (final url in imageUrls) {
      final path = StorageService.extractFilePathFromUrl(url, 'menus');
      if (path != null) filePaths.add(path);
    }
    if (filePaths.isNotEmpty) {
      try {
        await StorageService.removeFiles(bucket: 'menus', filePaths: filePaths);
      } catch (e) {
        debugPrint('Failed to batch delete menu images: $e. Retrying one-by-one.');
        for (final p in filePaths) {
          try {
            await StorageService.removeFiles(bucket: 'menus', filePaths: [p]);
          } catch (_) {}
        }
      }
    }
  }

  /// Delete menus by IDs
  Future<void> deleteMenus(List<String> ids) async {
    if (ids.isEmpty) return;
    await _client.from('menus').delete().inFilter('id', ids);
  }

  /// Insert new menu records
  Future<void> insertMenus(List<Map<String, dynamic>> records) async {
    if (records.isEmpty) return;
    await _client.from('menus').insert(records);
  }

  /// Upsert/update existing menu records
  Future<void> upsertMenus(List<Map<String, dynamic>> records) async {
    if (records.isEmpty) return;
    await _client.from('menus').upsert(records);
  }
}
