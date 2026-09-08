import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
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
        const SnackBar(content: Text('성공적으로 저장되었습니다!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateStoreMarkerScreen(storeId: widget.storeId),
        ),
      );
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('메뉴 생성')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentBlue),
            );
          }

          final menuItems = _viewModel.menuItems;

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 82),
                itemCount: menuItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == menuItems.length) {
                    return Center(
                      child: TextButton.icon(
                        onPressed: _viewModel.addMenuItem,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('메뉴 추가하기'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    );
                  }

                  final item = menuItems[index];
                  final imageProvider = item.imageProvider;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => _viewModel.pickImage(index),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: imageProvider != null
                                      ? Image(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.add_a_photo,
                                          size: 40,
                                          color: Colors.black54,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: item.nameController,
                                      decoration: const InputDecoration(
                                        labelText: '메뉴이름',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: item.priceController,
                                      decoration: const InputDecoration(
                                        labelText: '메뉴가격',
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: item.descriptionController,
                            decoration: const InputDecoration(
                              labelText: '메뉴 설명(선택사항)',
                            ),
                            maxLines: null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _viewModel.removeMenuItem(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (_viewModel.isSaving)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.accentBlue),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.90,
            height: 50,
            child: ElevatedButton(
              onPressed: _viewModel.isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                '메뉴 저장 후 다음 단계로',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Backward compatibility alias
typedef CreateStoreMenu = CreateStoreMenuScreen;
