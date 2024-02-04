import 'package:flutter/material.dart';
import 'package:draw_board/models/defaultColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void saveColors(List<Color> list_colors, bool isBackground) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  List<String> colors = [];
  for (Color col in list_colors) colors.add(colorToHex(col));
  _pref.setStringList(
      isBackground ? 'backgroundColors' : 'foregroundColors', colors);
}

Future<List<Color>> getColors(bool isBackground) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  List<Color> colors = [];
  List<String>? savedColors = _pref
      .getStringList(isBackground ? 'backgroundColors' : 'foregroundColors');
  if (savedColors == null) {
    saveColors(isBackground ? defaultBackgroundColors : defaultForegroundColors,
        isBackground);
    return isBackground ? defaultBackgroundColors : defaultForegroundColors;
  }
  for (String hex in savedColors) colors.add(hexToColor(hex));
  return colors;
}

void saveColor(Color col, bool isBackground) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  _pref.setString(isBackground ? 'backColor' : 'foreColor', colorToHex(col));
}

void saveBrushWidth(double val) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  _pref.setInt('brush', val.floor());
}

Future<Color> getColor(bool isBackground) async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  String? hex = _pref.getString(isBackground ? 'backColor' : 'foreColor');
  if (hex == null) {
    saveColor(
        isBackground ? defaultBackgroundColors[0] : defaultForegroundColors[0],
        isBackground);
    return isBackground
        ? defaultBackgroundColors[0]
        : defaultForegroundColors[0];
  }
  return hexToColor(hex);
}

Future<double> getBrushWidth() async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  int? x = _pref.getInt('brush');
  if (x == null) return 2.0;
  return x.toDouble();
}

void clearSharedPref() async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  _pref.clear();
}
