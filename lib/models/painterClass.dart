import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<ui.PointerDeviceKind> get dragDevices => {
        ui.PointerDeviceKind.touch,
        ui.PointerDeviceKind.mouse,
      };
}

class brushTool extends CustomPainter {
  Paint eraser;
  late List<dynamic> strokes;
  brushTool(this.strokes, this.eraser);

  List<Offset> offsetsList = [];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < strokes.length - 1; i++) {
      if (strokes[i] != null && strokes[i + 1] != null) {
        canvas.drawLine(strokes[i].offset, strokes[i + 1].offset,
            strokes[i].isErased ? eraser : strokes[i].paint);
      } else if (strokes[i] != null && strokes[i + 1] == null) {
        offsetsList.clear();
        offsetsList.add(strokes[i].offset);
        canvas.drawPoints(ui.PointMode.points, offsetsList,
            strokes[i].isErased ? eraser : strokes[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter customPainter) => true;
}

class drawPoint {
  late Offset offset;
  late Paint paint;
  late bool isErased;

  drawPoint(
      {required this.offset, required this.paint, required this.isErased});
}

Future<ui.Image> getImage(List<dynamic> strokes, Paint eraser, Size size) {
  final recorder = ui.PictureRecorder();
  late Canvas canvaGlobal = Canvas(recorder);
  canvaGlobal.drawColor(eraser.color, BlendMode.src);
  List<Offset> offsetsList = [];

  for (int i = 0; i < strokes.length - 1; i++) {
    if (strokes[i] != null && strokes[i + 1] != null) {
      canvaGlobal.drawLine(strokes[i].offset, strokes[i + 1].offset,
          strokes[i].isErased ? eraser : strokes[i].paint);
    } else if (strokes[i] != null && strokes[i + 1] == null) {
      offsetsList.clear();
      offsetsList.add(strokes[i].offset);
      canvaGlobal.drawPoints(ui.PointMode.points, offsetsList,
          strokes[i].isErased ? eraser : strokes[i].paint);
    }
  }

  final picture = recorder.endRecording();
  return picture.toImage(size.width.floor(), size.height.floor());
}
