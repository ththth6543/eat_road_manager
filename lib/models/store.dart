class Store {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? bdMgtSn;
  final String? roadAddress;

  const Store({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.bdMgtSn,
    this.roadAddress,
  });

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['store_id'].toString(),
      name: map['name'] ?? '이름 없음',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      bdMgtSn: map['bd_mgt_sn'],
      roadAddress: map['road_addr'] ?? map['road_address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'store_id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'bd_mgt_sn': bdMgtSn,
      'road_addr': roadAddress,
    };
  }
}
