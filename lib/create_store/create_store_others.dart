import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CreateStoreOthers extends StatefulWidget {
  final String storeId;

  const CreateStoreOthers({super.key, required this.storeId});

  @override
  State<CreateStoreOthers> createState() => _CreateStoreOthersState();
}

class _CreateStoreOthersState extends State<CreateStoreOthers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("기타 사항"),
      ),
    );
  }
}
