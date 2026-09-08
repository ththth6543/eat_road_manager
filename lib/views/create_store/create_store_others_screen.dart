import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/create_store_others_viewmodel.dart';

class CreateStoreOthersScreen extends StatefulWidget {
  final String storeId;

  const CreateStoreOthersScreen({super.key, required this.storeId});

  @override
  State<CreateStoreOthersScreen> createState() =>
      _CreateStoreOthersScreenState();
}

class _CreateStoreOthersScreenState extends State<CreateStoreOthersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();
  final TextEditingController _lastOrderTimeController =
      TextEditingController();
  final TextEditingController _storePhoneNumberController =
      TextEditingController();
  final TextEditingController _storeSNSController = TextEditingController();
  final TextEditingController _storeParkingController =
      TextEditingController();
  final TextEditingController _storeSeatsController = TextEditingController();
  final TextEditingController _storeWifiIdController = TextEditingController();
  final TextEditingController _storeWifiPwController = TextEditingController();

  Duration _selectedTime = Duration.zero;
  late final CreateStoreOthersViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CreateStoreOthersViewModel(storeId: widget.storeId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _storePhoneNumberController.dispose();
    _storeSNSController.dispose();
    _storeParkingController.dispose();
    _storeSeatsController.dispose();
    _storeWifiIdController.dispose();
    _storeWifiPwController.dispose();
    _lastOrderTimeController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final success = await _viewModel.saveStoreOthers(
      openTime: _openTimeController.text,
      closeTime: _closeTimeController.text,
      lastOrderTime: _lastOrderTimeController.text,
      storePhoneNumber: _storePhoneNumberController.text,
      snsUrl: _storeSNSController.text,
      parkingInfo: _storeParkingController.text,
      seatsInfo: _storeSeatsController.text,
      wifiId: _storeWifiIdController.text,
      wifiPw: _storeWifiPwController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가게 정보가 저장되었습니다.')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage!)),
      );
    }
  }

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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Widget _makeTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _makeOpenDate() {
    return Row(
      children: _viewModel.days.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final isSelected = _viewModel.selectedDays[index];

        return Expanded(
          child: GestureDetector(
            onTap: () => _viewModel.toggleDay(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentBlue : Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: isSelected ? AppColors.accentBlue : Colors.grey[400]!,
                ),
              ),
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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
      appBar: AppBar(title: const Text("기타 사항들")),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 82),
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _makeTitle("영업 시간"),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _openTimeController,
                        style: const TextStyle(fontSize: 20),
                        readOnly: true,
                        onTap: () => _setOpenAndCloseTime(_openTimeController),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "시작 시간",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text("~", style: TextStyle(fontSize: 30)),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _closeTimeController,
                        style: const TextStyle(fontSize: 20),
                        readOnly: true,
                        onTap: () =>
                            _setOpenAndCloseTime(_closeTimeController),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "마감 시간",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: CheckboxListTile(
                    title: const Text(
                      "주문 마감 시간(라스트 오더)",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    activeColor: AppColors.accentBlue,
                    contentPadding: EdgeInsets.zero,
                    value: _viewModel.isLastOrderAvailable,
                    onChanged: (val) =>
                        _viewModel.setLastOrder(val ?? false),
                  ),
                ),
                if (_viewModel.isLastOrderAvailable) ...[
                  const SizedBox(height: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: _lastOrderTimeController,
                      style: const TextStyle(fontSize: 20),
                      readOnly: true,
                      onTap: () =>
                          _setOpenAndCloseTime(_lastOrderTimeController),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "라스트 오더",
                      ),
                    ),
                  ),
                ],
                const Divider(height: 20),
                const SizedBox(height: 15),
                _makeTitle("영업일"),
                const SizedBox(height: 10),
                SizedBox(height: 50, child: _makeOpenDate()),
                const Divider(height: 50),
                _makeTitle("전화번호"),
                const SizedBox(height: 10),
                TextField(
                  controller: _storePhoneNumberController,
                  style: const TextStyle(fontSize: 20),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "전화번호",
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: CheckboxListTile(
                    title: const Text(
                      "예약 가능 여부",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    activeColor: AppColors.accentBlue,
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: _viewModel.isReservationAvailable,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) =>
                        _viewModel.setReservation(val ?? false),
                  ),
                ),
                const Divider(height: 40),
                _makeTitle("SNS 주소"),
                const SizedBox(height: 10),
                TextField(
                  controller: _storeSNSController,
                  style: const TextStyle(fontSize: 20),
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "SNS 주소",
                  ),
                ),
                const Divider(height: 40),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: CheckboxListTile(
                    title: const Text(
                      "주차 가능 여부",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    activeColor: AppColors.accentBlue,
                    contentPadding: EdgeInsets.zero,
                    value: _viewModel.isParkingAvailable,
                    onChanged: (val) =>
                        _viewModel.setParking(val ?? false),
                  ),
                ),
                if (_viewModel.isParkingAvailable) ...[
                  TextField(
                    controller: _storeParkingController,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "주차 위치를 대략적으로 적어주세요",
                    ),
                  ),
                ],
                const Divider(height: 40),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: CheckboxListTile(
                    title: const Text(
                      "포장 가능 여부",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    activeColor: AppColors.accentBlue,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: EdgeInsets.zero,
                    value: _viewModel.isTakeoutAvailable,
                    onChanged: (val) =>
                        _viewModel.setTakeout(val ?? false),
                  ),
                ),
                const Divider(height: 40),
                _makeTitle('좌석 형태 및 수용 규모(단체석 여부)'),
                const SizedBox(height: 10),
                TextField(
                  controller: _storeSeatsController,
                  style: const TextStyle(fontSize: 20),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "좌석 형태(테이블, 룸 등), 수용 인원을 자세히 적어주세요",
                    labelStyle: TextStyle(fontSize: 15),
                  ),
                ),
                const Divider(height: 50),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: CheckboxListTile(
                    title: const Text(
                      "매장 Wi-Fi 여부",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    activeColor: AppColors.accentBlue,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: EdgeInsets.zero,
                    value: _viewModel.isWifiAvailable,
                    onChanged: (val) {
                      _viewModel.setWifi(val ?? false);
                      if (val == true) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                          );
                        });
                      }
                    },
                  ),
                ),
                if (_viewModel.isWifiAvailable) ...[
                  TextField(
                    controller: _storeWifiIdController,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Wi-Fi 이름(ID)",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _storeWifiPwController,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Wi-Fi 비밀번호(PW)",
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _viewModel.isUploading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _viewModel.isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "저장하기",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Backward compatibility alias
typedef CreateStoreOthers = CreateStoreOthersScreen;
