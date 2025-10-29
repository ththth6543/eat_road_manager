import 'package:eat_road_manager/store_screen.dart';
import 'package:flutter/material.dart';

// StatefulWidget으로 변경
class DetailedStoreScreen extends StatefulWidget {
  final Store store;

  const DetailedStoreScreen({super.key, required this.store});

  @override
  State<DetailedStoreScreen> createState() => _DetailedStoreScreenState();
}

class _DetailedStoreScreenState extends State<DetailedStoreScreen>
    with SingleTickerProviderStateMixin {
  // TabController를 위한 Mixin 추가
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // TabController 초기화 (3개의 탭)
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose(); // Controller 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // --- 상단 공통 정보 섹션 ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.store.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // 별점
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.orangeAccent, size: 28),
                        const SizedBox(width: 5),
                        // 별점 로직 넣기
                        Text(
                          "4.8",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // --- TabBar 섹션 ---
              Material(
                color: Colors.white, // 배경색을 주변과 맞춤
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blueAccent,
                  // 터치 피드백(Splash) 색상 추가
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.blue.withAlpha(30);
                      }
                      return null; // 다른 상태에서는 효과 없음
                    },
                  ),
                  tabs: const [
                    Tab(text: '정보'),
                    Tab(text: '메뉴'),
                    Tab(text: '리뷰'),
                  ],
                ),
              ),
              // --- TabBarView 섹션 ---
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 각 탭의 콘텐츠 (ListView 사용)
                    // DraggableScrollableSheet의 scrollController를 각 ListView에 전달
                    _buildInfoTab(scrollController),
                    _buildMenuTab(scrollController),
                    _buildReviewTab(scrollController),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // '정보' 탭 UI
  Widget _buildInfoTab(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [

      ],
    );
  }

  // '메뉴' 탭 UI
  Widget _buildMenuTab(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [],
    );
  }

  // '리뷰' 탭 UI
  Widget _buildReviewTab(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [],
    );
  }
}
