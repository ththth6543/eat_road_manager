import 'package:flutter/material.dart';

class CreateStoreCheckDocument extends StatefulWidget {
  const CreateStoreCheckDocument({super.key});

  @override
  State<CreateStoreCheckDocument> createState() =>
      _CreateStoreCheckDocumentState();
}

class _CreateStoreCheckDocumentState extends State<CreateStoreCheckDocument> {
  // 사업자 등록증 번호 Controller
  final _businessRegistrationNumberController = TextEditingController();

  // 영업 신고증 번호 Controller
  final _businessReportNumberController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("서류 확인"),
        centerTitle: true,
      ),
      body: Column(
       children: [
         Text("사업자 등록증 번호"),
         SizedBox(height: 8,),
         TextField(
           controller: _businessRegistrationNumberController,
           style: TextStyle(fontSize: 20),
           keyboardType: TextInputType.text,
           decoration: InputDecoration(
             border: OutlineInputBorder(),
             labelText: "사업자 등록증 번호",
           ),
         ),
         SizedBox(height: 18,),
         Text("영업 신고증 번호"),
         SizedBox(height: 8,),
         TextField(
           controller: _businessReportNumberController,
           style: TextStyle(fontSize: 20),
           keyboardType: TextInputType.text,
           decoration: InputDecoration(
             border: OutlineInputBorder(),
             labelText: "영업 신고증 번호",
           ),
         ),
       ],
      )
    );
  }
}
