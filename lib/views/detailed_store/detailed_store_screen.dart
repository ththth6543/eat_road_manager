import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/detailed_store_viewmodel.dart';
import 'tabs/detailed_store_info_tab.dart';
import 'tabs/detailed_store_menu_tab.dart';
import 'tabs/detailed_store_review_tab.dart';

class DetailedStoreScreen extends StatefulWidget {
  final int storeId;
  final VoidCallback onClose;

  const DetailedStoreScreen({
    super.key,
    required this.storeId,
    required this.onClose,
  });

  @override
  State<DetailedStoreScreen> createState() => _DetailedStoreScreenState();
}

class _DetailedStoreScreenState extends State<DetailedStoreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final DetailedStoreViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _viewModel = DetailedStoreViewModel(storeId: widget.storeId);
    _viewModel.fetchStoreDetails();
    _viewModel.fetchMenus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  static const Color mainColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.isStoreLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: mainColor),
                );
              }

              if (_viewModel.storeError != null) {
                return Center(child: Text(_viewModel.storeError!));
              }

              final storeInfo = _viewModel.storeInfo;
              if (storeInfo == null) {
                return const Center(child: Text('가게 정보가 없습니다.'));
              }

              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.zero,
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: mainColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: widget.onClose,
                            icon: const Icon(Icons.close,
                                color: Colors.redAccent),
                            style: const ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    storeInfo.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Color(0xFFFFD700), size: 30),
                      SizedBox(width: 5),
                      Text('4.8', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TabBar(
                    controller: _tabController,
                    labelColor: mainColor,
                    indicatorColor: mainColor,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: Colors.grey,
                    overlayColor:
                        WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return mainColor.withAlpha(50);
                      }
                      return null;
                    }),
                    tabs: const [
                      Tab(text: '정보'),
                      Tab(text: '메뉴'),
                      Tab(text: '리뷰'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        InfoTab(
                          storeInfo: storeInfo,
                          scrollController: scrollController,
                        ),
                        MenuTab(
                          storeId: widget.storeId,
                          scrollController: scrollController,
                          viewModel: _viewModel,
                        ),
                        const ReviewTab(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
