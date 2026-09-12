import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/create_store_overview_viewmodel.dart';
import 'create_store_menu_screen.dart';

class CreateStoreOverviewScreen extends StatefulWidget {
  final String storeId;

  const CreateStoreOverviewScreen({super.key, required this.storeId});

  @override
  State<CreateStoreOverviewScreen> createState() =>
      _CreateStoreOverviewScreenState();
}

class _CreateStoreOverviewScreenState extends State<CreateStoreOverviewScreen> {
  late final CreateStoreOverviewViewModel _viewModel;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = CreateStoreOverviewViewModel(storeId: widget.storeId);
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.loadStoreData();
    if (mounted) {
      _storeNameController.text = _viewModel.storeName;
      _descriptionController.text = _viewModel.description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _storeNameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSaveAndContinue() async {
    final success = await _viewModel.saveStoreOverview(
      _storeNameController.text,
      _descriptionController.text,
    );

    if (mounted && success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateStoreMenuScreen(storeId: widget.storeId),
        ),
      );
    } else if (mounted && _viewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_viewModel.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('가게 소개 및 사진')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentBlue,
                semanticsLabel: '가게 불러오는 중...',
              ),
            );
          }

          final imageUrls = _viewModel.imageUrls;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 82),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '가게 이름',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _storeNameController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: '가게 이름',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '가게 소개',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: '가게에 대한 간단한 소개 부탁 드립니다!',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '인테리어, 내부 전경',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: imageUrls.length + 1,
                      itemBuilder: (context, index) {
                        if (index == imageUrls.length) {
                          return GestureDetector(
                            onTap: _viewModel.pickAndUploadImages,
                            child: Container(
                              color: Colors.grey[300],
                              child: _viewModel.isUploading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.accentBlue,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.black54,
                                    ),
                            ),
                          );
                        }
                        final imageUrl = imageUrls[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(imageUrl, fit: BoxFit.cover),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () =>
                                    _viewModel.deleteImage(index, imageUrl),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                            if (_viewModel.deletingIndex == index)
                              Container(
                                color: Colors.black.withAlpha(130),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSaveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                    ),
                    child: const Text(
                      '다음 단계로 이동',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Backward compatibility alias
typedef CreateStoreOverview = CreateStoreOverviewScreen;
