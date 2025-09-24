import 'package:flutter/material.dart';

class StoreScreen extends StatefulWidget {
  final String storeId;

  const StoreScreen({super.key, required this.storeId});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("가게 샘플"),),
      body: Center(
        child: Text("가게 샘플 asdfasdf"),
      ),
    );
  }
}

