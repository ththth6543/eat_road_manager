import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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
                  onSubmitted: (val) => _viewModel.search(val),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _viewModel.search(_searchController.text),
                child: const Text('검색'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentBlue),
                );
              }

              if (_viewModel.results.isEmpty) {
                return Center(
                  child: _viewModel.hasSearched
                      ? const Text('검색 결과가 없습니다.')
                      : const Text('주소를 검색하세요.'),
                );
              }

              return ListView.builder(
                itemCount: _viewModel.results.length,
                itemBuilder: (context, index) {
                  final juso = _viewModel.results[index];
                  return ListTile(
                    title: Text(juso.roadAddr),
                    subtitle: Text('[지번] ${juso.jibunAddr}'),
                    onTap: () {
                      _viewModel.selectJuso(juso);
                    },
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('기본 주소', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(selectedJuso.roadAddr,
              style: Theme.of(context).textTheme.bodyLarge),
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
                final addressData = selectedJuso.toJson();
                addressData['detailAddr'] =
                    _detailAddressController.text.trim();
                debugPrint('건물번호: ${addressData.toString()}');
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
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final selectedJuso = _viewModel.selectedJuso;
        return Scaffold(
          appBar: AppBar(
            title: Text(selectedJuso == null ? '주소 검색' : '상세 주소 입력'),
            leading: selectedJuso != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
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
