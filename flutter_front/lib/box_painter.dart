import 'package:flutter/material.dart';

class BoPainter extends CustomPainter {
  final Map<String, dynamic> detectedObjects;
  final Color color;
  final double strokeWidth;

  BoPainter(this.detectedObjects, {this.color = Colors.red, this.strokeWidth = 2.0});
  @override
  void paint(Canvas canvas, Size size) {
    print("In paint method");
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    detectedObjects.forEach((key, value) {
      if (value != null && value['xywh'] != null && value['xywh'].length == 4) {
        final List<dynamic> box = value['xywh'];
        final rect = Rect.fromLTWH(
          box[0].toDouble(), // x
          box[1].toDouble(), // y
          box[2].toDouble(), // width
          box[3].toDouble(), // height
        );
        canvas.drawRect(rect, paint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant BoPainter oldDelegate) {
    print("In shouldRepaint method");
    return oldDelegate.detectedObjects != detectedObjects;
  }
}
