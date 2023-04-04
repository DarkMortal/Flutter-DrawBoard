import 'package:flutter/material.dart';

List<Color> defaultForegroundColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.amber,
  Colors.yellow,
  Colors.indigo,
];

List<Color> defaultBackgroundColors = [
  Colors.white,
  const Color.fromARGB(255, 28, 35, 49),
  Colors.green,
  Colors.blue,
  Colors.indigo,
  const Color.fromARGB(255, 127, 218, 244)
];

//Convert the color to hex, Save it in preferences
String colorToHex(Color myColor) => '#${myColor.value.toRadixString(16)}';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1), radix: 16));
}
