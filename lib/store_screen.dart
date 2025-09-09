import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase 클라이언트 초기화
final supabase = Supabase.instance.client;

// Supabase 'stores' 테이블에 매칭될 모델 클래스
// 실제 테이블의 컬럼에 맞게 수정해야 합니다.
class Store {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  Store({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'],
      name: map['name'],
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
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
  List<Store> _nearbyStores = [];

  @override
  void initState() {
    super.initState();
    _initializeAndLoadMarkers();
  }

  Future<void> _initializeAndLoadMarkers() async {
    try {
      // 1. 현재 위치 가져오기
      setState(() { _message = '현재 위치를 찾는 중...'; });
      _currentPosition = await _getCurrentLocation();

      // 2. 주변 가게 데이터 가져오기
      setState(() { _message = '주변 가게를 찾는 중...'; });
      _nearbyStores = await _fetchNearbyStores(_currentPosition!);

      // 3. 지도 컨트롤러가 준비될 때까지 대기
      final controller = await _mapController.future;

      // 4. 지도에 마커 추가 및 카메라 이동
      setState(() { _message = '지도에 가게를 표시합니다.'; });
      _updateMap(controller);

      // 5. 로딩 완료
      setState(() {
        _isLoading = false;
        _message = '완료!';
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = '오류: ${e.toString()}';
      });
      // 사용자에게 오류 메시지 표시 (예: SnackBar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}'
          )),
        );
      }
    }
  }

  void _updateMap(NaverMapController controller) {
    // 현재 위치로 카메라 이동
    if (_currentPosition != null) {
      final cameraUpdate = NCameraUpdate.withParams(
        target: NLatLng(_currentPosition!.latitude,
            _currentPosition!.longitude),
        zoom: 15,
      );
      controller.updateCamera(cameraUpdate);
    }

    // 기존 마커 제거 (선택적)
    controller.clearOverlays(type: NOverlayType.marker);

    // 새로운 마커 세트 생성
    final markers = _nearbyStores.map((store) {
      return NMarker(
        id: store.id.toString(),
        position: NLatLng(store.latitude, store.longitude),
        caption: NOverlayCaption(text: store.name),
        size: Size(20, 30)
      );
    }).toSet();

    // 지도에 마커 추가
    controller.addOverlayAll(markers);
  }


  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 비활성화되어 있습니다.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<List<Store>> _fetchNearbyStores(Position position) async {
    try {
      // Supabase RPC 호출
      // 검색 반경을 5km (5000m)로 설정
      final List<dynamic> result = await supabase.rpc(
        'nearby_stores',
        params: {
          'lat': position.latitude,
          'long': position.longitude,
          'radius_m': 5000,
        },
      );

      if (result.isEmpty) {
        debugPrint('No nearby stores found.');
        return [];
      }

      final stores = result
          .map((data) => Store.fromMap(data as Map<String, dynamic>))
          .toList();
      return stores;
    } catch (e) {
      // 오류 처리
      debugPrint('Error fetching nearby stores: $e');
      return Future.error('가게 정보를 불러오는 데 실패했습니다.');
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
                  zoom: 15
              ),
              locationButtonEnable: true,
            ),
            onMapReady: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(120),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(_message, style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
