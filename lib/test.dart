import 'package:eat_road_manager/main.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final double _headerHeight = 160.0;
  final double _tabBarHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            // [수정] DefaultTabController를 NestedScrollView 바깥으로 이동하여
            // Header와 Body 모두 접근 가능하게 합니다.
            return DefaultTabController(
              length: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                ),
                child: NestedScrollView(
                  controller: scrollController,
                  headerSliverBuilder: (BuildContext context,
                      bool innerBoxIsScrolled) {
                    return [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyHeaderDelegate(
                          minHeight: _headerHeight + _tabBarHeight,
                          maxHeight: _headerHeight + _tabBarHeight,
                          child: Column(
                            children: [
                              // 가게 정보 (고정 높이)
                              const SizedBox(
                                height: 160.0, // _headerHeight와 동일
                                child: ShopInfoHeader(),
                              ),
                              // 탭바 (TabBar가 이제 DefaultTabController를 찾을 수 있습니다)
                              SizedBox(
                                height: _tabBarHeight,
                                child: const Material(
                                  color: Colors.white,
                                  child: TabBar(
                                    labelColor: Colors.black,
                                    unselectedLabelColor: Colors.grey,
                                    indicatorColor: Colors.black,
                                    tabs: [
                                      Tab(text: "메뉴"),
                                      Tab(text: "정보"),
                                      Tab(text: "리뷰"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },

                  // [수정] TabBarView는 이제 DefaultTabController의 자식입니다.
                  body: TabBarView(
                    children: [
                      _buildMenuTab(),
                      _buildInfoTab(),
                      _buildReviewTab(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 탭 내용 위젯 (이전과 동일) ---
  Widget _buildMenuTab() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 30,
      itemBuilder: (_, i) =>
          ListTile(
            title: Text("메뉴 아이템 ${i + 1}"),
            subtitle: Text("${(i + 1) * 1000}원"),
          ),
    );
  }

  Widget _buildInfoTab() => const Center(child: Text("가게 정보"));

  Widget _buildReviewTab() => const Center(child: Text("리뷰 목록"));
}

// 가게 정보 위젯 (이전과 동일)
class ShopInfoHeader extends StatelessWidget {
  const ShopInfoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Text(
            "맛있는 파스타 집",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
              },
              icon: Icon(Icons.cancel)
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star_half, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text("4.5", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// 상단 고정 헤더를 위한 Delegate 클래스 (이전과 동일)
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}