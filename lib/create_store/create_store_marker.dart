import 'dart:async';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter/material.dart';

//ios도 나중에 넣을 것
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eat_road_manager/create_store/create_store_marker_search_address.dart';

enum MarkerMode { search, manual }

class Coordinates {
  final double lat;
  final double lng;

  Coordinates(this.lat, this.lng);

  String() {
    return 'Lat: $lat, Lng: $lng';
  }
}

class CreateStoreMarker extends StatefulWidget {
  final String storeId;

  const CreateStoreMarker({super.key, required this.storeId});

  @override
  State<CreateStoreMarker> createState() => _CreateStoreMarkerState();
}

class _CreateStoreMarkerState extends State<CreateStoreMarker> {
  bool _hasPermission = false;
  bool _isMarkCreated = false;
  late NaverMapController _mapController;
  final Completer<NaverMapController> _controllerCompleter = Completer();
  final TextEditingController _addressController = TextEditingController();
  MarkerMode _mode = MarkerMode.search;
  NLatLng? _currentCenter;

  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      debugPrint("위치 권한 허용 되어있음");
      return true;
    } else if (status.isDenied) {
      var newStatus = await Permission.location.request();
      if (newStatus.isGranted) {
        debugPrint("위치 권한 허용됨");
        return true;
      } else {
        debugPrint("위치 권한 거부됨");
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      debugPrint("위치 권한 영구 거부됨");
      openAppSettings();
      return false;
    }
    return false;
  }

  Future<void> _checkPermission() async {
    final isGranted = await requestLocationPermission();
    setState(() {
      _hasPermission = isGranted;
    });
  }

  //geocoding API를 이용하여 도로명주소를 위도, 경도로 변환
  Future<Coordinates?> getCoordinatesFromAddress(String address) async {
    final String clientId = 'vbjkz22vte';
    final String clientSecret = 'FkRp5jplV4VLhEnzt0em2gm3pYGPLIf8DcduG5XA';

    final String query = Uri.encodeComponent(address);
    final String url =
        'https://maps.apigw.ntruss.com/map-geocode/v2/geocode?query=$query';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-ncp-apigw-api-key-id': clientId,
          'x-ncp-apigw-api-key': clientSecret,
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && (data['addresses'] as List).isNotEmpty) {
          final addressInfo = data['addresses'][0];
          final double latitude = double.parse(addressInfo['y']);
          final double longitude = double.parse(addressInfo['x']);

          return Coordinates(latitude, longitude);
        } else {
          debugPrint('주소 변환 실패: ${data['errorMessage']}');
          return null;
        }
      } else {
        debugPrint('API 호출 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('에러 발생: $e');
      return null;
    }
  }

  Future<String?> _getAddressFromCoordinates(NLatLng position) async {
    final String clientId = 'vbjkz22vte';
    final String clientSecret = 'FkRp5jplV4VLhEnzt0em2gm3pYGPLIf8DcduG5XA';
    final String url =
        'https://maps.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=${position.longitude},${position.latitude}&output=json';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-ncp-apigw-api-key-id': clientId,
          'x-ncp-apigw-api-key': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          debugPrint('Reverse geocode response body is empty.');
          return '주소를 찾을 수 없습니다.';
        }

        final data = json.decode(response.body);
        if (data['status']['code'] == 0 && (data['results'] as List).isNotEmpty) {
          final result = data['results'][0];
          debugPrint('${data['results']}');
          final region = result['region'];

          final String area1 = region['area1']?['name'] ?? '';
          final String area2 = region['area2']?['name'] ?? '';
          final String area3 = region['area3']?['name'] ?? '';

          String landAddress = '';
          if (result['land'] != null) {
            final land = result['land'];
            final String landName = land['name'] ?? '';
            final String landNumber1 = land['number1'] ?? '';
            final String landNumber2 = land['number2'] ?? '';
            landAddress = '$landName $landNumber1 $landNumber2'.trim();
          }

          final fullAddress = '$area1 $area2 $area3 $landAddress'.trim();

          if (fullAddress.isEmpty) {
            return '주소 정보를 찾을 수 없습니다.';
          }
          return fullAddress;
        } else {
          debugPrint('Reverse geocode API error: ${data['status']?['message']}');
          return '주소를 찾을 수 없습니다.';
        }
      } else {
        debugPrint('Reverse geocode API call failed with status: ${response.statusCode}, body: ${response.body}');
        return 'API 호출 실패';
      }
    } catch (e, s) {
      debugPrint('Exception in _getAddressFromCoordinates: $e\n$s');
      return '주소 변환 중 에러 발생';
    }
  }

  void _addMarkerAtCoordinates(NLatLng position) async {
    _mapController.clearOverlays();
    final marker = NMarker(id: 'selected', position: position);
    _mapController.addOverlay(marker);

    final address = await _getAddressFromCoordinates(position);
    if (address != null && mounted) {
      setState(() {
        _addressController.text = address;
        _isMarkCreated = true;
      });
    }
  }

  //도로명 주소를 이용해 위도와 경도를 가져오고 마커 생성
  void _searchAndMarkAddress() async {
    final address = _addressController.text;
    if (address.isEmpty) return;

    final coordinates = await getCoordinatesFromAddress(address);

    if (coordinates != null && mounted) {
      final position = NLatLng(coordinates.lat, coordinates.lng);
      _mapController.clearOverlays();
      final marker = NMarker(
        id: address,
        position: position,
      );
      _mapController.addOverlay(marker);

      var newCamera = NCameraUpdate.withParams(target: position, zoom: 15);
      _mapController.updateCamera(newCamera);

      setState(() {
        _isMarkCreated = true;
      });
    }
  }

  Future<void> _openAddressPopup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressSearchView(),
        fullscreenDialog: true,
      ),
    );

    if (result != null && result is String) {
      setState(() {
        _addressController.text = result;
      });
      _searchAndMarkAddress();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    const seoulCityHall = NLatLng(37.5665, 126.9780);
    final safeAreaPadding = MediaQuery.paddingOf(context);
    return Scaffold(
      appBar: AppBar(title: Text("가게 마커 생성")),
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              contentPadding: safeAreaPadding,
              initialCameraPosition: NCameraPosition(
                target: seoulCityHall,
                zoom: 12,
              ),
              locationButtonEnable: true,
            ),
            onMapReady: (controller) {
              _mapController = controller;
              _controllerCompleter.complete(controller);
            },
            onCameraChange: (reason, latLng) {
              if (_mode == MarkerMode.manual) {
                setState(() {
                  _currentCenter = latLng as NLatLng?;
                });
              }
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(125),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: _addressController,
                          decoration: InputDecoration(
                            hintText: _mode == MarkerMode.search
                                ? '주소를 입력해 주세요'
                                : '지도 중앙의 주소가 표시됩니다',
                            border: InputBorder.none,
                          ),
                          onTap: _mode == MarkerMode.search ? _openAddressPopup : null,
                        ),
                      ),
                      if (_mode == MarkerMode.search)
                        IconButton(
                          onPressed: _searchAndMarkAddress,
                          icon: Icon(Icons.location_on),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<MarkerMode>(
                  segments: const <ButtonSegment<MarkerMode>>[
                    ButtonSegment<MarkerMode>(
                        value: MarkerMode.search, label: Text('주소 검색')),
                    ButtonSegment<MarkerMode>(
                        value: MarkerMode.manual, label: Text('지도에서 선택')),
                  ],
                  selected: <MarkerMode>{_mode},
                  onSelectionChanged: (Set<MarkerMode> newSelection) async {
                    final newMode = newSelection.first;
                    if (newMode == MarkerMode.manual) {
                      final cameraPosition = await _mapController.getCameraPosition();
                      setState(() {
                        _currentCenter = cameraPosition.target;
                        _mode = newMode;
                        _isMarkCreated = false;
                        _mapController.clearOverlays();
                        _addressController.clear();
                      });
                    } else {
                      setState(() {
                        _mode = newMode;
                        _isMarkCreated = false;
                        _mapController.clearOverlays();
                        _addressController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          if (_mode == MarkerMode.manual)
            const Center(
              child: Icon(Icons.location_pin, size: 50, color: Colors.red),
            ),
          if (_mode == MarkerMode.manual && !_isMarkCreated)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("이 위치로 지정 클릭");
                  debugPrint("$_currentCenter");
                  if (_currentCenter != null) {
                    _addMarkerAtCoordinates(_currentCenter!);
                  }
                },
                child: const Text('이 위치로 지정'),
              ),
            ),
          if (_isMarkCreated)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint("버튼 클릭");
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text('가게 위치 저장 후 다음 단계로'),
              ),
            ),
        ],
      ),
    );
  }
}
