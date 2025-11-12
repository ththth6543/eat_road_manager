import 'package:eat_road_manager/store_info.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detailed_store_screen_block_icon.dart';
import 'package:flutter/services.dart';
import 'detailed_store_screen_text_button.dart';

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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          height: 500,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color.fromRGBO(255, 143, 33, 1),))
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
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
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 15, left: 15, right: 15),
            //padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("인테리어 사진 들어갈 곳"),
          ),
          // Iconbutton
          BlockIcon(),
          //description
          Container(
            padding: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
            width: double.infinity,
            child: Text(info.description),
          ),
          Divider(
            height: 0,
            thickness: 1,
            color: Colors.grey[300],
            indent: 15,
            endIndent: 15,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
            child: Column(
              children: [
                // 주소 address
                IconTextButton(
                  icon: Icons.location_on,
                  text: '${info.roadAddr} ${info.detailAddr ?? ''}'.trim(),
                  onPressed: () {
                    final fullAddress =
                        '${info.roadAddr} ${info.detailAddr ?? ''}'.trim();

                    if (fullAddress.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: fullAddress));
                    }
                  },
                ),
                IconTextButton(
                  icon: Icons.phone,
                  text: info.storePhoneNumber ?? '전화번호 정보 없음',
                  onPressed: () {
                    if (info.storePhoneNumber != null &&
                        info.storePhoneNumber!.isNotEmpty) {
                      Clipboard.setData(
                        ClipboardData(text: info.storePhoneNumber!),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            color: Colors.grey[300],
            indent: 15,
            endIndent: 15,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  "영업 시간",
                ),
                SizedBox(height: 10),
                IconTextButton(
                  icon: Icons.access_time,
                  text: '${info.openTime} ~ ${info.closeTime}',
                ),
                IconTextButton(
                  icon: Icons.dining,
                  text: '주문 마감 시간: ${info.lastOrderTime ?? '정보 없음'}',
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            color: Colors.grey[300],
            indent: 15,
            endIndent: 15,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  "세부 사항",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab(StoreInfo info, ScrollController scrollController) {
    return Text("메뉴 탭");
  }

  Widget _buildReviewTab(StoreInfo info, ScrollController scrollController) {
    return Text("리뷰탭");
  }
}