import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Check and request location permission using permission_handler
  static Future<bool> requestLocationPermission() async {
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
      await openAppSettings();
      return false;
    }
    return false;
  }

  /// Get current GPS position with Geolocator
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화되어 있습니다.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
