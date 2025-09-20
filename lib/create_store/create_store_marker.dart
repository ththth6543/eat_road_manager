import 'dart:async';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter/material.dart';

//ios도 나중에 넣을 것
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eat_road_manager/create_store/create_store_marker_search_address.dart';

// 3단계 워크플로우를 관리하기 위한 열거형
enum MarkerCreationStep { initial, fineTuning, confirmed }

class CreateStoreMarker extends StatefulWidget {
  final String storeId;

  const CreateStoreMarker({super.key, required this.storeId});

  @override
  State<CreateStoreMarker> createState() => _CreateStoreMarkerState();
}

class _CreateStoreMarkerState extends State<CreateStoreMarker> {
  // State Management
  MarkerCreationStep _step = MarkerCreationStep.initial;
  late NaverMapController _mapController;
  final Completer<NaverMapController> _controllerCompleter = Completer();

  // Address & Coordinate Data
  Map<String, dynamic>? _initialAddressData; // 주소 검색 결과 (도로명, 지번, 행정구역 등)
  NLatLng? _initialCoordinates; // 주소 검색으로 찾은 초기 좌표
  NLatLng? _finalCoordinates; // 사용자가 조정한 최종 좌표

  // Permissions
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final isGranted = await requestLocationPermission();
    setState(() {
      _hasPermission = isGranted;
    });
  }

  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      var newStatus = await Permission.location.request();
      return newStatus.isGranted;
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }
    return false;
  }

  // Step 1: 주소 검색 팝업 열기
  Future<void> _openAddressSearch() async {
    // AddressSearchView가 전체 주소 데이터를 Map으로 반환한다고 가정합니다.
    // 이 부분은 AddressSearchView의 수정이 필요합니다.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddressSearchView()),
    );

    if (result != null && result is Map<String, dynamic>) {
      // Geocoding을 통해 좌표 가져오기
      final coords = await _getCoordinatesFromAddress(result['roadAddr']);

      if (coords != null) {
        setState(() {
          _initialAddressData = result;
          _initialCoordinates = coords;
          _step = MarkerCreationStep.fineTuning; // 다음 단계로 전환
        });

        // 지도에 초기 마커 표시 및 카메라 이동
        _mapController.clearOverlays();
        _mapController.addOverlay(NMarker(id: 'initial', position: coords));
        _mapController.updateCamera(NCameraUpdate.withParams(target: coords, zoom: 16));
      }
    }
  }

  // Geocoding API 호출 (주소 -> 좌표)
  Future<NLatLng?> _getCoordinatesFromAddress(String address) async {
    final String clientId = 'vbjkz22vte';
    final String clientSecret = 'FkRp5jplV4VLhEnzt0em2gm3pYGPLIf8DcduG5XA';
    final String url =
        'https://maps.apigw.ntruss.com/map-geocode/v2/geocode?query=${Uri.encodeComponent(address)}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-ncp-apigw-api-key-id': clientId,
          'x-ncp-apigw-api-key': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && (data['addresses'] as List).isNotEmpty) {
          final addressInfo = data['addresses'][0];
          final double latitude = double.parse(addressInfo['y']);
          final double longitude = double.parse(addressInfo['x']);
          return NLatLng(latitude, longitude);
        } else {
          debugPrint('Geocoding API error: ${data['errorMessage']}');
          return null;
        }
      } else {
        debugPrint('Geocoding API call failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception in _getCoordinatesFromAddress: $e');
      return null;
    }
  }

  // Step 2: 위치 미세 조정 후 확정
  void _confirmFineTunedLocation() async {
    final cameraPosition = await _mapController.getCameraPosition();
    final center = cameraPosition.target;

    setState(() {
      _finalCoordinates = center;
      _step = MarkerCreationStep.confirmed; // 마지막 단계로 전환
    });

    // 최종 위치에 마커 업데이트
    _mapController.clearOverlays();
    _mapController.addOverlay(NMarker(id: 'final', position: center));
  }

  // Step 3: 최종 저장
  void _saveStoreLocation() {
    // 여기서 _initialAddressData와 _finalCoordinates를 사용하여 DB에 저장
    debugPrint("--- 최종 저장 데이터 ---");
    debugPrint("주소 정보: $_initialAddressData");
    debugPrint("최종 좌표: $_finalCoordinates");
    // ... 저장 로직 ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가게 위치 등록'),
        leading: _step != MarkerCreationStep.initial
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    // 이전 단계로 돌아가기 로직
                    if (_step == MarkerCreationStep.confirmed) {
                      _step = MarkerCreationStep.fineTuning;
                    } else if (_step == MarkerCreationStep.fineTuning) {
                      _step = MarkerCreationStep.initial;
                      _mapController.clearOverlays();
                    }
                  });
                },
              )
            : null,
      ),
      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.5665, 126.9780), // 서울시청
                zoom: 12,
              ),
              locationButtonEnable: true,
            ),
            onMapReady: (controller) {
              _mapController = controller;
              _controllerCompleter.complete(controller);
            },
          ),
          _buildStepUI(), // 현재 단계에 맞는 UI를 빌드하는 위젯
        ],
      ),
    );
  }

  // 각 단계별 UI를 빌드하는 함수
  Widget _buildStepUI() {
    switch (_step) {
      case MarkerCreationStep.initial:
        return _buildInitialUI();
      case MarkerCreationStep.fineTuning:
        return _buildFineTuningUI();
      case MarkerCreationStep.confirmed:
        return _buildConfirmedUI();
    }
  }

  // 1단계: 주소 검색 UI
  Widget _buildInitialUI() {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.search),
        label: const Text('주소 검색으로 시작하기', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
        onPressed: _openAddressSearch,
      ),
    );
  }

  // 2단계: 위치 미세 조정 UI
  Widget _buildFineTuningUI() {
    return Stack(
      children: [
        const Center(
          child: Icon(Icons.add, size: 30, color: Colors.black),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.6),
            padding: const EdgeInsets.all(12.0),
            child: const Text(
              '지도를 움직여 마커를 정확한 위치에 맞추고, 아래 버튼을 눌러주세요.',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: _confirmFineTunedLocation,
            child: const Text('이 위치로 확정'),
          ),
        ),
      ],
    );
  }

  // 3단계: 최종 확인 UI
  Widget _buildConfirmedUI() {
    String roadAddress = _initialAddressData?['roadAddr'] ?? '주소 정보 없음';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(roadAddress, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('위도: ${_finalCoordinates?.latitude.toStringAsFixed(5)}'),
              Text('경도: ${_finalCoordinates?.longitude.toStringAsFixed(5)}'),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _saveStoreLocation,
                child: const Text('가게 위치 저장 후 다음 단계로'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
