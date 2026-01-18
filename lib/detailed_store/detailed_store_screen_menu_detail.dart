import 'package:flutter/material.dart';
import 'package:eat_road_manager/detailed_store/menu_info.dart';

class DetailedStoreScreenMenuDetail extends StatelessWidget {
  final MenuInfo menuInfo;

  const DetailedStoreScreenMenuDetail({super.key, required this.menuInfo});

  static const Color mainColor = Color.fromRGBO(255, 143, 33, 1);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(menuInfo.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: mainColor.withAlpha(120), width: 4),
                ),
                child: Image.network('${menuInfo.imageUrl}'),
              ),
              SizedBox(height: 10,),
              Text("• 가격: ${menuInfo.price}원",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10,),
              Text("• 정보: ${menuInfo.description}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10,),
              Text("• 알러지 유발 재료: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10,),
              Text("• 유튜브 링크: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
