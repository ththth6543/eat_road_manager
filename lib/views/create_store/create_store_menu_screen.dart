import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/create_store_menu_viewmodel.dart';
import 'create_store_marker_screen.dart';

class CreateStoreMenuScreen extends StatefulWidget {
  final String storeId;

  const CreateStoreMenuScreen({super.key, required this.storeId});

  @override
  State<CreateStoreMenuScreen> createState() => _CreateStoreMenuScreenState();
}

class _CreateStoreMenuScreenState extends State<CreateStoreMenuScreen> {
  late final CreateStoreMenuViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CreateStoreMenuViewModel(storeId: widget.storeId);
    _viewModel.loadExistingMenus();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final success = await _viewModel.saveAllMenus();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('메뉴가 성공적으로 저장되었습니다!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedSm),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CreateStoreMarkerScreen(storeId: widget.storeId),
        ),
      );
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

  Future<void> _confirmRemoveMenuItem(int index) async {
    final item = _viewModel.menuItems[index];
    final hasContent =
        item.nameController.text.trim().isNotEmpty ||
        item.priceController.text.trim().isNotEmpty ||
        item.hasImage;

    if (!hasContent) {
      _viewModel.removeMenuItem(index);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
        title: const Text('메뉴 삭제', style: AppTypography.titleLarge),
        content: Text(
          '${item.nameController.text.trim().isNotEmpty ? "'${item.nameController.text.trim()}'" : "${index + 1}번째"} 메뉴를 삭제하시겠습니까?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소', style: TextStyle(color: AppColors.gray600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(72, 38),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _viewModel.removeMenuItem(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('메뉴 등록', style: AppTypography.titleLarge),
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
              '2단계 / 4단계',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final menuItems = _viewModel.menuItems;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // 1. 가이드 배너
                  _buildGuideBanner(),
                  AppSpacing.gapH16,

                  // 2. 메뉴 카드 리스트
                  for (int index = 0; index < menuItems.length; index++) ...[
                    _buildMenuCard(index, menuItems[index], menuItems.length),
                    AppSpacing.gapH16,
                  ],

                  // 3. 메뉴 추가하기 버튼
                  _buildAddMenuButton(),
                  AppSpacing.gapH32,
                ],
              ),
              if (_viewModel.isSaving)
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

  /// 상단 가이드 팁 배너
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
            Icons.lightbulb_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '대표 메뉴를 등록해 보세요!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '선명한 음식 사진과 정성스런 설명을 함께 등록하면 손님들의 주문과 방문 확률이 높아집니다.',
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

  /// 단일 메뉴 카드
  Widget _buildMenuCard(int index, MenuFormItem item, int totalCount) {
    final imageProvider = item.imageProvider;
    final isFirst = index == 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [AppColors.softShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 헤더 (메뉴 순번, 대표 뱃지, 삭제 버튼)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: AppSpacing.roundedSm,
                    ),
                    child: Text(
                      '메뉴 ${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray800,
                      ),
                    ),
                  ),
                  if (isFirst) ...[
                    AppSpacing.gapW8,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      child: const Text(
                        '대표',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (totalCount > 1)
                InkWell(
                  onTap: () => _confirmRemoveMenuItem(index),
                  borderRadius: AppSpacing.roundedFull,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.gray500,
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.gapH16,

          // 이미지 및 기본 정보 (메뉴명, 가격)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사진 업로더
              _buildImageUploader(index, item, imageProvider),
              AppSpacing.gapW16,

              // 입력 필드 (메뉴 이름, 가격)
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: item.nameController,
                      style: AppTypography.titleSmall,
                      decoration: const InputDecoration(
                        labelText: '메뉴명 *',
                        hintText: '예: 비법 떡볶이',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    AppSpacing.gapH12,
                    TextFormField(
                      controller: item.priceController,
                      style: AppTypography.titleSmall,
                      decoration: const InputDecoration(
                        labelText: '가격 *',
                        hintText: '0',
                        suffixText: '원',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,

          // 메뉴 설명 입력 필드
          TextFormField(
            controller: item.descriptionController,
            style: AppTypography.bodyMedium,
            decoration: const InputDecoration(
              labelText: '메뉴 설명 (선택)',
              hintText: '메뉴의 특징, 주재료, 조리 방식을 간단히 적어주세요.',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  /// 사진 업로더 위젯
  Widget _buildImageUploader(
    int index,
    MenuFormItem item,
    ImageProvider? imageProvider,
  ) {
    const double size = 104;

    if (imageProvider != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: AppSpacing.roundedMd,
              border: Border.all(color: AppColors.border, width: 1.0),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          // 사진 변경 오버레이 버튼
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: InkWell(
              onTap: () => _viewModel.pickImage(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: const Text(
                  '변경',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // 사진 삭제 원형 X 버튼
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () => _viewModel.removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.gray800,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: () => _viewModel.pickImage(index),
      borderRadius: AppSpacing.roundedMd,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 28, color: AppColors.primary),
            SizedBox(height: 6),
            Text(
              '사진 추가',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메뉴 추가하기 버튼
  Widget _buildAddMenuButton() {
    return InkWell(
      onTap: _viewModel.addMenuItem,
      borderRadius: AppSpacing.roundedLg,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primarySubtle,
          borderRadius: AppSpacing.roundedLg,
          border: Border.all(color: AppColors.primary300, width: 1.2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              size: 20,
              color: AppColors.primaryDark,
            ),
            SizedBox(width: 8),
            Text(
              '새 메뉴 추가하기',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
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
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final count = _viewModel.validMenuCount;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (count > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '작성 완료된 메뉴',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.gray600,
                          ),
                        ),
                        Text(
                          '$count개',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ElevatedButton(
                  onPressed: _viewModel.isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.roundedMd,
                    ),
                    elevation: 0,
                  ),
                  child: _viewModel.isSaving
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
                            Text(
                              '메뉴 저장 후 다음 단계로',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Backward compatibility alias
typedef CreateStoreMenu = CreateStoreMenuScreen;
