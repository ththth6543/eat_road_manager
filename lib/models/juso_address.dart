class JusoAddress {
  final String roadAddr; // 전체 도로명 주소
  final String jibunAddr; // 지번 주소
  final String siNm; // 시도명
  final String sggNm; // 시군구명
  final String emdNm; // 읍면동명
  final String liNm; // 법정리명
  final String bdMgtSn; // 건물 관리 번호
  final double? latitude; // 위도 (y)
  final double? longitude; // 경도 (x)

  JusoAddress({
    required this.roadAddr,
    required this.jibunAddr,
    required this.siNm,
    required this.sggNm,
    required this.emdNm,
    required this.liNm,
    required this.bdMgtSn,
    this.latitude,
    this.longitude,
  });

  factory JusoAddress.fromJson(Map<String, dynamic> json) {
    return JusoAddress(
      roadAddr: json['roadAddr'] ?? '',
      jibunAddr: json['jibunAddr'] ?? '',
      siNm: json['siNm'] ?? '',
      sggNm: json['sggNm'] ?? '',
      emdNm: json['emdNm'] ?? '',
      liNm: json['liNm'] ?? '',
      bdMgtSn: json['bdMgtSn'] ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roadAddr': roadAddr,
      'jibunAddr': jibunAddr,
      'siNm': siNm,
      'sggNm': sggNm,
      'emdNm': emdNm,
      'liNm': liNm,
      'bdMgtSn': bdMgtSn,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}

// Alias for Juso
typedef Juso = JusoAddress;
