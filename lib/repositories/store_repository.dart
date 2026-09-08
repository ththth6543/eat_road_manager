import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/network/supabase_client.dart';
import '../models/store.dart';
import '../models/store_info.dart';

class StoreRepository {
  final SupabaseClient _client;

  StoreRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Fetch nearby stores within radius using RPC nearby_stores
  Future<List<Store>> fetchNearbyStores({
    required double latitude,
    required double longitude,
    int radiusM = 5000,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final List<dynamic> result = await _client
          .rpc(
            'nearby_stores',
            params: {
              'lat': latitude,
              'long': longitude,
              'radius_m': radiusM,
            },
          )
          .timeout(timeout);

      if (result.isEmpty) return [];
      return result
          .map((data) => Store.fromMap(data as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('서버 응답이 너무 늦어 데이터를 불러오지 못했습니다.');
    } catch (e) {
      throw Exception('가게 정보를 불러오는 데 실패했습니다: $e');
    }
  }

  /// Get existing DRAFT store or create a new one for current user
  Future<String> getOrCreateDraftStore(String userId) async {
    final List<dynamic> drafts = await _client
        .from('stores')
        .select('id')
        .eq('owner_id', userId)
        .eq('status', 'DRAFT');

    if (drafts.isNotEmpty) {
      return drafts.first['id'].toString();
    } else {
      final newData = await _client
          .from('stores')
          .insert({'owner_id': userId, 'name': '임시 가게', 'status': 'DRAFT'})
          .select('id')
          .single();
      return newData['id'].toString();
    }
  }

  /// Fetch detailed store info by store ID
  Future<StoreInfo> getStoreInfo(dynamic storeId) async {
    final data = await _client
        .from('stores')
        .select()
        .eq('id', storeId)
        .single();
    return StoreInfo.fromMap(data);
  }

  /// Fetch basic store data (name, description, image_urls)
  Future<Map<String, dynamic>> getStoreOverview(dynamic storeId) async {
    final data = await _client
        .from('stores')
        .select('name, description, image_urls')
        .eq('id', storeId)
        .single();
    return data;
  }

  /// Update store overview (name, description, image_urls)
  Future<void> updateStoreOverview({
    required dynamic storeId,
    required String name,
    required String description,
    required List<String> imageUrls,
  }) async {
    await _client.from('stores').update({
      'name': name,
      'description': description,
      'image_urls': imageUrls,
    }).eq('id', storeId);
  }

  /// Update store location coordinates & road address
  Future<void> updateStoreLocation({
    required dynamic storeId,
    required double latitude,
    required double longitude,
    required String roadAddress,
    String? bdMgtSn,
    String? jibunAddr,
    String? siNm,
    String? sggNm,
    String? emdNm,
  }) async {
    final updateData = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'road_address': roadAddress,
      if (bdMgtSn != null) 'bdMgtSn': bdMgtSn,
      if (jibunAddr != null) 'jibun_address': jibunAddr,
      if (siNm != null) 'siNm': siNm,
      if (sggNm != null) 'sggNm': sggNm,
      if (emdNm != null) 'emdNm': emdNm,
    };

    await _client.from('stores').update(updateData).eq('id', storeId);
  }

  /// Update store operational details (business days, hours, amenities)
  Future<void> updateStoreOthers({
    required dynamic storeId,
    required Map<String, dynamic> data,
  }) async {
    await _client.from('stores').update(data).eq('id', storeId);
  }
}
