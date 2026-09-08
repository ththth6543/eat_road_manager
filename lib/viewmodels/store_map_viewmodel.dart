import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/location_service.dart';
import '../models/store.dart';
import '../repositories/store_repository.dart';

class StoreMapViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;

  bool _isLoading = true;
  String _message = '현재 위치를 찾는 중...';
  String? _errorMessage;
  Position? _currentPosition;

  List<Store> _stores = [];
  Map<String, List<Store>> _groupedStores = {};

  // Info window (말풍선) state
  List<Store>? _selectedStoresForInfoWindow;
  Offset? _infoWindowOffset;
  String? _selectedMarkerIdForInfoWindow;

  // Detailed sheet state
  int? _selectedStoreIdForSheet;

  StoreMapViewModel({StoreRepository? storeRepository})
    : _storeRepository = storeRepository ?? StoreRepository();

  bool get isLoading => _isLoading;
  String get message => _message;
  String? get errorMessage => _errorMessage;
  Position? get currentPosition => _currentPosition;
  List<Store> get stores => _stores;
  Map<String, List<Store>> get groupedStores => _groupedStores;

  List<Store>? get selectedStoresForInfoWindow => _selectedStoresForInfoWindow;
  Offset? get infoWindowOffset => _infoWindowOffset;
  String? get selectedMarkerIdForInfoWindow => _selectedMarkerIdForInfoWindow;
  int? get selectedStoreIdForSheet => _selectedStoreIdForSheet;

  /// Initialize location and load nearby stores
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    _message = '현재 위치를 찾는 중...';
    notifyListeners();

    try {
      _currentPosition = await LocationService.getCurrentPosition();

      _message = '주변 가게를 찾는 중...';
      notifyListeners();

      _stores = await _storeRepository.fetchNearbyStores(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );

      _groupedStores = groupBy(
        _stores,
        (store) => store.bdMgtSn?.isNotEmpty == true
            ? store.bdMgtSn!
            : store.id.toString(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void showInfoWindow(List<Store> stores, Offset offset, String markerId) {
    _selectedMarkerIdForInfoWindow = markerId;
    _selectedStoresForInfoWindow = stores;
    _infoWindowOffset = offset;
    notifyListeners();
  }

  void closeInfoWindow() {
    if (_selectedMarkerIdForInfoWindow != null) {
      _selectedMarkerIdForInfoWindow = null;
      _selectedStoresForInfoWindow = null;
      _infoWindowOffset = null;
      notifyListeners();
    }
  }

  void showDetailedScreen(int storeId) {
    closeInfoWindow();
    _selectedStoreIdForSheet = storeId;
    notifyListeners();
  }

  void closeDetailedScreen() {
    if (_selectedStoreIdForSheet != null) {
      _selectedStoreIdForSheet = null;
      notifyListeners();
    }
  }
}
