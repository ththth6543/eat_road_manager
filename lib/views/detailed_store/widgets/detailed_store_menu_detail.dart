import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/menu_item.dart';

class DetailedStoreScreenMenuDetail extends StatelessWidget {
  final MenuItem menuInfo;

  const DetailedStoreScreenMenuDetail({super.key, required this.menuInfo});

  static const Color mainColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(menuInfo.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                child: menuInfo.imageUrl != null
                    ? Image.network(menuInfo.imageUrl!)
                    : const Icon(Icons.fastfood, size: 80, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                "• 가격: ${menuInfo.price}원",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "• 정보: ${menuInfo.description ?? ''}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "• 알러지 유발 재료: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "• 유튜브 링크: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
