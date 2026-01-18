import 'package:flutter/material.dart';
import 'package:eat_road_manager/detailed_store/menu_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eat_road_manager/detailed_store/detailed_store_screen_menu_detail.dart';

final supabase = Supabase.instance.client;

class MenuTab extends StatefulWidget {
  final int storeId;
  final ScrollController scrollController;

  const MenuTab({
    super.key,
    required this.storeId,
    required this.scrollController,
  });

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  List<MenuInfo>? _menus;
  bool _isLoading = true;
  String? _errorMessage;
  static const Color mainColor = Color.fromRGBO(255, 143, 33, 1);

  @override
  void initState() {
    super.initState();
    getMenuData();
  }

  Future<void> getMenuData() async {
    try {
      final menuData = await supabase
          .from('menus')
          .select('description, image_url, name, price, created_at')
          .eq('store_id', widget.storeId);

      if (mounted) {
        setState(() {
          _menus = (menuData as List)
              .map((data) => MenuInfo.fromMap(data as Map<String, dynamic>))
              .toList();
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: mainColor));
    }

    //에러가 있을 경우
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    // 메뉴를 등록하지 않아 메뉴가 없을 경우
    if (_menus == null || _menus!.isEmpty) {
      return Center(child: Text('등록된 메뉴가 없습니다.'));
    }

    // 메뉴가 있을 때
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: _menus!.length,
      itemBuilder: (context, index) {
        final menu = _menus![index];
        return Card(
          color: Colors.white,
          shadowColor: Colors.black,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          elevation: 1,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: mainColor.withAlpha(120),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            splashColor: mainColor.withAlpha(100),
            highlightColor: mainColor.withAlpha(100),
            focusColor: mainColor.withAlpha(100),
            hoverColor: mainColor.withAlpha(100),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedStoreScreenMenuDetail(menuInfo: menu)));
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
                            errorBuilder: (context, error, stackTrace) => Icon(
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
                          child: Icon(
                            Icons.fastfood,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menu.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${menu.price}원',
                          style: TextStyle(
                            fontSize: 16,
                            color: mainColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
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
  }
}
