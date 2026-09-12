import 'package:flutter/material.dart';
import '../repositories/store_repository.dart';

class CreateStoreOthersViewModel extends ChangeNotifier {
  final String storeId;
  final StoreRepository _storeRepository;

  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  final List<bool> selectedDays = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

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

  bool get hasSelectedAnyDay => selectedDays.any((d) => d);

  bool get isEverydaySelected => selectedDays.every((d) => d);

  bool get isWeekdaysSelected =>
      selectedDays[0] &&
      selectedDays[1] &&
      selectedDays[2] &&
      selectedDays[3] &&
      selectedDays[4] &&
      !selectedDays[5] &&
      !selectedDays[6];

  bool get isWeekendsSelected =>
      !selectedDays[0] &&
      !selectedDays[1] &&
      !selectedDays[2] &&
      !selectedDays[3] &&
      !selectedDays[4] &&
      selectedDays[5] &&
      selectedDays[6];

  void toggleDay(int index) {
    if (index >= 0 && index < selectedDays.length) {
      selectedDays[index] = !selectedDays[index];
      notifyListeners();
    }
  }

  void selectEveryday() {
    for (int i = 0; i < selectedDays.length; i++) {
      selectedDays[i] = true;
    }
    notifyListeners();
  }

  void selectWeekdays() {
    for (int i = 0; i < 5; i++) {
      selectedDays[i] = true;
    }
    selectedDays[5] = false;
    selectedDays[6] = false;
    notifyListeners();
  }

  void selectWeekends() {
    for (int i = 0; i < 5; i++) {
      selectedDays[i] = false;
    }
    selectedDays[5] = true;
    selectedDays[6] = true;
    notifyListeners();
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

  bool validate({required String openTime, required String closeTime}) {
    if (!hasSelectedAnyDay) {
      _errorMessage = '영업 요일을 최소 1개 이상 선택해 주세요.';
      notifyListeners();
      return false;
    }

    if (openTime.trim().isEmpty || closeTime.trim().isEmpty) {
      _errorMessage = '영업 시작 시간과 마감 시간을 모두 설정해 주세요.';
      notifyListeners();
      return false;
    }

    return true;
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

    if (!validate(openTime: openTime, closeTime: closeTime)) {
      return false;
    }

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
        'open_time': openTime.trim(),
        'close_time': closeTime.trim(),
        'last_order_time':
            isLastOrderAvailable &&
                lastOrderTime != null &&
                lastOrderTime.isNotEmpty
            ? lastOrderTime.trim()
            : null,
        'business_days': businessDays,
        'store_phone_number': storePhoneNumber.trim(),
        'is_reservation_available': isReservationAvailable,
        'sns_url': snsUrl.trim(),
        'is_parking_available': isParkingAvailable,
        'parking_info': isParkingAvailable && parkingInfo.trim().isNotEmpty
            ? parkingInfo.trim()
            : null,
        'is_takeout_available': isTakeoutAvailable,
        'seats_info': seatsInfo.trim(),
        'is_wifi_available': isWifiAvailable,
        'wifi_id': isWifiAvailable && wifiId.trim().isNotEmpty
            ? wifiId.trim()
            : null,
        'wifi_pw': isWifiAvailable && wifiPw.trim().isNotEmpty
            ? wifiPw.trim()
            : null,
        'status': 'PUBLISHED', // 가게 등록 완료 상태로 변경
      };

      await _storeRepository.updateStoreOthers(storeId: storeId, data: data);
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('가게 운영 정보 저장 오류: $e');
      _errorMessage = '저장 중 오류 발생: $e';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }
}
