import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String _get(String key) => dotenv.env[key] ?? '';

  // Naver Map & Geocode
  static String get naverMapClientId => _get('NAVER_MAP_CLIENT_ID');
  static String get naverGeocodeClientSecret =>
      _get('NAVER_GEOCODE_CLIENT_SECRET');
  static String get naverGeocodeBaseUrl => _get('NAVER_GEOCODE_BASE_URL');

  // Supabase
  static String get supabaseUrl => _get('SUPABASE_URL');
  static String get supabaseAnonKey => _get('SUPABASE_ANON_KEY');

  // Public Gov Data - Business Validate
  static String get ntsBusinessApiKey => _get('NTS_BUSINESS_API_KEY');
  static String get ntsBusinessUrl => _get('NTS_BUSINESS_URL');

  // Food Safety Korea - Restaurant License Open API
  static String get foodSafetyApiKey => _get('FOOD_SAFETY_API_KEY');
  static String get foodSafetyBaseUrl => _get('FOOD_SAFETY_BASE_URL');

  // Juso Address Open API
  static String get jusoApiKey => _get('JUSO_API_KEY');
  static String get jusoApiUrl => _get('JUSO_API_URL');
}
