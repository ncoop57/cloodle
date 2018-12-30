import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CloodlePainter extends CustomPainter {
  ui.Image image;
  List<Offset> points;
  Color color;
  StrokeCap strokeCap;
  double strokeWidth;
  List<CloodlePainter> painters;

  CloodlePainter(
      {this.image,
      this.points,
      this.color,
      this.strokeCap,
      this.strokeWidth,
      this.painters = const []});

  @override
  void paint(Canvas canvas, Size size) {
    // paintImage(
    //     canvas: canvas,
    //     rect: const Offset(0, 0) & const Size(411.4, 683.4),
    //     image: this.image);
    // size.center(Offset.zero)
    // double height = this.image.height;
    paintImage(canvas: canvas, rect: Offset.zero & size, image: this.image);

    for (CloodlePainter painter in painters) {
      painter.paint(canvas, size);
    }

    print("Painting....");

    Paint paint = new Paint();
    paint.color = color;
    paint.strokeCap = strokeCap;
    paint.strokeWidth = strokeWidth;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CloodlePainter oldPainter) => oldPainter.points != points;

  // List<Offset> points;
  // final ui.Image image;

  // CloodlePainter({this.image, this.points});

  // @override
  // void paint(Canvas canvas, Size size) {
  //   canvas.drawImage(this.image, ui.Offset.zero, new Paint());

  //   Paint paint = new Paint()
  //     ..color = Colors.blue
  //     ..strokeCap = StrokeCap.round
  //     ..strokeWidth = 10.0;

  //   for (int i = 0; i < points.length - 1; i++) {
  //     if (points[i] != null && points[i + 1] != null) {
  //       canvas.drawLine(points[i], points[i + 1], paint);
  //     }
  //   }
  // }

  // @override
  // bool shouldRepaint(CloodlePainter oldDelegate) => false;
}
