import 'package:flutter/material.dart';

class DraggableTabSheetExample extends StatefulWidget {
  const DraggableTabSheetExample({super.key});

  @override
  State<DraggableTabSheetExample> createState() => _DraggableTabSheetExampleState();
}

class _DraggableTabSheetExampleState extends State<DraggableTabSheetExample>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 컨텐츠 (예시)
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                '배경 컨텐츠 (지도나 이미지 등)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // DraggableScrollableSheet
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onVerticalDragUpdate: (_){},
                      onVerticalDragStart: (_){},
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            color: Colors.red,
                          ),
                          Text("23131"),
                        ],
                      ),
                    ),
                    // 탭바
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        tabs: const [
                          Tab(text: '탭 1'),
                          Tab(text: '탭 2'),
                          Tab(text: '탭 3'),
                        ],
                      ),
                    ),

                    // 탭바 내용
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTabContent(scrollController, '탭 1 내용'),
                          _buildTabContent(scrollController, '탭 2 내용'),
                          _buildTabContent(scrollController, '탭 3 내용'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 각 탭 안의 내용 (ListView 예시)
  Widget _buildTabContent(ScrollController controller, String title) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.red
          ),
          Container(
              width: double.infinity,
              height: 200,
              color: Colors.orangeAccent
          ),
          Container(
              width: double.infinity,
              height: 200,
              color: Colors.yellowAccent
          ),
          Container(
              width: double.infinity,
              height: 200,
              color: Colors.red
          ),
          Container(
              width: double.infinity,
              height: 200,
              color: Colors.orangeAccent
          ),
          Container(
              width: double.infinity,
              height: 200,
              color: Colors.yellowAccent
          ),
          Container(
              width: double.infinity,
              height: 200,
              color: Colors.red
          ),
          Container(
              width: double.infinity,
              height: 200,
              color: Colors.orangeAccent
          ),
          Container(
              width: double.infinity,
              height: 200,
              color: Colors.yellowAccent
          ),
        ]
      )
    );
  }
}