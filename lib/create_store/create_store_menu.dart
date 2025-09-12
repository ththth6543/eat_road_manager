import 'package:flutter/material.dart';

class CreateStoreMenu extends StatefulWidget {
  const CreateStoreMenu({super.key});

  @override
  State<CreateStoreMenu> createState() => _CreateStoreMenuState();
}

class _CreateStoreMenuState extends State<CreateStoreMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("메뉴 생성")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "가게 메뉴를 작성해 주세요!",
                style: TextStyle(fontSize: 20, color: Colors.grey,),
              ),
            ],
          ),
        )
      ),
    );
  }
}
