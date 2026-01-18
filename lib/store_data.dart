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