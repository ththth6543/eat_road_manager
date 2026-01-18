// 영업 신고서 인증 절차
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BusinessRegiAuth extends StatefulWidget {
  const BusinessRegiAuth({super.key});

  @override
  State<BusinessRegiAuth> createState() => _BusinessRegiAuthState();
}

class _BusinessRegiAuthState extends State<BusinessRegiAuth> {
  final TextEditingController bNoController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  /* test
  사업자 번호 = 8418702958
  대표자명 = 김영직
  등록일 = 20240401
   */

  bool _isSuccess = false;

  Future<void> verifyBusiness(String bNo, String startDt, String pName) async {
    if (bNo.length != 10 || startDt.length != 8 || pName.isEmpty) {
      _showErrorDialog(context, "입력 형식이 올바르지 않습니다.");
      return;
    }
    const String apiKey =
        "a617c3698289dd11096cacae64771157558120cdfe45009dacd32f5434b00f1b"; // 공공데이터포털에서 발급받은 인코딩 키
    const String url =
        "https://api.odcloud.kr/api/nts-businessman/v1/validate?serviceKey=$apiKey";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "businesses": [
            {
              "b_no": bNo, // 사업자번호 (10자리 숫자만)
              "start_dt": startDt, // 개업일자 (YYYYMMDD)
              "p_nm": pName, // 대표자성명
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['data'][0]['valid'] == '01') {
          debugPrint("인증 성공: 유효한 사업자입니다.");
          setState(() {
            _isSuccess = true;
          });
        } else {
          debugPrint("${result['status_code']} 인증 실패: 정보를 다시 확인하세요.");
          if (mounted) {
            _showErrorDialog(context, '등록된 정보와 일치하지 않습니다. 입력한 내용을 다시 확인해 주세요.');
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text("확인", style: TextStyle(color: Colors.blueAccent),),
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
          borderSide: BorderSide(
            color: Colors.blueAccent,
            width: 3.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.red.withAlpha(180),
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.red,
            width: 3.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const successMessage = "인증성공: 유효한 사업자 입니다";
    return Scaffold(
      appBar: AppBar(title: Text("사업자등록번호 인증")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField('사업자등록번호 (- 제외)', bNoController, TextInputType.number),
            SizedBox(height: 12,),
            buildTextField('개업일자 (예: 20230101)', dateController, TextInputType.number),
            SizedBox(height: 12,),
            buildTextField('대표자 성명', nameController, TextInputType.text),
            SizedBox(height: 12,),
            Text(
              _isSuccess ? successMessage : "",
              style: TextStyle(color: Colors.green),
            ),
            SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
                onPressed: () {
                  verifyBusiness(
                    bNoController.text,
                    dateController.text,
                    nameController.text,
                  );
                },
                child: Text("인증하기"),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.90,
        height: 50,
        child: ElevatedButton(
          onPressed: (){
            if(_isSuccess){
              debugPrint("success");
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSuccess ? Colors.blueAccent : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text('다음 단계', style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      ),
    );
  }
}
