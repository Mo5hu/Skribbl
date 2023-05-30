import 'package:flutter/material.dart';

class TouchPoints {
  Paint? paint;
  Offset? points;

  TouchPoints({this.points, this.paint});

  factory TouchPoints.fromMap(Map<String, dynamic> data) {
    Color color;
    if (data.containsKey('color')) {
      String valueString =
          data['color'].split('(0x')[1].split(')')[0]; // kind of hacky..
      int valueColor = int.parse(valueString, radix: 16);
      color = Color(valueColor);
    } else {
      color = Colors.black;
    }
    if (data['dx'] != null && data['dy'] != null) {
      return TouchPoints(
        paint: Paint()
          ..color = color
          ..strokeWidth = data['size'].toDouble()
          ..strokeCap = StrokeCap.round,
        points: Offset(data['dx'].toDouble(), data['dy'].toDouble()),
      );
    }

    return TouchPoints(
      paint: Paint()
        ..color = color
        ..strokeWidth = data['size'].toDouble()
        ..strokeCap = StrokeCap.round,
      points: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dx': points?.dx,
      'dy': points?.dy,
      'color': paint?.color.toString(),
      'size': paint?.strokeWidth,
    };
  }
}
