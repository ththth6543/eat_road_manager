import 'dart:async';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter/material.dart';
import 'detailed_store_screen.dart';

//ios도 나중에 넣을 것
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Coordinates {
  final double lat;
  final double lng;

  Coordinates(this.lat, this.lng);

  String() {
    return 'Lat: $lat, Lng: $lng';
  }
}

class CreateStoreMarker extends StatefulWidget {
  const CreateStoreMarker({super.key});

  @override
  State<CreateStoreMarker> createState() => _CreateStoreMarkerState();
}

class _CreateStoreMarkerState extends State<CreateStoreMarker> {
  //변수
  bool _hasPermission = false;
  late NaverMapController _mapController;
  final Completer<NaverMapController> _controllerCompleter = Completer();
  final TextEditingController _addressController = TextEditingController();

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

  //도로명 주소를 이용해 위도와 경도를 가져오고 마커 생성
  void _searchAndMarkAddress() async {
    final address = _addressController.text;
    final coordinates = await getCoordinatesFromAddress(address);

    if (coordinates != null && mounted) {
      final position = NLatLng(coordinates.lat, coordinates.lng);

      final marker = NMarker(
        id: address, // Required
        position: position, // Required
        caption: NOverlayCaption(text: "lat: ${coordinates.lat}, lng: ${coordinates.lng}"), // Optional
      );

      marker.setOnTapListener((NMarker tappedMarker) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => StoreScreen()));
      });

      _mapController.addOverlay(marker); // 지도에 마커를 추가

      var newCamera = NCameraUpdate.withParams(
        target: position,
        zoom: 15,
        bearing: 0,
        tilt: 0,
      );
      _mapController.updateCamera(newCamera);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    const seoulCityHall = NLatLng(37.4411228, 127.1573973);
    final safeAreaPadding = MediaQuery.paddingOf(context);
    return Scaffold(
      appBar: AppBar(title: Text("가게 마커 생성")),
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              contentPadding: safeAreaPadding,
              // 화면의 SafeArea에 중요 지도 요소가 들어가지 않도록 설정하는 Padding. 필요한 경우에만 사용하세요.
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
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
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
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: '주소를 입력하세요',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) => _searchAndMarkAddress(),
                    ),
                  ),
                  IconButton(
                    onPressed: _searchAndMarkAddress,
                    icon: Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
