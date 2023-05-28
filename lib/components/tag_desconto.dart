import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TagDesconto extends CustomPainter {
  const TagDesconto({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    Path path = Path();

    path
      ..moveTo(0, 0)
      ..lineTo(size.width * .87, 0)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * .87, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    //* Circle
    canvas.drawCircle(
      Offset(size.width * .87, size.height * .5),
      size.height * .15,
      paint..color = Get.isDarkMode ? const Color(0xFF666666) : const Color(0xFFFFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
