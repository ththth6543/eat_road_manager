import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../viewmodels/detailed_store_viewmodel.dart';
import '../widgets/detailed_store_menu_detail.dart';

class MenuTab extends StatefulWidget {
  final String storeId;
  final ScrollController scrollController;
  final DetailedStoreViewModel? viewModel;

  const MenuTab({
    super.key,
    required this.storeId,
    required this.scrollController,
    this.viewModel,
  });

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  late final DetailedStoreViewModel _viewModel;
  bool _isLocalViewModel = false;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
    } else {
      _viewModel = DetailedStoreViewModel(storeId: widget.storeId);
      _isLocalViewModel = true;
      _viewModel.fetchMenus();
    }
  }

  @override
  void dispose() {
    if (_isLocalViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.isMenusLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (_viewModel.menuError != null) {
          return Center(child: Text(_viewModel.menuError!));
        }

        final menus = _viewModel.menus;
        if (menus == null || menus.isEmpty) {
          return const Center(child: Text('등록된 메뉴가 없습니다.'));
        }

        return ListView.builder(
          controller: widget.scrollController,
          itemCount: menus.length,
          itemBuilder: (context, index) {
            final menu = menus[index];
            return Card(
              color: Colors.white,
              shadowColor: Colors.black,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              elevation: 1,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: AppColors.primary.withAlpha(120),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                splashColor: AppColors.primary.withAlpha(100),
                highlightColor: AppColors.primary.withAlpha(100),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailedStoreScreenMenuDetail(menuInfo: menu),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      menu.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                menu.imageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.fastfood,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(
                                Icons.fastfood,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menu.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${menu.price}원',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (menu.description != null &&
                                menu.description!.isNotEmpty)
                              Text(
                                menu.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
