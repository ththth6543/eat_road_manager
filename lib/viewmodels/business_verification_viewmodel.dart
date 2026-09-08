import 'package:flutter/foundation.dart';
import '../models/juso_address.dart';
import '../repositories/verification_repository.dart';

class BusinessRegistrationViewModel extends ChangeNotifier {
  final VerificationRepository _repository;

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  BusinessRegistrationViewModel({VerificationRepository? repository})
      : _repository = repository ?? VerificationRepository();

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  Future<bool> verify({
    required String bNo,
    required String startDt,
    required String pName,
  }) async {
    if (bNo.length != 10 || startDt.length != 8 || pName.trim().isEmpty) {
      _errorMessage = "입력 형식이 올바르지 않습니다.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final valid = await _repository.verifyBusinessRegistration(
        bNo: bNo,
        startDt: startDt,
        pName: pName,
      );

      _isLoading = false;
      _isSuccess = valid;
      if (!valid) {
        _errorMessage = '등록된 정보와 일치하지 않습니다. 입력한 내용을 다시 확인해 주세요.';
      }
      notifyListeners();
      return valid;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '네트워크 연결 상태를 확인해 주세요.';
      notifyListeners();
      return false;
    }
  }
}

class BusinessLicenseViewModel extends ChangeNotifier {
  final VerificationRepository _repository;

  bool _isLoading = false;
  List<dynamic> _searchResults = [];
  String? _errorMessage;

  BusinessLicenseViewModel({VerificationRepository? repository})
      : _repository = repository ?? VerificationRepository();

  bool get isLoading => _isLoading;
  List<dynamic> get searchResults => _searchResults;
  String? get errorMessage => _errorMessage;

  Future<void> verifyLicense(String lcnsNo) async {
    if (lcnsNo.trim().isEmpty) {
      _errorMessage = "상호명을 입력해주세요.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.verifyFoodSafetyLicense(lcnsNo);
      _searchResults = results;
      _isLoading = false;
      if (results.isEmpty) {
        _errorMessage = '검색 결과가 없습니다. 번호를 다시 확인해주세요.';
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '네트워크 연결 상태 또는 입력 번호를 확인해 주세요.';
      notifyListeners();
    }
  }
}

class AddressSearchViewModel extends ChangeNotifier {
  final VerificationRepository _repository;

  bool _isLoading = false;
  bool _hasSearched = false;
  List<JusoAddress> _results = [];
  JusoAddress? _selectedJuso;
  String? _errorMessage;

  AddressSearchViewModel({VerificationRepository? repository})
      : _repository = repository ?? VerificationRepository();

  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  List<JusoAddress> get results => _results;
  JusoAddress? get selectedJuso => _selectedJuso;
  String? get errorMessage => _errorMessage;

  void selectJuso(JusoAddress juso) {
    _selectedJuso = juso;
    notifyListeners();
  }

  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) return;

    _isLoading = true;
    _hasSearched = true;
    _results = [];
    _errorMessage = null;
    notifyListeners();

    try {
      _results = await _repository.searchAddress(keyword);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '주소 검색 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }
}
