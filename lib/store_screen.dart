import 'dart:async';
import 'package:collection/collection.dart';
import 'package:eat_road_manager/detailed_store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'speech_bubble_painter.dart';

final supabase = Supabase.instance.client;

class Store {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? bdMgtSn;
  final String? roadAddress;

  Store({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.bdMgtSn,
    this.roadAddress,
  });

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'],
      name: map['name'] ?? '이름 없음',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      bdMgtSn: map['bdMgtSn'],
      roadAddress: map['road_address'],
    );
  }
}

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final Completer<NaverMapController> _mapController = Completer();
  bool _isLoading = true;
  String _message = '현재 위치를 찾는 중...';
  Position? _currentPosition;

  // 정보창(말풍선) 관련 상태
  List<Store>? _selectedStoresForInfoWindow;
  Offset? _infoWindowOffset;
  String? _selectedMarkerIdForInfoWindow;

  // 상세 화면(DraggableSheet) 관련 상태
  int? _selectedStoreIdForSheet;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    try {
      final mapController = await _mapController.future;
      final stores = await _fetchDataAndStores();
      final groupedStores = groupBy(
        stores,
        (store) => store.bdMgtSn?.isNotEmpty == true
            ? store.bdMgtSn!
            : store.id.toString(),
      );
      _updateMap(mapController, groupedStores);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<List<Store>> _fetchDataAndStores() async {
    if (mounted) setState(() => _message = '현재 위치를 찾는 중...');
    _currentPosition = await _getCurrentLocation();
    if (mounted) setState(() => _message = '주변 가게를 찾는 중...');
    return await _fetchNearbyStores(_currentPosition!);
  }

  void _updateMap(
    NaverMapController controller,
    Map<String, List<Store>> allGroups,
  ) {
    if (_currentPosition != null) {
      controller.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 15,
        ),
      );
    }

    controller.clearOverlays(type: NOverlayType.marker);
    final markers = <NMarker>{};

    allGroups.forEach((key, storesInGroup) {
      if (storesInGroup.isEmpty) return;
      final firstStore = storesInGroup.first;
      NMarker marker;

      if (storesInGroup.length >= 2) {
        marker = NMarker(
          id: key,
          size: Size(30, 40),
          position: NLatLng(firstStore.latitude, firstStore.longitude),
          caption: NOverlayCaption(text: '${storesInGroup.length}개'),
        );
        marker.setOnTapListener(
          (_) => _showInfoWindow(storesInGroup, marker.position),
        );
      } else {
        marker = NMarker(
          id: firstStore.id.toString(),
          size: Size(30, 40),
          position: NLatLng(firstStore.latitude, firstStore.longitude),
          caption: NOverlayCaption(text: firstStore.name),
        );
        marker.setOnTapListener((_) => _showDetailedScreen(firstStore.id));
      }
      markers.add(marker);
    });

    controller.addOverlayAll(markers);
  }

  void _showInfoWindow(List<Store> stores, NLatLng position) async {
    final controller = await _mapController.future;
    final point = await controller.latLngToScreenLocation(position);
    setState(() {
      _selectedMarkerIdForInfoWindow = stores.first.bdMgtSn;
      _selectedStoresForInfoWindow = stores;
      _infoWindowOffset = Offset(point.x.toDouble(), point.y.toDouble());
    });
  }

  void _showDetailedScreen(int storeId) {
    _closeInfoWindow();
    setState(() {
      _selectedStoreIdForSheet = storeId;
    });
  }

  void _closeInfoWindow() {
    if (_selectedMarkerIdForInfoWindow != null) {
      setState(() {
        _selectedMarkerIdForInfoWindow = null;
      });
    }
  }

  void _closeDetailedScreen() {
    if (_selectedStoreIdForSheet != null) {
      setState(() {
        _selectedStoreIdForSheet = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주변 가게')),
      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.5666102, 126.9783881),
                zoom: 15,
              ),
              locationButtonEnable: true,
            ),
            onMapReady: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
            onMapTapped: (point, latLng) {
              _closeInfoWindow();
              _closeDetailedScreen();
            },
            onCameraChange: (reason, animated) => _closeInfoWindow(),
          ),
          if (_isLoading) _buildLoadingIndicator(),

          // 정보창(말풍선)
          if (_selectedMarkerIdForInfoWindow != null) _buildCustomInfoWindow(),

          // 상세 화면(Draggable Sheet)
          if (_selectedStoreIdForSheet != null)
            DetailedStoreScreen(
              storeId: _selectedStoreIdForSheet!,
              onClose: _closeDetailedScreen,
            ),
        ],
      ),
    );
  }

  Widget _buildCustomInfoWindow() {
    const double infoWindowWidth = 250.0;
    final double infoWindowHeight =
        60.0 + (_selectedStoresForInfoWindow!.length * 50.0);

    return Positioned(
      left: _infoWindowOffset!.dx - (infoWindowWidth / 2),
      top: _infoWindowOffset!.dy - infoWindowHeight - 45,
      child: CustomPaint(
        painter: SpeechBubblePainter(
          bubbleColor: Colors.white,
          borderColor: Colors.grey[400]!,
          borderWidth: 2,
        ),
        child: Container(
          width: infoWindowWidth,
          height: infoWindowHeight,
          padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedStoresForInfoWindow!.first.roadAddress ?? '가게 목록',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _selectedStoresForInfoWindow!.length,
                  itemBuilder: (context, index) {
                    final store = _selectedStoresForInfoWindow![index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.lightBlue.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showDetailedScreen(store.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 12.0,
                          ),
                          child: Text(
                            store.name,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withAlpha(120),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.blueAccent),
            const SizedBox(height: 16),
            Text(_message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _handleError(Object e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _message = '오류: ${e.toString()}';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')));
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('위치 서비스가 비활성화되어 있습니다.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        return Future.error('위치 권한이 거부되었습니다.');
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.');
    }
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<List<Store>> _fetchNearbyStores(Position position) async {
    try {
      final List<dynamic> result = await supabase
          .rpc(
            'nearby_stores',
            params: {
              'lat': position.latitude,
              'long': position.longitude,
              'radius_m': 5000,
            },
          )
          .timeout(const Duration(seconds: 10));
      if (result.isEmpty) return [];
      return result
          .map((data) => Store.fromMap(data as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw ('서버 응답이 너무 늦어 데이터를 불러오지 못했습니다.');
    } catch (e) {
      throw ('가게 정보를 불러오는 데 실패했습니다.');
    }
  }
}
