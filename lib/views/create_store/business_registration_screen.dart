import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/business_verification_viewmodel.dart';

class BusinessRegistrationScreen extends StatefulWidget {
  const BusinessRegistrationScreen({super.key});

  @override
  State<BusinessRegistrationScreen> createState() =>
      _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState
    extends State<BusinessRegistrationScreen> {
  final TextEditingController bNoController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  late final BusinessRegistrationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BusinessRegistrationViewModel();
  }

  @override
  void dispose() {
    bNoController.dispose();
    dateController.dispose();
    nameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final valid = await _viewModel.verify(
      bNo: bNoController.text,
      startDt: dateController.text,
      pName: nameController.text,
    );

    if (!valid && _viewModel.errorMessage != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "인증 실패",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(_viewModel.errorMessage!),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "확인",
                style: TextStyle(color: AppColors.accentBlue),
              ),
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
      appBar: AppBar(title: const Text("사업자등록번호 인증")),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  '사업자등록번호 (- 제외)',
                  bNoController,
                  TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  '개업일자 (예: 20230101)',
                  dateController,
                  TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField('대표자 성명', nameController, TextInputType.text),
                const SizedBox(height: 12),
                if (_viewModel.isSuccess)
                  const Text(
                    "인증성공: 유효한 사업자 입니다",
                    style: TextStyle(color: Colors.green),
                  ),
                const SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _viewModel.isLoading ? null : _handleVerify,
                    child: _viewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("인증하기"),
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
typedef BusinessRegiAuth = BusinessRegistrationScreen;
