import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Juso 모델: API 응답을 파싱하고 Map으로 변환하는 기능을 포함
class Juso {
  final String roadAddr; // 전체 도로명 주소
  final String jibunAddr; // 지번 주소
  // final String admCd; // 행정구역코드
  // final String rnMgtSn; // 도로명코드
  // final String udrtYn; // 지하여부
  // final String buldMnnm; // 건물본번
  // final String buldSlno; // 건물부번
  final String siNm; // 시도명
  final String sggNm; // 시군구명
  final String emdNm; // 읍면동명
  final String liNm; // 법정리명

  Juso({
    required this.roadAddr,
    required this.jibunAddr,
    // required this.admCd,
    // required this.rnMgtSn,
    // required this.udrtYn,
    // required this.buldMnnm,
    // required this.buldSlno,
    required this.siNm,
    required this.sggNm,
    required this.emdNm,
    required this.liNm,
  });

  factory Juso.fromJson(Map<String, dynamic> json) {
    return Juso(
      roadAddr: json['roadAddr'] ?? '',
      jibunAddr: json['jibunAddr'] ?? '',
      // admCd: json['admCd'] ?? '',
      // rnMgtSn: json['rnMgtSn'] ?? '',
      // udrtYn: json['udrtYn'] ?? '',
      // buldMnnm: json['buldMnnm'] ?? '',
      // buldSlno: json['buldSlno'] ?? '',
      siNm: json['siNm'] ?? '',
      sggNm: json['sggNm'] ?? '',
      emdNm: json['emdNm'] ?? '',
      liNm: json['liNm'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roadAddr': roadAddr,
      'jibunAddr': jibunAddr,
      //'admCd': admCd,
      //'rnMgtSn': rnMgtSn,
      //'udrtYn': udrtYn,
      //'buldMnnm': buldMnnm,
      //'buldSlno': buldSlno,
      'siNm': siNm,
      'sggNm': sggNm,
      'emdNm': emdNm,
      'liNm': liNm,
    };
  }
}

class AddressSearchView extends StatefulWidget {
  const AddressSearchView({super.key});

  @override
  State<AddressSearchView> createState() => _AddressSearchViewState();
}

class _AddressSearchViewState extends State<AddressSearchView> {
  final _searchController = TextEditingController();
  final _detailAddressController = TextEditingController();

  List<Juso> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Juso? _selectedJuso;

  Future<void> _searchAddress(String keyword) async {
    if (keyword.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _results = [];
    });

    const String confmKey = 'devU01TX0FVVEgyMDI1MDkyMDAzMDQ1MzExNjIzOTY=';
    const String apiUrl = 'https://business.juso.go.kr/addrlink/addrLinkApi.do';
    final String url =
        '$apiUrl?confmKey=$confmKey&currentPage=1&countPerPage=100&keyword=${Uri.encodeComponent(keyword)}&resultType=json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results']['juso'] != null) {
          final List<dynamic> jusoList = data['results']['juso'];
          setState(() {
            _results = jusoList.map((j) => Juso.fromJson(j)).toList();
          });
        }
      } else {
        debugPrint('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSearchUi() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '도로명, 건물명, 지번으로 검색',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _searchAddress,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _searchAddress(_searchController.text),
                child: const Text('검색'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
                  ? Center(
                      child: _hasSearched
                          ? const Text('검색 결과가 없습니다.')
                          : const Text('주소를 검색하세요.'),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final juso = _results[index];
                        return ListTile(
                          title: Text(juso.roadAddr),
                          subtitle: Text('[지번] ${juso.jibunAddr}'),
                          onTap: () {
                            setState(() {
                              _selectedJuso = juso;
                            });
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildDetailUi() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('기본 주소', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(_selectedJuso!.roadAddr, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          TextField(
            controller: _detailAddressController,
            decoration: const InputDecoration(
              labelText: '상세 주소',
              hintText: '상세 주소를 입력하세요 (예: 101동 101호)',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final addressData = _selectedJuso!.toJson();
                addressData['detailAddress'] = _detailAddressController.text.trim();
                // 전체 주소 데이터를 Map 형태로 반환
                Navigator.pop(context, addressData);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('주소 입력 완료'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedJuso == null ? '주소 검색' : '상세 주소 입력'),
        leading: _selectedJuso != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedJuso = null;
                    _detailAddressController.clear();
                  });
                },
              )
            : null,
      ),
      body: _selectedJuso == null ? _buildSearchUi() : _buildDetailUi(),
    );
  }
}
