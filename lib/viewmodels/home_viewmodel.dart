import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';
import '../repositories/store_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final StoreRepository _storeRepository;

  bool _isCreatingStore = false;
  String? _errorMessage;

  HomeViewModel({
    AuthRepository? authRepository,
    StoreRepository? storeRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _storeRepository = storeRepository ?? StoreRepository();

  bool get isCreatingStore => _isCreatingStore;
  String? get errorMessage => _errorMessage;

  /// Retrieves an existing draft or creates a new draft store.
  /// Returns the storeId string or null if error occurred.
  Future<String?> getOrCreateDraftStore() async {
    if (_isCreatingStore) return null;

    _isCreatingStore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authRepository.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인 해주세요');
      }

      final storeId = await _storeRepository.getOrCreateDraftStore(userId);
      _isCreatingStore = false;
      notifyListeners();
      return storeId;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isCreatingStore = false;
      notifyListeners();
      return null;
    }
  }
}
