class JusoAddress {
  final String roadAddr; // 전체 도로명 주소
  final String jibunAddr; // 지번 주소
  final String siNm; // 시도명
  final String sggNm; // 시군구명
  final String emdNm; // 읍면동명
  final String liNm; // 법정리명
  final String bdMgtSn; // 건물 관리 번호

  JusoAddress({
    required this.roadAddr,
    required this.jibunAddr,
    required this.siNm,
    required this.sggNm,
    required this.emdNm,
    required this.liNm,
    required this.bdMgtSn,
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
    };
  }
}

// Alias for Juso
typedef Juso = JusoAddress;
