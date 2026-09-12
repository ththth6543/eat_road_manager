import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/juso_address.dart';

class VerificationRepository {
  final http.Client _httpClient;

  VerificationRepository({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Verify business registration with NTS Open API
  Future<bool> verifyBusinessRegistration({
    required String bNo,
    required String startDt,
    required String pName,
  }) async {
    final url =
        "${ApiConstants.ntsBusinessUrl}?serviceKey=${ApiConstants.ntsBusinessApiKey}";

    final response = await _httpClient.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "businesses": [
          {
            "b_no": bNo,
            "start_dt": startDt,
            "p_nm": pName,
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['data'] != null &&
          result['data'] is List &&
          result['data'].isNotEmpty) {
        return result['data'][0]['valid'] == '01';
      }
    }
    return false;
  }

  /// Verify restaurant business license with Food Safety Korea
  Future<List<dynamic>> verifyFoodSafetyLicense(String lcnsNo) async {
    final url =
        "${ApiConstants.foodSafetyBaseUrl}/${ApiConstants.foodSafetyApiKey}/I1200/json/1/20/LCNS_NO=$lcnsNo";

    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['I1200'] != null &&
          data['I1200']['total_count'] != '0' &&
          data['I1200']['row'] != null) {
        return data['I1200']['row'] as List<dynamic>;
      }
      return [];
    } else {
      throw Exception("서버 통신 오류가 발생했습니다. (코드: ${response.statusCode})");
    }
  }

  /// Search address (Attempts Naver Geocoding first, then Juso API)
  Future<List<JusoAddress>> searchAddress(String keyword) async {
    final cleanKeyword = keyword.trim();
    if (cleanKeyword.isEmpty) return [];

    // 1. 네이버 클라우드 지오코딩 API로 주소 검색 (좌표가 포함되어 반환됨)
    final naverResults = await searchAddressFromNaver(cleanKeyword);
    if (naverResults.isNotEmpty) {
      debugPrint('네이버 지오코딩 검색 성공: ${naverResults.length}건');
      return naverResults;
    }

    // 2. 만약 네이버 지오코딩에서 결과가 없으면 행정안전부 도로명주소 API 시도
    try {
      final url =
          '${ApiConstants.jusoApiUrl}?confmKey=${ApiConstants.jusoApiKey}&currentPage=1&countPerPage=50&keyword=${Uri.encodeComponent(cleanKeyword)}&resultType=json';

      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final common = data['results']?['common'];
        final errorCode = common?['errorCode']?.toString();

        if (errorCode == '0' &&
            data['results'] != null &&
            data['results']['juso'] != null) {
          final List<dynamic> jusoList = data['results']['juso'];
          return jusoList.map((j) => JusoAddress.fromJson(j)).toList();
        }
      }
    } catch (e) {
      debugPrint('행안부 도로명주소 API 호출 예외: $e');
    }

    return [];
  }

  /// Search address directly using Naver Cloud Maps Geocoding API
  /// Official documentation specs:
  /// GET https://maps.apigw.ntruss.com/map-geocode/v2/geocode?query={query}&count={count}
  /// Headers:
  ///   'Accept': 'application/json'
  ///   'x-ncp-apigw-api-key-id': {API Key ID}
  ///   'x-ncp-apigw-api-key': {API Key}
  Future<List<JusoAddress>> searchAddressFromNaver(String keyword) async {
    try {
      final url =
          '${ApiConstants.naverGeocodeBaseUrl}?query=${Uri.encodeComponent(keyword)}&count=20';

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'x-ncp-apigw-api-key-id': ApiConstants.naverMapClientId,
          'x-ncp-apigw-api-key': ApiConstants.naverGeocodeClientSecret,
        },
      );

      debugPrint('Naver Geocode 주소검색 응답 [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['addresses'] != null) {
          final List<dynamic> list = data['addresses'];
          return list.map((item) {
            String siNm = '';
            String sggNm = '';
            String emdNm = '';
            if (item['addressElements'] is List) {
              for (final el in item['addressElements']) {
                final types = (el['types'] as List?) ?? [];
                if (types.contains('SIDO')) siNm = el['longName']?.toString() ?? '';
                if (types.contains('SIGUGUN')) sggNm = el['longName']?.toString() ?? '';
                if (types.contains('DONGMYUN')) emdNm = el['longName']?.toString() ?? '';
              }
            }

            final roadAddr = item['roadAddress']?.toString() ?? '';
            final jibunAddr = item['jibunAddress']?.toString() ?? '';
            final lat = double.tryParse(item['y']?.toString() ?? '');
            final lng = double.tryParse(item['x']?.toString() ?? '');

            return JusoAddress(
              roadAddr: roadAddr.isNotEmpty ? roadAddr : jibunAddr,
              jibunAddr: jibunAddr.isNotEmpty ? jibunAddr : roadAddr,
              siNm: siNm,
              sggNm: sggNm,
              emdNm: emdNm,
              liNm: '',
              bdMgtSn: '',
              latitude: lat,
              longitude: lng,
            );
          }).where((a) => a.roadAddr.isNotEmpty).toList();
        }
      } else {
        debugPrint('Naver Geocode API 오류 [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      debugPrint('Naver Geocode 주소검색 예외: $e');
    }
    return [];
  }

  /// Geocode address to NLatLng using Naver Geocoding API
  /// Headers:
  ///   'Accept': 'application/json'
  ///   'x-ncp-apigw-api-key-id': {API Key ID}
  ///   'x-ncp-apigw-api-key': {API Key}
  Future<NLatLng?> geocodeAddress(String address) async {
    final cleanQuery = address.trim();
    if (cleanQuery.isEmpty) return null;

    debugPrint('Naver Geocode 좌표요청: $cleanQuery');
    final url =
        '${ApiConstants.naverGeocodeBaseUrl}?query=${Uri.encodeComponent(cleanQuery)}';

    try {
      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'x-ncp-apigw-api-key-id': ApiConstants.naverMapClientId,
          'x-ncp-apigw-api-key': ApiConstants.naverGeocodeClientSecret,
        },
      );

      debugPrint('Naver Geocode 응답 [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' &&
            data['addresses'] != null &&
            (data['addresses'] as List).isNotEmpty) {
          final addressInfo = data['addresses'][0];
          final double? lat = double.tryParse(addressInfo['y']?.toString() ?? '');
          final double? lng = double.tryParse(addressInfo['x']?.toString() ?? '');
          if (lat != null && lng != null) {
            return NLatLng(lat, lng);
          }
        }
      } else {
        debugPrint('Naver Geocode API 오류 [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      debugPrint('Naver Geocode 통신 예외: $e');
    }
    return null;
  }
}
