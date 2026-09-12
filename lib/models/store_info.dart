import 'package:equatable/equatable.dart';

class StoreInfo extends Equatable {
  // 필수 값
  final String name;
  final String description;
  final String roadAddr;
  final String openTime;
  final String closeTime;
  final List<String> businessDays;
  final bool isReservationAvailable;
  final bool isParkingAvailable;
  final bool isTakeoutAvailable;
  final bool isWifiAvailable;

  // 선택 값 (Nullable)
  final String? detailAddr;
  final String? storePhoneNumber;
  final List<String> interiorImageUrls;
  final String? lastOrderTime;
  final String? parkingInfo;
  final String? snsUrl;
  final String? seatsInfo;
  final String? wifiId;
  final String? wifiPw;

  const StoreInfo({
    required this.name,
    required this.description,
    required this.roadAddr,
    required this.openTime,
    required this.closeTime,
    required this.businessDays,
    required this.isReservationAvailable,
    required this.isParkingAvailable,
    required this.isTakeoutAvailable,
    required this.isWifiAvailable,
    this.interiorImageUrls = const [],
    this.detailAddr,
    this.lastOrderTime,
    this.storePhoneNumber,
    this.snsUrl,
    this.parkingInfo,
    this.seatsInfo,
    this.wifiId,
    this.wifiPw,
  });

  // factory 생성자
  factory StoreInfo.fromMap(Map<String, dynamic> info) {
    return StoreInfo(
      name: info['name'] ?? '이름 없음',
      description: info['description'] ?? '가게 소개 작성을 깜박하셨나 봅니다',
      roadAddr: info['road_addr'] ?? '주소 정보 없음',
      openTime: info['open_time'] ?? '??:??',
      closeTime: info['close_time'] ?? '??:??',
      businessDays:
          (info['business_days'] as List<dynamic>?)?.cast<String>() ?? [],
      isReservationAvailable: info['is_reservation_available'] ?? false,
      isParkingAvailable: info['is_parking_available'] ?? false,
      isWifiAvailable: info['is_wifi_available'] ?? false,
      isTakeoutAvailable: info['is_takeout_available'] ?? false,
      interiorImageUrls:
          (info['image_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      detailAddr: info['detail_addr'],
      lastOrderTime: info['last_order_time'],
      storePhoneNumber: info['store_phone_number'],
      snsUrl: info['sns_url'],
      parkingInfo: info['parking_info'],
      seatsInfo: info['seats_info'],
      wifiId: info['wifi_id'],
      wifiPw: info['wifi_pw'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'road_addr': roadAddr,
      'open_time': openTime,
      'close_time': closeTime,
      'business_days': businessDays,
      'is_reservation_available': isReservationAvailable,
      'is_parking_available': isParkingAvailable,
      'is_takeout_available': isTakeoutAvailable,
      'is_wifi_available': isWifiAvailable,
      'image_urls': interiorImageUrls,
      'detail_addr': detailAddr,
      'last_order_time': lastOrderTime,
      'store_phone_number': storePhoneNumber,
      'sns_url': snsUrl,
      'parking_info': parkingInfo,
      'seats_info': seatsInfo,
      'wifi_id': wifiId,
      'wifi_pw': wifiPw,
    };
  }

  @override
  List<Object?> get props => [
        name,
        description,
        roadAddr,
        openTime,
        closeTime,
        businessDays,
        isReservationAvailable,
        isParkingAvailable,
        isTakeoutAvailable,
        isWifiAvailable,
        interiorImageUrls,
        detailAddr,
        lastOrderTime,
        storePhoneNumber,
        snsUrl,
        parkingInfo,
        seatsInfo,
        wifiId,
        wifiPw,
      ];
}
