import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/juso_address.dart';
import '../../viewmodels/business_verification_viewmodel.dart';

class AddressSearchView extends StatefulWidget {
  const AddressSearchView({super.key});

  @override
  State<AddressSearchView> createState() => _AddressSearchViewState();
}

class _AddressSearchViewState extends State<AddressSearchView> {
  final _searchController = TextEditingController();
  final _detailAddressController = TextEditingController();
  late final AddressSearchViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddressSearchViewModel();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _detailAddressController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _viewModel.search(query);
    }
  }

  Widget _buildSearchUi() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: AppTypography.bodyLarge,
                  decoration: InputDecoration(
                    hintText: '도로명, 건물명, 지번으로 검색',
                    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel_rounded, size: 18, color: AppColors.gray400),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.gray100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.roundedMd,
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppSpacing.roundedMd,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppSpacing.roundedMd,
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _handleSearch(),
                ),
              ),
              AppSpacing.gapW8,
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    elevation: 0,
                  ),
                  child: const Text('검색', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderLight),
        Expanded(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.isLoading) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 14),
                      Text('주소를 검색하는 중입니다...', style: TextStyle(color: AppColors.gray600, fontSize: 13)),
                    ],
                  ),
                );
              }

              if (_viewModel.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 44),
                        const SizedBox(height: 12),
                        Text(
                          _viewModel.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.gray800, fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (_viewModel.results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _viewModel.hasSearched ? Icons.search_off_rounded : Icons.location_on_outlined,
                        size: 48,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _viewModel.hasSearched ? '검색 결과가 없습니다.' : '도로명, 건물명 또는 지번을 입력하세요.',
                        style: const TextStyle(color: AppColors.gray600, fontSize: 15),
                      ),
                      if (_viewModel.hasSearched) ...[
                        const SizedBox(height: 4),
                        const Text(
                          '검색어의 철자가 정확한지 확인해 주세요.',
                          style: TextStyle(color: AppColors.gray500, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _viewModel.results.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, index) {
                  final juso = _viewModel.results[index];
                  return InkWell(
                    onTap: () => _viewModel.selectJuso(juso),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      margin: const EdgeInsets.only(top: 1, right: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySubtle,
                                        borderRadius: AppSpacing.roundedXs,
                                        border: Border.all(color: AppColors.primary100),
                                      ),
                                      child: const Text(
                                        '도로명',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        juso.roadAddr,
                                        style: AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (juso.jibunAddr.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        margin: const EdgeInsets.only(top: 1, right: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.gray100,
                                          borderRadius: AppSpacing.roundedXs,
                                        ),
                                        child: const Text(
                                          '지번',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.gray600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          juso.jibunAddr,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.gray600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.gray400,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailUi(JusoAddress selectedJuso) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppSpacing.roundedMd,
              border: Border.all(color: AppColors.primary100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '선택된 주소',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedJuso.roadAddr,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (selectedJuso.jibunAddr.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '[지번] ${selectedJuso.jibunAddr}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.gray600),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.gapH24,
          Text('상세 주소 입력', style: AppTypography.titleSmall),
          AppSpacing.gapH8,
          TextField(
            controller: _detailAddressController,
            style: AppTypography.bodyLarge,
            decoration: const InputDecoration(
              labelText: '동 / 호수 / 층 / 상세 위치',
              hintText: '예: 101동 101호, 1층',
            ),
            autofocus: true,
          ),
          AppSpacing.gapH32,
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final addressData = selectedJuso.toJson();
                addressData['detailAddr'] = _detailAddressController.text.trim();
                debugPrint('선택된 주소 데이터: ${addressData.toString()}');
                Navigator.pop(context, addressData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
                elevation: 0,
              ),
              child: const Text(
                '주소 입력 완료',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final selectedJuso = _viewModel.selectedJuso;
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            title: Text(
              selectedJuso == null || selectedJuso.roadAddr.isEmpty ? '주소 검색' : '상세 주소 입력',
              style: AppTypography.titleLarge,
            ),
            leading: selectedJuso != null && selectedJuso.roadAddr.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      _viewModel.selectJuso(
                        JusoAddress(
                          roadAddr: '',
                          jibunAddr: '',
                          siNm: '',
                          sggNm: '',
                          emdNm: '',
                          liNm: '',
                          bdMgtSn: '',
                        ),
                      );
                      _detailAddressController.clear();
                    },
                  )
                : null,
          ),
          body: selectedJuso == null || selectedJuso.roadAddr.isEmpty
              ? _buildSearchUi()
              : _buildDetailUi(selectedJuso),
        );
      },
    );
  }
}
