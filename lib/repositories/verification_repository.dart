import 'dart:convert';
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

  /// Search road address using Korean Juso Open API
  Future<List<JusoAddress>> searchAddress(String keyword) async {
    final url =
        '${ApiConstants.jusoApiUrl}?confmKey=${ApiConstants.jusoApiKey}&currentPage=1&countPerPage=100&keyword=${Uri.encodeComponent(keyword)}&resultType=json';

    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results']['juso'] != null) {
        final List<dynamic> jusoList = data['results']['juso'];
        return jusoList.map((j) => JusoAddress.fromJson(j)).toList();
      }
      return [];
    } else {
      throw Exception("주소 검색 서버 통신 실패 (코드: ${response.statusCode})");
    }
  }

  /// Geocode address to NLatLng using Naver Geocoding API
  Future<NLatLng?> geocodeAddress(String address) async {
    final url =
        '${ApiConstants.naverGeocodeBaseUrl}?query=${Uri.encodeComponent(address)}';

    final response = await _httpClient.get(
      Uri.parse(url),
      headers: {
        'x-ncp-apigw-api-key-id': ApiConstants.naverMapClientId,
        'x-ncp-apigw-api-key': ApiConstants.naverGeocodeClientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && (data['addresses'] as List).isNotEmpty) {
        final addressInfo = data['addresses'][0];
        final double lat = double.parse(addressInfo['y']);
        final double lng = double.parse(addressInfo['x']);
        return NLatLng(lat, lng);
      }
    }
    return null;
  }
}
