import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
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
  final TextEditingController _openTimeController = TextEditingController(
    text: '09:00',
  );
  final TextEditingController _closeTimeController = TextEditingController(
    text: '21:00',
  );
  final TextEditingController _lastOrderTimeController = TextEditingController(
    text: '20:30',
  );
  final TextEditingController _storePhoneNumberController =
      TextEditingController();
  final TextEditingController _storeSNSController = TextEditingController();
  final TextEditingController _storeParkingController = TextEditingController();
  final TextEditingController _storeSeatsController = TextEditingController();
  final TextEditingController _storeWifiIdController = TextEditingController();
  final TextEditingController _storeWifiPwController = TextEditingController();

  Duration _selectedTime = const Duration(hours: 9);
  late final CreateStoreOthersViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CreateStoreOthersViewModel(storeId: widget.storeId);
    // 기본 평일 + 주말 전체 선택
    _viewModel.selectEveryday();
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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('축하합니다! 가게 등록이 성공적으로 완료되었습니다.')),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedSm),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(_viewModel.errorMessage!)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedSm),
        ),
      );
    }
  }

  void _showTimePickerModal(TextEditingController controller, String title) {
    // 기존 입력된 텍스트에서 Duration 파싱
    final parts = controller.text.split(':');
    if (parts.length == 2) {
      final h = int.tryParse(parts[0]) ?? 9;
      final m = int.tryParse(parts[1]) ?? 0;
      _selectedTime = Duration(hours: h, minutes: m);
    }

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext ctx) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                color: AppColors.gray50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        '취소',
                        style: TextStyle(color: AppColors.gray600),
                      ),
                    ),
                    Text(title, style: AppTypography.titleSmall),
                    TextButton(
                      onPressed: () {
                        controller.text = _formatDuration(_selectedTime);
                        setState(() {});
                        Navigator.of(ctx).pop();
                      },
                      child: const Text(
                        '선택 완료',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  minuteInterval: 5,
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: _selectedTime,
                  onTimerDurationChanged: (Duration newTime) {
                    _selectedTime = newTime;
                  },
                ),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('운영 및 편의 정보', style: AppTypography.titleLarge),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppSpacing.roundedFull,
              border: Border.all(color: AppColors.primary100),
            ),
            child: const Text(
              '4단계 / 4단계 (마지막)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Stack(
            children: [
              ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // 상단 안내 배너
                  _buildGuideBanner(),
                  AppSpacing.gapH16,

                  // 1. 영업 일정 & 시간 카드
                  _buildSectionCard(
                    title: '영업 일정 및 시간',
                    icon: Icons.access_time_rounded,
                    child: _buildOperatingHoursSection(),
                  ),
                  AppSpacing.gapH16,

                  // 2. 매장 연락처 & SNS 카드
                  _buildSectionCard(
                    title: '매장 연락처 및 SNS',
                    icon: Icons.contact_phone_outlined,
                    child: _buildContactSection(),
                  ),
                  AppSpacing.gapH16,

                  // 3. 편의 시설 & 서비스 카드
                  _buildSectionCard(
                    title: '편의 시설 및 서비스',
                    icon: Icons.room_service_outlined,
                    child: _buildAmenitiesSection(),
                  ),
                  AppSpacing.gapH16,

                  // 4. 좌석 및 매장 규모 카드
                  _buildSectionCard(
                    title: '좌석 및 매장 규모',
                    icon: Icons.table_restaurant_outlined,
                    child: _buildSeatsSection(),
                  ),
                  AppSpacing.gapH32,
                ],
              ),
              if (_viewModel.isUploading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  /// 상단 가이드 배너
  Widget _buildGuideBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.primary100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.celebration_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '마지막 단계입니다!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '영업시간과 매장 편의정보를 입력하시면 잇로드 지도에 매장이 정식 오픈됩니다.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gray700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 공통 카드
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: const BoxDecoration(boxShadow: [AppColors.softShadow]),
      child: Material(
        color: AppColors.cardBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedLg,
          side: BorderSide(color: AppColors.border, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: AppSpacing.roundedSm,
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 18),
                  ),
                  AppSpacing.gapW8,
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  /// 1. 영업 일정 및 시간 섹션
  Widget _buildOperatingHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 영업 요일 선택 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '영업 요일 *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                _buildQuickPresetButton(
                  '매일',
                  _viewModel.isEverydaySelected,
                  _viewModel.selectEveryday,
                ),
                const SizedBox(width: 4),
                _buildQuickPresetButton(
                  '평일만',
                  _viewModel.isWeekdaysSelected,
                  _viewModel.selectWeekdays,
                ),
                const SizedBox(width: 4),
                _buildQuickPresetButton(
                  '주말만',
                  _viewModel.isWeekendsSelected,
                  _viewModel.selectWeekends,
                ),
              ],
            ),
          ],
        ),
        AppSpacing.gapH8,

        // 요일 칩들 (월 ~ 일)
        Row(
          children: _viewModel.days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isSelected = _viewModel.selectedDays[index];

            return Expanded(
              child: GestureDetector(
                onTap: () => _viewModel.toggleDay(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.gray100,
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : AppColors.gray700,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        AppSpacing.gapH20,

        // 영업 시간 (시작 ~ 마감)
        const Text(
          '영업 시간 *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.gapH8,
        Row(
          children: [
            Expanded(
              child: _buildTimePickerBox(
                controller: _openTimeController,
                label: '오픈 시간',
                onTap: () =>
                    _showTimePickerModal(_openTimeController, '오픈 시간 설정'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '~',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray500,
                ),
              ),
            ),
            Expanded(
              child: _buildTimePickerBox(
                controller: _closeTimeController,
                label: '마감 시간',
                onTap: () =>
                    _showTimePickerModal(_closeTimeController, '마감 시간 설정'),
              ),
            ),
          ],
        ),
        AppSpacing.gapH16,

        // 라스트 오더 스위치
        Material(
          color: AppColors.gray50,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedMd,
            side: BorderSide(color: AppColors.borderLight),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text(
                  '라스트 오더 설정',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  '마감 전 마지막 주문 가능 시간',
                  style: TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
                activeTrackColor: AppColors.primary,
                value: _viewModel.isLastOrderAvailable,
                onChanged: (val) => _viewModel.setLastOrder(val),
              ),
              if (_viewModel.isLastOrderAvailable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Row(
                    children: [
                      const Text(
                        '라스트 오더 시간:',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimePickerBox(
                          controller: _lastOrderTimeController,
                          label: '주문 마감',
                          onTap: () => _showTimePickerModal(
                            _lastOrderTimeController,
                            '라스트 오더 시간 설정',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 퀵 요일 프리셋 버튼
  Widget _buildQuickPresetButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.roundedXs,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : Colors.transparent,
          borderRadius: AppSpacing.roundedXs,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryDark : AppColors.gray600,
          ),
        ),
      ),
    );
  }

  /// 시간 선택 인풋 박스
  Widget _buildTimePickerBox({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.roundedMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.text.isNotEmpty ? controller.text : '--:--',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.schedule_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 2. 매장 연락처 및 SNS 섹션
  Widget _buildContactSection() {
    return Column(
      children: [
        TextFormField(
          controller: _storePhoneNumberController,
          style: AppTypography.bodyLarge,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: '매장 대표 전화번호',
            hintText: '예: 02-1234-5678 또는 010-1234-5678',
            prefixIcon: Icon(
              Icons.phone_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            isDense: true,
          ),
        ),
        AppSpacing.gapH12,
        TextFormField(
          controller: _storeSNSController,
          style: AppTypography.bodyLarge,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: '인스타그램 또는 SNS 링크 (선택)',
            hintText: '예: instagram.com/my_store',
            prefixIcon: Icon(
              Icons.link_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  /// 3. 편의 시설 및 서비스 섹션
  Widget _buildAmenitiesSection() {
    return Column(
      children: [
        // 예약 가능 스위치
        _buildAmenitySwitch(
          title: '예약 가능',
          subtitle: '방문 전 사전 예약 접수 가능 여부',
          icon: Icons.event_available_rounded,
          value: _viewModel.isReservationAvailable,
          onChanged: (val) => _viewModel.setReservation(val),
        ),
        const Divider(height: 1, color: AppColors.borderLight),

        // 포장 가능 스위치
        _buildAmenitySwitch(
          title: '포장(테이크아웃) 가능',
          subtitle: '매장 방문 포장 주문 가능 여부',
          icon: Icons.takeout_dining_rounded,
          value: _viewModel.isTakeoutAvailable,
          onChanged: (val) => _viewModel.setTakeout(val),
        ),
        const Divider(height: 1, color: AppColors.borderLight),

        // 주차 가능 스위치 & 인풋
        _buildAmenitySwitch(
          title: '주차 가능',
          subtitle: '매장 전용 또는 인근 주차 공간 제공',
          icon: Icons.local_parking_rounded,
          value: _viewModel.isParkingAvailable,
          onChanged: (val) => _viewModel.setParking(val),
        ),
        if (_viewModel.isParkingAvailable)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextFormField(
              controller: _storeParkingController,
              style: AppTypography.bodyMedium,
              decoration: const InputDecoration(
                labelText: '주차 위치 및 안내',
                hintText: '예: 매장 앞 2대 주차 가능, 인근 공영주차장 1시간 지원',
                isDense: true,
              ),
            ),
          ),
        const Divider(height: 1, color: AppColors.borderLight),

        // 매장 Wi-Fi 스위치 & 인풋
        _buildAmenitySwitch(
          title: '무료 Wi-Fi 제공',
          subtitle: '매장 방문 고객용 무선 인터넷',
          icon: Icons.wifi_rounded,
          value: _viewModel.isWifiAvailable,
          onChanged: (val) {
            _viewModel.setWifi(val);
            if (val) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              });
            }
          },
        ),
        if (_viewModel.isWifiAvailable)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _storeWifiIdController,
                    style: AppTypography.bodyMedium,
                    decoration: const InputDecoration(
                      labelText: 'Wi-Fi ID (이름)',
                      hintText: '네트워크 이름',
                      isDense: true,
                    ),
                  ),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: TextFormField(
                    controller: _storeWifiPwController,
                    style: AppTypography.bodyMedium,
                    decoration: const InputDecoration(
                      labelText: '비밀번호(PW)',
                      hintText: '비밀번호',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 편의시설 공통 스위치 타일
  Widget _buildAmenitySwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: SwitchListTile(
        secondary: Icon(
          icon,
          color: value ? AppColors.primary : AppColors.gray500,
          size: 22,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.gray600),
        ),
        activeTrackColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// 4. 좌석 및 매장 규모 섹션
  Widget _buildSeatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _storeSeatsController,
          style: AppTypography.bodyMedium,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '좌석 형태 및 수용 인원',
            hintText:
                '예: 4인 테이블 8개, 2인 테이블 4개, 바 좌석 6석\n총 44석 수용 가능하며 단체석 예약도 가능합니다.',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  /// 하단 고정 액션 바
  Widget _buildBottomActionBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: AppColors.borderLight, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _viewModel.isUploading ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
            elevation: 0,
          ),
          child: _viewModel.isUploading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '가게 등록 완료하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Backward compatibility alias
typedef CreateStoreOthers = CreateStoreOthersScreen;
