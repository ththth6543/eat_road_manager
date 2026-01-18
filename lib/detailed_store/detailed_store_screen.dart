import 'package:eat_road_manager/detailed_store/detailed_store_screen_review_tab.dart';
import 'package:eat_road_manager/detailed_store/store_info.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eat_road_manager/detailed_store/detailed_store_screen_menu_tab.dart';
import 'package:eat_road_manager/detailed_store/detailed_store_screen_info_tab.dart';

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

  final mainColor = Color.fromRGBO(255, 143, 33, 1);

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          height: 500,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromRGBO(255, 143, 33, 1),
                  ),
                )
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 0),
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
                              icon: Icon(Icons.close, color: Colors.redAccent),
                              style: ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _storeInfo!.name,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // 별점 시스템 넣기
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Color(0xFFFFD700), size: 30),
                        SizedBox(width: 5),
                        Text('4.8', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    SizedBox(height: 10),
                    // color: #F47B25
                    TabBar(
                      labelColor: Color.fromRGBO(255, 143, 33, 1.0),
                      indicatorColor: Color.fromRGBO(255, 143, 33, 1.0),
                      padding: EdgeInsets.only(
                        top: 0,
                        left: 15,
                        right: 15,
                        bottom: 0,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      unselectedLabelColor: Colors.grey,
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                        states,
                      ) {
                        if (states.contains(WidgetState.pressed)) {
                          return Color.fromRGBO(255, 143, 33, 1);
                        }
                        return null;
                      }),
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
                          InfoTab(
                            storeInfo: _storeInfo!,
                            scrollController: scrollController,
                          ),
                          MenuTab(
                            storeId: widget.storeId,
                            scrollController: scrollController,
                          ),
                          ReviewTab(),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
