import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusinessLicenseAuth extends StatefulWidget {
  const BusinessLicenseAuth({super.key});

  @override
  State<BusinessLicenseAuth> createState() => _BusinessLicenseAuthState();
}

class _BusinessLicenseAuthState extends State<BusinessLicenseAuth> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  //식품의약품안전처의 '식품접객업정보 오픈 api'사용
  Future<void> verifyLicense(String lcnsNo) async {
    if (lcnsNo.isEmpty) {
      _showErrorDialog(context, "상호명을 입력해주세요.");
      return;
    }

    setState(() {
      _isLoading = true;
    });
    const String apiKey = "1521f6b9ce8d4ed29702"; // 식품의약품안전처에서 발급받은 인증 키
    final String url =
        'http://openapi.foodsafetykorea.go.kr/api/$apiKey/I1200/json/1/20/LCNS_NO=$lcnsNo';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 데이터 존재 여부 체크
        if (data['I1200'] != null && data['I1200']['total_count'] != '0') {
          setState(() {
            _searchResults = data['I1200']['row'];
          });
        } else {
          setState(() => _searchResults = []);
          debugPrint('검색 실패: 번호를 다시 확인하세요.');
          if (mounted) {
            _showErrorDialog(context, '검색 결과가 없습니다. 번호를 다시 확인해주세요.');
          }
        }
      } else {
        debugPrint("서버 에러: ${response.statusCode}");
        if (mounted) {
          _showErrorDialog(context, "서버 통신 오류가 발생했습니다. 잠시 후 다시 시도해 주세요");
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, "네트워크 연결 상태를 확인해 주세요");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("인증 실패", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
            child: Text("확인", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType,
  ) {
    return TextField(
      controller: controller,
      cursorColor: Colors.black,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.blueAccent.withAlpha(180),
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blueAccent, width: 3.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.red.withAlpha(180), width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.red, width: 3.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('영업 허가증 인증')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField('인허가 번호 (- 제외)', _searchController, TextInputType.number),

            SizedBox(height: 12),

            // 2. 인증 버튼 (네모 스타일, 라디우스 5)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : () => verifyLicense(_searchController.text),
              child: _isLoading
                  ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text("검색 시작", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            SizedBox(height: 25),
            Text("검색 결과", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            Divider(height: 20),

            // 3. 검색 결과 리스트
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(child: Text("인증할 식당의 이름을 검색해 주세요."))
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (ctx, index) {
                  final item = _searchResults[index];
                  //폐업일자 가져오기(null 처리)
                  final String? entDtRaw = item['CLSBIZ_DT'];
                  final bool isClosed = entDtRaw != null && entDtRaw.trim().isNotEmpty;
                  final bool isLive = !isClosed;

                  return Card(
                    elevation: 0,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      title: Text(item['BSSH_NM'] ?? '상호명 미기재', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(item['LOCP_ADDR'] ?? "주소 정보 없음", maxLines: 2, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4),
                          Text("${item['INDUTY_NM'] ?? '업종 미분류'} | ${item['PRSDNT_NM'] ?? '대표자 없음'}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                      trailing: Text(
                        isLive ? '영업중' : '폐업',
                        style: TextStyle(
                          color: isLive ? Colors.blue : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: isLive ? () {
                        // [다음 단계] 사장님 소유권 확인을 위한 추가 액션 (예: 사진 업로드)
                        print("${item['BSSH_NM']} 선택됨");
                      } : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}