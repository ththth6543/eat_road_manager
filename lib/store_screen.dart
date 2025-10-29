import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'speech_bubble_painter.dart';
import 'detailed_store_screen.dart';

final supabase = Supabase.instance.client;

class Store {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? bdMgtSn;
  final String? roadAddr;

  Store({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.bdMgtSn,
    this.roadAddr,
  });

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'],
      name: map['name'] ?? '이름 없음',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      bdMgtSn: map['bdMgtSn'],
      roadAddr: map['roadAddr'],
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
  //Map<String, List<Store>> _groupedStores = {};

  // --- 커스텀 정보창을 위한 상태 변수 ---
  List<Store>? _selectedStores;
  Offset? _infoWindowOffset;
  String? _selectedMarkerId;
  // ---------------------------------

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    try {
      final mapControllerFuture = _mapController.future;
      final storesFuture = _fetchDataAndStores();

      final results = await Future.wait([mapControllerFuture, storesFuture]);

      final controller = results[0] as NaverMapController;
      final nearbyStores = results[1] as List<Store>;

      // 1. 모든 가게를 일단 bdMgtSn 기준으로 그룹화
      final initialGroups = groupBy(
        nearbyStores,
        (store) => store.bdMgtSn?.isNotEmpty == true ? store.bdMgtSn! : store.id.toString(),
      );

      // 2. 4개 이상인 그룹과 그 외(개별)로 분리
      final Map<String, List<Store>> groupsToShow = {};
      final List<Store> individualsToShow = [];

      initialGroups.forEach((key, stores) {
        // bdMgtSn이 있고, 개수가 4개 이상인 경우만 그룹으로 처리
        if (stores.first.bdMgtSn != null && stores.first.bdMgtSn!.isNotEmpty && stores.length >= 4) {
          groupsToShow[key] = stores;
        } else {
          individualsToShow.addAll(stores);
        }
      });

      // 3. 분리된 데이터를 지도에 업데이트
      _updateMap(controller, groupsToShow, individualsToShow);

      setState(() => _isLoading = false);

    } catch (e) {
      _handleError(e);
    }
  }

  // 데이터 로딩 로직을 별도 함수로 분리
  Future<List<Store>> _fetchDataAndStores() async {
    setState(() => _message = '현재 위치를 찾는 중...');
    _currentPosition = await _getCurrentLocation();
    setState(() => _message = '주변 가게를 찾는 중...');
    return await _fetchNearbyStores(_currentPosition!);
  }

  void _updateMap(NaverMapController controller, Map<String, List<Store>> groupedStores, List<Store> individualStores) {
    if (_currentPosition != null) {
      controller.updateCamera(NCameraUpdate.withParams(
        target: NLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 15,
      ));
    }

    controller.clearOverlays(type: NOverlayType.marker);
    final markers = <NMarker>{};

    // 그룹 마커 생성 (4개 이상)
    groupedStores.forEach((key, storesInGroup) {
      final firstStore = storesInGroup.first;
      final marker = NMarker(
        id: key, // 그룹의 고유 ID로 bdMgtSn 사용
        position: NLatLng(firstStore.latitude, firstStore.longitude),
        caption: NOverlayCaption(text: '${storesInGroup.length}개'),
        size: const Size(30, 40),
      );

      marker.setOnTapListener((tappedMarker) async {
        final point = await controller.latLngToScreenLocation(tappedMarker.position);
        setState(() {
          _selectedMarkerId = tappedMarker.info.id;
          _selectedStores = storesInGroup;
          _infoWindowOffset = Offset(point.x.toDouble(), point.y.toDouble());
        });
      });
      markers.add(marker);
    });

    // 개별 마커 생성 (3개 이하)
    for (final store in individualStores) {
      final marker = NMarker(
        id: store.id.toString(),
        position: NLatLng(store.latitude, store.longitude),
        caption: NOverlayCaption(text: store.name),
        size: const Size(30, 40),
      );

      marker.setOnTapListener((tappedMarker) async {
        final point = await controller.latLngToScreenLocation(tappedMarker.position);
        setState(() {
          _selectedMarkerId = tappedMarker.info.id;
          _selectedStores = [store]; // 리스트에 현재 가게 하나만 담음
          _infoWindowOffset = Offset(point.x.toDouble(), point.y.toDouble());
        });
      });
      markers.add(marker);
    }

    controller.addOverlayAll(markers);
  }

  void _closeInfoWindow() {
    setState(() {
      _selectedMarkerId = null;
      _infoWindowOffset = null;
      _selectedStores = null;
    });
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
              if (!_mapController.isCompleted) _mapController.complete(controller);
            },
            onMapTapped: (point, latLng) => _closeInfoWindow(),
            onCameraChange: (reason, animated) => _closeInfoWindow(),
          ),
          if (_isLoading)
            _buildLoadingIndicator(),
          if (_selectedMarkerId != null && _infoWindowOffset != null && _selectedStores != null)
            _buildCustomInfoWindow(),
        ],
      ),
    );
  }

  Widget _buildCustomInfoWindow() {
    const double infoWindowWidth = 250.0;
    final double infoWindowHeight = 60.0 + (_selectedStores!.length * 50.0);

    return Positioned(
      left: _infoWindowOffset!.dx - (infoWindowWidth / 2),
      top: _infoWindowOffset!.dy - infoWindowHeight - 45, // 마커와 말풍선 사이 간격
      child: Container(
        // 그림자 효과를 위한 컨테이너
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(
          painter: SpeechBubblePainter(
            bubbleColor: Colors.white,
            borderColor: Colors.grey[400]!,
            borderWidth: 1.5,
          ),
          child: Container(
            width: infoWindowWidth,
            height: infoWindowHeight,
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0), // 꼬리 고려
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedStores!.first.roadAddr ?? '가게 목록',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _selectedStores!.length,
                    itemBuilder: (context, index) {
                      final store = _selectedStores![index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.lightBlue.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            // 정보창을 먼저 닫음
                            _closeInfoWindow();

                            // DraggableScrollableSheet를 포함한 상세 화면을 모달로 띄움
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true, // 전체 화면까지 드래그 가능하도록 설정
                              backgroundColor: Colors.transparent, // 배경을 투명하게 하여 커스텀 디자인 적용
                              builder: (context) => DetailedStoreScreen(store: store),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
                            child: Text(store.name, style: const TextStyle(fontSize: 18)),
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
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _handleError(Object e) {
    setState(() {
      _isLoading = false;
      _message = '오류: ${e.toString()}';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')),
      );
    }
  }

  // --- 데이터 로딩 및 위치 관련 함수들 (기존과 동일) ---
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('위치 서비스가 비활성화되어 있습니다.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('위치 권한이 거부되었습니다.');
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.');
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<Store>> _fetchNearbyStores(Position position) async {
    try {
      debugPrint('[DEBUG] nearby_stores RPC 호출 시작: lat=${position.latitude}, long=${position.longitude}');

      final List<dynamic> result = await supabase
          .rpc(
            'nearby_stores',
            params: {
              'lat': position.latitude,
              'long': position.longitude,
              'radius_m': 5000,
            },
          )
          .timeout(const Duration(seconds: 10)); // 10초 타임아웃 추가

      if (result.isEmpty) {
        debugPrint('[DEBUG] 주변 가게 없음.');
        return [];
      }

      debugPrint('[DEBUG] ${result.length}개의 가게를 찾았습니다. 파싱 시작...');
      final stores = result.map((data) => Store.fromMap(data as Map<String, dynamic>)).toList();
      debugPrint('[DEBUG] 파싱 완료. 가게 목록을 반환합니다.');
      return stores;

    } on TimeoutException {
      debugPrint('[DEBUG] 오류: RPC 호출이 10초를 초과했습니다 (Timeout).');
      return Future.error('서버 응답이 너무 늦어 데이터를 불러오지 못했습니다.');
    } catch (e) {
      debugPrint('[DEBUG] _fetchNearbyStores에서 오류 발생: $e');
      return Future.error('가게 정보를 불러오는 데 실패했습니다.');
    }
  }
}