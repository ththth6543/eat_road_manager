import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../core/services/location_service.dart';
import '../models/juso_address.dart';
import '../repositories/store_repository.dart';
import '../repositories/verification_repository.dart';

enum MarkerCreationStep { initial, fineTuning, confirmed }

class CreateStoreMarkerViewModel extends ChangeNotifier {
  final String storeId;
  final StoreRepository _storeRepository;
  final VerificationRepository _verificationRepository;

  MarkerCreationStep _step = MarkerCreationStep.initial;
  bool _hasPermission = false;
  bool _isLoading = false;
  String _storeName = '';
  String? _errorMessage;

  JusoAddress? _selectedAddress;
  NLatLng? _initialCoordinates;
  NLatLng? _finalCoordinates;

  CreateStoreMarkerViewModel({
    required this.storeId,
    StoreRepository? storeRepository,
    VerificationRepository? verificationRepository,
  }) : _storeRepository = storeRepository ?? StoreRepository(),
       _verificationRepository =
           verificationRepository ?? VerificationRepository();

  MarkerCreationStep get step => _step;
  bool get hasPermission => _hasPermission;
  bool get isLoading => _isLoading;
  String get storeName => _storeName;
  String? get errorMessage => _errorMessage;
  JusoAddress? get selectedAddress => _selectedAddress;
  NLatLng? get initialCoordinates => _initialCoordinates;
  NLatLng? get finalCoordinates => _finalCoordinates;

  Future<void> initialize() async {
    await checkPermission();
    await fetchStoreName();
  }

  Future<void> checkPermission() async {
    _hasPermission = await LocationService.requestLocationPermission();
    notifyListeners();
  }

  Future<void> fetchStoreName() async {
    try {
      final overview = await _storeRepository.getStoreOverview(storeId);
      _storeName = overview['name'] ?? '';
      notifyListeners();
    } catch (e) {
      debugPrint('가게 이름 가져오기 실패: $e');
    }
  }

  /// Process address picked from address search view
  Future<bool> selectAddress(JusoAddress address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      NLatLng? coords;

      // 0. 검색 결과에 이미 정확한 좌표가 포함되어 있는 경우 즉시 사용
      if (address.latitude != null && address.longitude != null) {
        coords = NLatLng(address.latitude!, address.longitude!);
        debugPrint('주소 객체에 포함된 네이버 좌표 즉시 사용: $coords');
      }

      // 1. 원본 도로명 주소로 시도
      if (coords == null && address.roadAddr.isNotEmpty) {
        coords = await _verificationRepository.geocodeAddress(address.roadAddr);
      }

      // 2. 괄호 참고항목(동/건물명) 제거 후 시도 (예: "테헤란로 152 (역삼동)" -> "테헤란로 152")
      if (coords == null && address.roadAddr.contains('(')) {
        final cleanRoad = address.roadAddr
            .replaceAll(RegExp(r'\(.*?\)'), '')
            .trim();
        if (cleanRoad.isNotEmpty) {
          coords = await _verificationRepository.geocodeAddress(cleanRoad);
        }
      }

      // 3. 지번 주소로 시도
      if (coords == null && address.jibunAddr.isNotEmpty) {
        coords = await _verificationRepository.geocodeAddress(
          address.jibunAddr,
        );
      }

      // 4. 지번 주소 괄호 제거 후 시도
      if (coords == null && address.jibunAddr.contains('(')) {
        final cleanJibun = address.jibunAddr
            .replaceAll(RegExp(r'\(.*?\)'), '')
            .trim();
        if (cleanJibun.isNotEmpty) {
          coords = await _verificationRepository.geocodeAddress(cleanJibun);
        }
      }

      // 5. 시/도 + 시/군/구 + 읍/면/동 지역명으로 시도 (최소 위치 보장)
      if (coords == null) {
        final areaName = '${address.siNm} ${address.sggNm} ${address.emdNm}'
            .trim();
        if (areaName.isNotEmpty) {
          coords = await _verificationRepository.geocodeAddress(areaName);
        }
      }

      if (coords != null) {
        _selectedAddress = address;
        _initialCoordinates = coords;
        _finalCoordinates = coords;
        _step = MarkerCreationStep.fineTuning;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            '선택하신 주소의 지도 좌표를 찾을 수 없습니다.\n잠시 후 다시 시도하시거나 도로명/지번을 확인해 주세요.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '주소 변환 중 오류 발생: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void updateFineTuningCoordinates(NLatLng coords) {
    _finalCoordinates = coords;
    notifyListeners();
  }

  void confirmPosition() {
    _step = MarkerCreationStep.confirmed;
    notifyListeners();
  }

  void resetToSearch() {
    _step = MarkerCreationStep.initial;
    _selectedAddress = null;
    _initialCoordinates = null;
    _finalCoordinates = null;
    notifyListeners();
  }

  Future<bool> saveStoreLocation() async {
    if (_finalCoordinates == null || _selectedAddress == null) {
      _errorMessage = '위치 정보가 설정되지 않았습니다.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _storeRepository.updateStoreLocation(
        storeId: storeId,
        latitude: _finalCoordinates!.latitude,
        longitude: _finalCoordinates!.longitude,
        roadAddress: _selectedAddress!.roadAddr,
        bdMgtSn: _selectedAddress!.bdMgtSn,
        jibunAddr: _selectedAddress!.jibunAddr,
        siNm: _selectedAddress!.siNm,
        sggNm: _selectedAddress!.sggNm,
        emdNm: _selectedAddress!.emdNm,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '가게 위치 저장 실패: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
