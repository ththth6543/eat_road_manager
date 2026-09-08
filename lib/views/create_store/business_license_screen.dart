import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/business_verification_viewmodel.dart';

class BusinessLicenseScreen extends StatefulWidget {
  const BusinessLicenseScreen({super.key});

  @override
  State<BusinessLicenseScreen> createState() => _BusinessLicenseScreenState();
}

class _BusinessLicenseScreenState extends State<BusinessLicenseScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final BusinessLicenseViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BusinessLicenseViewModel();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    await _viewModel.verifyLicense(_searchController.text);
    if (!mounted) return;

    if (_viewModel.errorMessage != null && _viewModel.searchResults.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("인증 실패",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(_viewModel.errorMessage!),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("확인",
                  style: TextStyle(color: AppColors.accentBlue)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTextField(
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
        floatingLabelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: AppColors.accentBlue.withAlpha(180),
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 3.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('영업 허가증 인증')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                    '인허가 번호 (- 제외)', _searchController, TextInputType.number),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    elevation: 0,
                  ),
                  onPressed: _viewModel.isLoading ? null : _handleSearch,
                  child: _viewModel.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "검색 시작",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 25),
                Text(
                  "검색 결과",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const Divider(height: 20),
                Expanded(
                  child: _viewModel.searchResults.isEmpty
                      ? const Center(child: Text("인증할 식당의 이름을 검색해 주세요."))
                      : ListView.builder(
                          itemCount: _viewModel.searchResults.length,
                          itemBuilder: (ctx, index) {
                            final item = _viewModel.searchResults[index];
                            final String? entDtRaw = item['CLSBIZ_DT'];
                            final bool isClosed = entDtRaw != null &&
                                entDtRaw.trim().isNotEmpty;
                            final bool isLive = !isClosed;

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                title: Text(
                                  item['BSSH_NM'] ?? '상호명 미기재',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      item['LOCP_ADDR'] ?? "주소 정보 없음",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${item['INDUTY_NM'] ?? '업종 미분류'} | ${item['PRSDNT_NM'] ?? '대표자 없음'}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  isLive ? '영업중' : '폐업',
                                  style: TextStyle(
                                    color: isLive ? Colors.blue : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: isLive
                                    ? () {
                                        debugPrint(
                                            "${item['BSSH_NM']} 선택됨");
                                      }
                                    : null,
                              ),
                            );
                          },
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
typedef BusinessLicenseAuth = BusinessLicenseScreen;
