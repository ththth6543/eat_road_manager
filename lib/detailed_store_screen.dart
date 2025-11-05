import 'package:eat_road_manager/store_info.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marquee/marquee.dart';

final supabase = Supabase.instance.client;

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
  TabController? _tabController;
  StoreInfo? _storeInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchStoreDetails();
  }

  Future<void> _fetchStoreDetails() async {
    try {
      final data = await supabase
          .from('stores')
          .select()
          .eq('id', widget.storeId)
          .single();
      if (mounted) {
        setState(() {
          _storeInfo = StoreInfo.fromMap(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '데이터를 불러오는 데 실패했습니다: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  double _sheetposition = 0.4;
  final double _dragSensivity = 600;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _sheetposition,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    Grabber(
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        setState(() {
                          _sheetposition -= details.delta.dy / _dragSensivity;
                          if (_sheetposition < 0.25) {
                            _sheetposition = 0.25;
                          }
                          if (_sheetposition > 1.0) {
                            _sheetposition = 1.0;
                          }
                        });
                      },
                    ),
                    Text(_storeInfo!.name, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Color(0xFFFFD700), size: 30,),
                        SizedBox(width: 5,),
                        Text('4.8', style: TextStyle(fontSize: 20),),
                      ],
                    ),
                    TabBar(
                      tabs: [
                        Tab(text: '정보'),
                        Tab(text: '메뉴'),
                        Tab(text: '리뷰'),
                      ],
                      controller: _tabController,
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildInfoTab(_storeInfo!, scrollController),
                          _buildMenuTab(_storeInfo!, scrollController),
                          _buildReviewTab(_storeInfo!, scrollController),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildInfoTab(StoreInfo info, ScrollController scrollController) {
    return ListView.builder(
      itemCount: 15,
        itemBuilder: (context, index) {
      return ListTile(
        title: Text(info.name),
        subtitle: Text(info.description),
      );
    });
  }

  Widget _buildMenuTab(StoreInfo info, ScrollController scrollController) {
    return Text("메뉴 탭");
  }

  Widget _buildReviewTab(StoreInfo info, ScrollController scrollController) {
    return Text("리뷰탭");
  }
}

class Grabber extends StatelessWidget {
  const Grabber({super.key, required this.onVerticalDragUpdate});

  final ValueChanged<DragUpdateDetails> onVerticalDragUpdate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      child: Container(
        width: double.infinity,
        height: 25,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            width: 40.0,
            height: 5.0,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }
}
