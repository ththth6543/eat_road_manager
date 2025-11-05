import 'package:equatable/equatable.dart';

class StoreInfo {
  //필수 값
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
  final List<String>? imageUrls;
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

    this.imageUrls = const [],
    this.detailAddr,
    this.lastOrderTime,
    this.storePhoneNumber,
    this.snsUrl,
    this.parkingInfo,
    this.seatsInfo,
    this.wifiId,
    this.wifiPw,
  });

  //factory 생성자
  factory StoreInfo.fromMap(Map<String, dynamic> info) {
    return StoreInfo(
      name: info['name'] ?? '이름 없음',
      description: info['description'] ?? '가게 소개 작성을 깜박하셨나 봅니다',
      roadAddr: info['roadAddr'] ?? '주소 정보 없음',
      openTime: info['openTime'] ?? '??:??',
      closeTime: info['closeTime'] ?? '??:??',
      businessDays:
      (info['businessDays'] as List<dynamic>?)?.cast<String>() ?? [],
      isReservationAvailable: info['isReservationAvailable'] ?? false,
      isParkingAvailable: info['isParkingAvailable'] ?? false,
      isWifiAvailable: info['isWifiAvailable'] ?? false,
      isTakeoutAvailable: info['isTakeoutAvailable'] ?? false,

      imageUrls: (info['image_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      detailAddr: info['detailAddr'] ?? [],
      lastOrderTime: info['lastOrderTime'] ?? [],
      storePhoneNumber: info['storePhoneNumber'] ?? [],
      snsUrl: info['snsUrl'] ?? [],
      parkingInfo: info['parkingInfo'] ?? [],
      seatsInfo: info['seatsInfo'] ?? [],
      wifiId: info['wifiId'] ?? [],
      wifiPw: info['wifiPw'] ?? [],
    );
  }

  // equatable을 위한 props 설정
  List<Object?> get props => [
    description,
    roadAddr,
    openTime,
    closeTime,
    businessDays,
    isReservationAvailable,
    isParkingAvailable,
    isTakeoutAvailable,
    isWifiAvailable,
    imageUrls,
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