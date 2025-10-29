import 'package:flutter/material.dart';

class SpeechBubblePainter extends CustomPainter {
  final Color bubbleColor;
  final Color borderColor;
  final double borderWidth;

  SpeechBubblePainter({
    this.bubbleColor = Colors.white,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    // 말풍선 배경 채우기
    final fillPaint = Paint()
      ..color = bubbleColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 말풍선 외곽선 그리기
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  Path _buildPath(Size size) {
    const cornerRadius = 12.0;
    const pointerHeight = 10.0;
    const pointerWidth = 16.0;

    final path = Path();

    // 말풍선 몸통
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - pointerHeight),
      const Radius.circular(cornerRadius),
    ));

    // 아래쪽 꼬리
    final pointerStartX = (size.width / 2) - (pointerWidth / 2);
    path.moveTo(pointerStartX, size.height - pointerHeight);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(pointerStartX + pointerWidth, size.height - pointerHeight);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
