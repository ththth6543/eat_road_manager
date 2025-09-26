import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CreateStoreOthers extends StatefulWidget {
  final String storeId;

  const CreateStoreOthers({super.key, required this.storeId});

  @override
  State<CreateStoreOthers> createState() => _CreateStoreOthersState();
}

class _CreateStoreOthersState extends State<CreateStoreOthers> {
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();
  final TextEditingController _storePhoneNumberController =
      TextEditingController();
  final TextEditingController _storeSNSController = TextEditingController();
  final TextEditingController _storeParkingController = TextEditingController();
  final TextEditingController _storeSeatsController = TextEditingController();
  final TextEditingController _storeWifiIdController = TextEditingController();
  final TextEditingController _storeWifiPwController = TextEditingController();

  // 영업일 저장
  List<String> _days = ['월', '화', '수', '목', '금', '토', '일'];
  List<bool> _selectedDays = [false, false, false, false, false, false, false];

  // 영업시간 저장
  Duration _selectedTime = Duration.zero;

  //예약 가능 여부
  bool _isReservationAvailable = false;

  // 주차 가능 여부
  bool _isParkingAvailable = false;

  // 음식 포장 가능 여부
  bool _isTakeoutAvailable = false;

  // wi-fi 사용 가능 여부
  bool _isWifiAvailable = false;

  void _setOpenAndCloseTime(TextEditingController controller) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: CupertinoTimerPicker(
            minuteInterval: 5,
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: _selectedTime,
            onTimerDurationChanged: (Duration newTime) {
              setState(() {
                _selectedTime = newTime;
                controller.text = _formatDuration(_selectedTime);
              });
            },
          ),
        );
      },
    );
  }

  // Duration을 'HH:mm' 형식의 String으로 반환
  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  // 제목 만들기
  Widget _makeTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  @override
  void dispose() {
    // Controller dispose 할 것
    super.dispose();
  }

  //영업일을 선택하는 UI
  Widget _makeOpenDate() {
    // Row와 Expanded를 사용하여 화면 크기에 관계없이 모든 요일이 표시되도록 수정
    return Row(
      children: _days.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final isSelected = _selectedDays[index];

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDays[index] = !_selectedDays[index];
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2), // 좌우 여백 살짝 조정
              padding: const EdgeInsets.symmetric(vertical: 10.0), // 수직 패딩
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.grey[400]!,
                ),
              ),
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("기타 사항들")),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 82),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _makeTitle("영업 시간"),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.access_time),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: TextField(
                    controller: _openTimeController,
                    style: TextStyle(fontSize: 20),
                    readOnly: true,
                    onTap: () => _setOpenAndCloseTime(_openTimeController),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "시작 시간",
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text("~", style: TextStyle(fontSize: 30)),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: TextField(
                    controller: _closeTimeController,
                    style: TextStyle(fontSize: 20),
                    readOnly: true,
                    onTap: () => _setOpenAndCloseTime(_closeTimeController),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "마감 시간",
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),
            _makeTitle("영업일"),
            SizedBox(height: 10),
            SizedBox(height: 50, child: _makeOpenDate()),

            SizedBox(height: 30),
            _makeTitle("전화번호"),

            SizedBox(height: 10),
            TextField(
              controller: _storePhoneNumberController,
              style: TextStyle(fontSize: 20),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "전화번호",
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: CheckboxListTile(
                title: Text(
                  "예약 가능 여부",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                activeColor: Colors.blueAccent,
                controlAffinity: ListTileControlAffinity.trailing,
                value: _isReservationAvailable,
                contentPadding: EdgeInsets.only(left: 0),
                onChanged: (value) {
                  setState(() {
                    _isReservationAvailable = value!;
                  });
                },
              ),
            ),

            SizedBox(height: 30),
            _makeTitle("SNS 주소"),
            SizedBox(height: 10),
            TextField(
              controller: _storeSNSController,
              style: TextStyle(fontSize: 20),
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "SNS 주소",
              ),
            ),

            SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: CheckboxListTile(
                title: Text(
                  "주차 가능 여부",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: Colors.blueAccent,
                selectedTileColor: Colors.blue,
                contentPadding: EdgeInsets.only(left: 0),
                value: _isParkingAvailable,
                onChanged: (value) {
                  setState(() {
                    _isParkingAvailable = value!;
                  });
                },
              ),
            ),
            if (_isParkingAvailable)
              TextField(
                controller: _storeParkingController,
                style: TextStyle(fontSize: 20),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "주차 위치를 대략적으로 적어주세요",
                ),
              ),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: CheckboxListTile(
                title: Text(
                  "포장 가능 여부",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                activeColor: Colors.blueAccent,
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.only(left: 0),
                value: _isTakeoutAvailable,
                onChanged: (value) {
                  setState(() {
                    _isTakeoutAvailable = value!;
                  });
                },
              ),
            ),

            SizedBox(height: 20,),
            _makeTitle('좌석 형태 및 수용 규모(단체석 여부)'),
            SizedBox(height: 10,),
            TextField(
              controller: _storeSeatsController,
              style: TextStyle(fontSize: 20),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "좌석 형태(테이블, 바, 룸, 좌식 등), 수용 인원을 알려주세요",
                labelStyle: TextStyle(fontSize: 15)
              ),
            ),
            SizedBox(height: 10,),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: CheckboxListTile(
                title: Text(
                  "매장 Wi-Fi 여부",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                activeColor: Colors.blueAccent,
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.only(left: 0,),
                value: _isWifiAvailable,
                onChanged: (value) {
                  setState(() {
                    _isWifiAvailable = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      // 완료 버튼
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 50,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            '작성 완료',
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
