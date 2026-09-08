import 'package:flutter/material.dart';
import '../repositories/store_repository.dart';

class CreateStoreOthersViewModel extends ChangeNotifier {
  final String storeId;
  final StoreRepository _storeRepository;

  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  final List<bool> selectedDays = [false, false, false, false, false, false, false];

  bool isLastOrderAvailable = false;
  bool isReservationAvailable = false;
  bool isParkingAvailable = false;
  bool isTakeoutAvailable = false;
  bool isWifiAvailable = false;

  bool _isUploading = false;
  String? _errorMessage;

  CreateStoreOthersViewModel({
    required this.storeId,
    StoreRepository? storeRepository,
  }) : _storeRepository = storeRepository ?? StoreRepository();

  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  void toggleDay(int index) {
    if (index >= 0 && index < selectedDays.length) {
      selectedDays[index] = !selectedDays[index];
      notifyListeners();
    }
  }

  void setReservation(bool value) {
    isReservationAvailable = value;
    notifyListeners();
  }

  void setParking(bool value) {
    isParkingAvailable = value;
    notifyListeners();
  }

  void setTakeout(bool value) {
    isTakeoutAvailable = value;
    notifyListeners();
  }

  void setWifi(bool value) {
    isWifiAvailable = value;
    notifyListeners();
  }

  void setLastOrder(bool value) {
    isLastOrderAvailable = value;
    notifyListeners();
  }

  Future<bool> saveStoreOthers({
    required String openTime,
    required String closeTime,
    String? lastOrderTime,
    required String storePhoneNumber,
    required String snsUrl,
    required String parkingInfo,
    required String seatsInfo,
    required String wifiId,
    required String wifiPw,
  }) async {
    if (_isUploading) return false;

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<String> businessDays = [];
      for (int i = 0; i < selectedDays.length; i++) {
        if (selectedDays[i]) {
          businessDays.add(days[i]);
        }
      }

      final data = <String, dynamic>{
        'openTime': openTime,
        'closeTime': closeTime,
        'lastOrderTime': isLastOrderAvailable ? lastOrderTime : null,
        'businessDays': businessDays,
        'storePhoneNumber': storePhoneNumber,
        'isReservationAvailable': isReservationAvailable,
        'snsUrl': snsUrl,
        'isParkingAvailable': isParkingAvailable,
        'parkingInfo': isParkingAvailable ? parkingInfo : null,
        'isTakeoutAvailable': isTakeoutAvailable,
        'seatsInfo': seatsInfo,
        'isWifiAvailable': isWifiAvailable,
        'wifiId': isWifiAvailable ? wifiId : null,
        'wifiPw': isWifiAvailable ? wifiPw : null,
        'status': 'PUBLISHED', // 가게 등록 완료 상태로 변경
      };

      await _storeRepository.updateStoreOthers(storeId: storeId, data: data);
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '저장 중 오류 발생: $e';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }
}
