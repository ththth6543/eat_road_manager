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
  })  : _storeRepository = storeRepository ?? StoreRepository(),
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
      final coords =
          await _verificationRepository.geocodeAddress(address.roadAddr);
      if (coords != null) {
        _selectedAddress = address;
        _initialCoordinates = coords;
        _finalCoordinates = coords;
        _step = MarkerCreationStep.fineTuning;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = '입력하신 주소의 좌표를 찾을 수 없습니다.';
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
