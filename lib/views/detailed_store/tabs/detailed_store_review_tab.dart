import 'package:flutter/material.dart';

class ReviewTab extends StatelessWidget {
  const ReviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "리뷰 탭",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
