import 'package:flutter/material.dart';
import 'package:skribbl/models/touch_points.dart';

// const onPanEnd = const Offset(999, 999);

class MyCustomPainter extends CustomPainter {
  final List<TouchPoints?>? touchpoints;

  MyCustomPainter({required this.touchpoints});

  @override
  void paint(Canvas canvas, Size size) {
    // if (touchpoints.length == 1) {
    //   canvas.drawCircle(touchpoints[1].points!,
    //       touchpoints[1]!.paint!.strokeWidth / 2, touchpoints[1]!.paint!);
    // } else if (touchpoints.length > 1) {
    // List<Offset> offsets = [];
    // for (int i = 0; i < touchpoints.length; i++) {
    // offsets.add(touchpoints[i].points!);
    // canvas.drawCircle(touchpoints[i].points!,
    //     touchpoints[i]!.paint!.strokeWidth / 2, touchpoints[i]!.paint!);
    // }
    // canvas.drawRawPoints(PointMode.lines, offsets, touchpoints.last.paint!);
    // canvas.drawPoints(PointMode.points, offsets, touchpoints.last.paint!);
    // canvas.drawLine(offsets.first, offsets.last, touchpoints.last.paint!);
    // }
    if (touchpoints != null && touchpoints!.isNotEmpty) {
      for (var i = 0; i < touchpoints!.length; i++) {
        // if (touchpoints[i].points != onPanEnd) {
        if (shouldDrawLine(i)) {
          canvas.drawLine(touchpoints![i]!.points!,
              touchpoints![i + 1]!.points!, touchpoints![i]!.paint!);
        } else if (shouldDrawPoint(i)) {
          canvas.drawCircle(touchpoints![i]!.points!,
              touchpoints![i]!.paint!.strokeWidth / 2, touchpoints![i]!.paint!);
          // canvas.drawPoints(
          //     PointMode.points, [touchpoints[i]!.points!], touchpoints[i]!.paint!);
          // }
        }
        // }
      }
    }
  }

  bool shouldDrawPoint(int i) =>
      touchpoints![i]?.points != null &&
      touchpoints!.length > i + 1 &&
      touchpoints![i + 1]?.points == null;

  bool shouldDrawLine(int i) =>
      touchpoints![i]?.points != null &&
      touchpoints!.length > i + 1 &&
      touchpoints![i + 1]?.points != null;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:skribbl/models/touch_points.dart';

// class MyCustomPainter extends CustomPainter {
//   final List<Offset> offsets;
//   final int size;
//   final Color color;
//   Paint painter = Paint();

//   MyCustomPainter({
//     required this.offsets,
//     required this.color,
//     required this.size,
//   }) {
//     painter = Paint()
//       ..isAntiAlias = true
//       ..color = color
//       ..strokeWidth = size.toDouble();
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     // if (offsets.length == 1) {
//     //   canvas.drawCircle(offsets[1].points!,
//     //       offsets[1]!.paint!.strokeWidth / 2, offsets[1]!.paint!);
//     // } else if (offsets.length > 1) {
//     // List<Offset> offsets = [];
//     // for (int i = 0; i < offsets.length; i++) {
//     // offsets.add(offsets[i].points!);
//     // canvas.drawCircle(offsets[i].points!,
//     //     offsets[i]!.paint!.strokeWidth / 2, offsets[i]!.paint!);
//     // }
//     // canvas.drawRawPoints(PointMode.lines, offsets, offsets.last.paint!);
//     // canvas.drawPoints(PointMode.points, offsets, offsets.last.paint!);
//     // canvas.drawLine(offsets.first, offsets.last, offsets.last.paint!);
//     // }
//     if (offsets != null) {
//       for (var i = 0; i < offsets.length; i++) {
//         if (shouldDrawLine(i)) {
//           canvas.drawLine(offsets[i], offsets[i + 1], painter);
//         } else if (shouldDrawPoint(i)) {
//           // canvas.drawCircle(offsets[i].points!,
//           //     offsets[i].strokeWidth / 2, offsets[i]);
//           canvas.drawPoints(PointMode.points, offsets, painter);
//           // }
//         }
//       }
//     }
//   }

//   bool shouldDrawPoint(int i) =>
//       offsets[i] != null && offsets.length > i + 1 && offsets[i + 1] == null;

//   bool shouldDrawLine(int i) =>
//       offsets[i] != null && offsets.length > i + 1 && offsets[i + 1] != null;

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
