import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../models/store_info.dart';
import '../repositories/menu_repository.dart';
import '../repositories/store_repository.dart';

class DetailedStoreViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;
  final MenuRepository _menuRepository;

  final String storeId;
  StoreInfo? _storeInfo;
  List<MenuItem>? _menus;

  bool _isStoreLoading = true;
  bool _isMenusLoading = true;
  String? _storeError;
  String? _menuError;

  DetailedStoreViewModel({
    required this.storeId,
    StoreRepository? storeRepository,
    MenuRepository? menuRepository,
  })  : _storeRepository = storeRepository ?? StoreRepository(),
        _menuRepository = menuRepository ?? MenuRepository();

  StoreInfo? get storeInfo => _storeInfo;
  List<MenuItem>? get menus => _menus;
  bool get isStoreLoading => _isStoreLoading;
  bool get isMenusLoading => _isMenusLoading;
  String? get storeError => _storeError;
  String? get menuError => _menuError;

  Future<void> fetchStoreDetails() async {
    _isStoreLoading = true;
    _storeError = null;
    notifyListeners();

    try {
      _storeInfo = await _storeRepository.getStoreInfo(storeId);
      _isStoreLoading = false;
      notifyListeners();
    } catch (e) {
      _storeError = '데이터를 불러오는 데 실패했습니다: $e';
      _isStoreLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMenus() async {
    _isMenusLoading = true;
    _menuError = null;
    notifyListeners();

    try {
      _menus = await _menuRepository.fetchMenusByStoreId(storeId);
      _isMenusLoading = false;
      notifyListeners();
    } catch (e) {
      _menuError = '데이터를 불러오는 데 실패했습니다: $e';
      _isMenusLoading = false;
      notifyListeners();
    }
  }
}
