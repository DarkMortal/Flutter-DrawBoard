import 'dart:io' as fs;
import 'dart:io' show Platform;
import 'dart:ui' show ImageByteFormat;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:draw_board/widgets/popupMessage.dart';
import 'package:draw_board/models/painterClass.dart';
import 'package:draw_board/models/defaultColors.dart';
import 'package:draw_board/models/sharedPrefHelper.dart';
import 'package:draw_board/models/androidFileSaver.dart';

double getMax(double a, double b) => a >= b ? a : b;
double getMin(double a, double b) => a <= b ? a : b;

class DrawBoard extends StatefulWidget {
  @override
  DrawBoardState createState() => DrawBoardState();
}

class DrawBoardState extends State<DrawBoard> {
  Color? tempCol;
  double brushSize = 3;
  late Paint eraserBrush = Paint();
  bool showAppBar = true, isErase = false;
  late List<Color> backColors = [], foreColors = [];
  late Color foregroundColor = defaultForegroundColors[0],
      backgroundColor = defaultBackgroundColors[0];

  List<dynamic> drawPoints = [];

  void initColors() async {
    //clearSharedPref(); // don't use in production

    backColors = await getColors(true);
    foreColors = await getColors(false);

    backgroundColor = await getColor(true);
    foregroundColor = await getColor(false);

    brushSize = await getBrushWidth();

    setState(() {
      eraserBrush = Paint()
        ..color = backgroundColor
        ..isAntiAlias = true
        ..strokeCap = StrokeCap.round
        ..strokeWidth = brushSize * 5;
    });
  }

  void updateBackground(Color col) {
    backgroundColor = col;
    saveColor(col, true);
  }

  void updateForeground(Color col) {
    foregroundColor = col;
    saveColor(col, false);
  }

  @override
  void initState() {
    super.initState();
    initColors();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: showAppBar
          ? Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: SpeedDial(
                direction: SpeedDialDirection.down,
                icon: Icons.menu,
                activeIcon: Icons.close,
                iconTheme: const IconThemeData(color: Colors.white),
                children: [
                  SpeedDialChild(
                    child: Icon(isErase
                        ? Icons.pentagon_rounded
                        : Icons.square_rounded),
                    label: "Pencil / Eraser",
                    onTap: () => setState(() {
                      isErase = !isErase;
                    }),
                  ),
                  SpeedDialChild(
                      child: const Icon(Icons.cleaning_services_rounded),
                      label: "Clear All",
                      onTap: () => drawPoints.clear()),
                  SpeedDialChild(
                      child: const Icon(Icons.save),
                      label: "Save",
                      onTap: () => {
                            getImage(drawPoints, eraserBrush,
                                    MediaQuery.of(context).size)
                                .then((value) async {
                              var imgBytes = await value.toByteData(
                                  format: ImageByteFormat.png);
                              if (Platform.isLinux) {
                                fs.File('./savedImage.png').writeAsBytesSync(
                                    imgBytes!.buffer.asInt8List());
                                showMessage(
                                    context, 'Image saved successfully :)');
                              }
                              if (Platform.isAndroid) {
                                saveImage(imgBytes!).then((value) {
                                  if (value)
                                    showMessage(
                                        context, 'Image saved successfully');
                                  else
                                    showMessage(
                                        context, "Image couldn't be saved");
                                });
                              }
                            }).catchError((val) {
                              showMessage(context, 'There was some error');
                            })
                          }),
                  SpeedDialChild(
                      child: const Icon(Icons.info),
                      label: "About",
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text('About'),
                                content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                          'A simple drawing application created using flutter\n\nHow to use:\n'),
                                      Text('\u2022 Tap on a colour to use it'),
                                      Text(
                                          '\u2022 Double-tap on a colour to change it'),
                                      Text(
                                          '\u2022 Long-tap on a colour to remove it'),
                                      Text(
                                          '\u2022 Adjust the slider to change the width of the brush / pencil'),
                                    ]),
                                actions: [
                                  TextButton(
                                      style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.blueAccent)),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Ok',
                                          style:
                                              TextStyle(color: Colors.white)))
                                ],
                              )))
                ],
                spaceBetweenChildren: 5.0,
                backgroundColor: Colors.orange,
                activeBackgroundColor: Colors.red,
              ))
          : null,
      bottomNavigationBar: showAppBar
          ? BottomAppBar(
              child: Container(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade300
                      : const Color.fromARGB(255, 34, 42, 57),
                  padding: const EdgeInsets.all(10),
                  height: getMin(MediaQuery.of(context).size.height, 220),
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(children: [
                        Text('Brush / Eraser Size',
                            style: TextStyle(
                                color: (Theme.of(context).brightness ==
                                        Brightness.light)
                                    ? Colors.black
                                    : Colors.white)),
                        Slider(
                            min: 1,
                            max: 5,
                            value: brushSize,
                            divisions: 4,
                            onChangeStart: null,
                            onChanged: (double value) {
                              saveBrushWidth(value);
                              setState(() {
                                brushSize = value;
                                setState(() {
                                  eraserBrush = Paint()
                                    ..color = backgroundColor
                                    ..isAntiAlias = true
                                    ..strokeCap = StrokeCap.round
                                    ..strokeWidth = brushSize * 5;
                                });
                              });
                            }),
                        Text('Background Color',
                            style: TextStyle(
                                color: (Theme.of(context).brightness ==
                                        Brightness.light)
                                    ? Colors.black
                                    : Colors.white)),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: getMin(
                                      MediaQuery.of(context).size.width,
                                      20 + backColors.length * 40),
                                  maxWidth: getMax(
                                      MediaQuery.of(context).size.width,
                                      20 + backColors.length * 40),
                                ),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      for (int i = 0;
                                          i < backColors.length;
                                          i++)
                                        GestureDetector(
                                            onTap: () {
                                              updateBackground(backColors[i]);
                                              setState(() {
                                                eraserBrush = Paint()
                                                  ..color = backgroundColor
                                                  ..isAntiAlias = true
                                                  ..strokeCap = StrokeCap.round
                                                  ..strokeWidth = brushSize * 5;
                                              });
                                            },
                                            onLongPress: () {
                                              confirm(context,
                                                      'Are you sure you want to delete this color?')
                                                  .then((res) {
                                                if (res) {
                                                  if (backColors.length > 1) {
                                                    backColors.removeAt(i);
                                                    if (!backColors.contains(
                                                        backgroundColor))
                                                      updateBackground(
                                                          backColors[0]);
                                                    saveColors(
                                                        backColors, true);
                                                    setState(() {});
                                                  } else {
                                                    showMessage(context,
                                                        'Atleast one color needs to be there in the pallete');
                                                  }
                                                }
                                              });
                                            },
                                            onDoubleTap: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Update background Color'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: ColorPicker(
                                                        pickerColor:
                                                            backColors[i],
                                                        onColorChanged:
                                                            (Color newCol) {
                                                          tempCol = newCol;
                                                        },
                                                      ),
                                                      // Use Material color picker:
                                                      //
                                                      // child: MaterialPicker(
                                                      //   pickerColor: pickerColor,
                                                      //   onColorChanged: changeColor,
                                                      //   showLabel: true, // only on portrait mode
                                                      // ),
                                                      //
                                                      // Use Block color picker:
                                                      //
                                                      // child: BlockPicker(
                                                      //   pickerColor: currentColor,
                                                      //   onColorChanged: changeColor,
                                                      // ),
                                                      //
                                                      // child: MultipleChoiceBlockPicker(
                                                      //   pickerColors: currentColors,
                                                      //   onColorsChanged: changeColors,
                                                      // ),
                                                    ),
                                                    actions: <Widget>[
                                                      ElevatedButton(
                                                        style: const ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStatePropertyAll(
                                                                    Colors
                                                                        .blueAccent)),
                                                        child: const Text(
                                                            'Update Color',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                        onPressed: () {
                                                          if (backColors
                                                              .contains(
                                                                  tempCol!)) {
                                                            showMessage(context,
                                                                'Color already present in pallete');
                                                          } else {
                                                            backColors[i] =
                                                                tempCol!;
                                                            updateBackground(
                                                                backColors[i]);
                                                            saveColors(
                                                                backColors,
                                                                true);
                                                            // tempCol = null; redundant
                                                            setState(() {
                                                              eraserBrush =
                                                                  Paint()
                                                                    ..color =
                                                                        backgroundColor
                                                                    ..isAntiAlias =
                                                                        true
                                                                    ..strokeCap =
                                                                        StrokeCap
                                                                            .round
                                                                    ..strokeWidth =
                                                                        brushSize *
                                                                            5;
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ).then(
                                                    (value) => tempCol = null),
                                            child: Container(
                                              width: backColors[i] ==
                                                      backgroundColor
                                                  ? 50
                                                  : 40,
                                              height: backColors[i] ==
                                                      backgroundColor
                                                  ? 50
                                                  : 40,
                                              decoration: BoxDecoration(
                                                  color: backColors[i],
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 3)),
                                            )),
                                      GestureDetector(
                                        onTap: () => showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                                'Add new background Color'),
                                            content: SingleChildScrollView(
                                              child: ColorPicker(
                                                pickerColor: Colors.white,
                                                onColorChanged: (Color newCol) {
                                                  tempCol = newCol;
                                                },
                                              ),
                                            ),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                style: const ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors.blueAccent)),
                                                child: const Text('Add Color',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                onPressed: () {
                                                  if (backColors
                                                      .contains(tempCol!)) {
                                                    showMessage(context,
                                                        'Color already present in pallete');
                                                  } else {
                                                    backColors.add(tempCol!);
                                                    updateBackground(tempCol!);
                                                    saveColors(
                                                        backColors, true);
                                                    // tempCol = null; redundant
                                                    setState(() {
                                                      eraserBrush = Paint()
                                                        ..color =
                                                            backgroundColor
                                                        ..isAntiAlias = true
                                                        ..strokeCap =
                                                            StrokeCap.round
                                                        ..strokeWidth =
                                                            brushSize * 5;
                                                    });
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ).then((value) => tempCol = null),
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade600,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 3),
                                          ),
                                          child: const Center(
                                              child: Icon(Icons.add,
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ]))),
                        Text('Foreground Color',
                            style: TextStyle(
                                color: (Theme.of(context).brightness ==
                                        Brightness.light)
                                    ? Colors.black
                                    : Colors.white)),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: getMin(
                                      MediaQuery.of(context).size.width,
                                      20 + foreColors.length * 40),
                                  maxWidth: getMax(
                                      MediaQuery.of(context).size.width,
                                      20 + foreColors.length * 40),
                                ),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      for (int i = 0;
                                          i < foreColors.length;
                                          i++)
                                        GestureDetector(
                                            onTap: () {
                                              updateForeground(foreColors[i]);
                                              setState(() {});
                                            },
                                            onLongPress: () {
                                              confirm(context,
                                                      'Are you sure you want to delete this color?')
                                                  .then((res) {
                                                if (res) {
                                                  if (foreColors.length > 1) {
                                                    foreColors.removeAt(i);
                                                    if (!foreColors.contains(
                                                        foregroundColor))
                                                      updateForeground(
                                                          foreColors[0]);
                                                    saveColors(
                                                        foreColors, false);
                                                    setState(() {});
                                                  } else {
                                                    showMessage(context,
                                                        'Atleast one color needs to be there in the pallete');
                                                  }
                                                }
                                              });
                                            },
                                            onDoubleTap: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Update foreground Color'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: ColorPicker(
                                                        pickerColor:
                                                            foreColors[i],
                                                        onColorChanged:
                                                            (Color newCol) {
                                                          tempCol = newCol;
                                                        },
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      ElevatedButton(
                                                        style: const ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStatePropertyAll(
                                                                    Colors
                                                                        .blueAccent)),
                                                        child: const Text(
                                                            'Update Color',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                        onPressed: () {
                                                          if (foreColors
                                                              .contains(
                                                                  tempCol!)) {
                                                            showMessage(context,
                                                                'Color already present in pallete');
                                                          } else {
                                                            foreColors[i] =
                                                                tempCol!;
                                                            updateForeground(
                                                                foreColors[i]);
                                                            saveColors(
                                                                foreColors,
                                                                false);
                                                            // tempCol = null; redundant
                                                            setState(() {});
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ).then(
                                                    (value) => tempCol = null),
                                            child: Container(
                                              width: foreColors[i] ==
                                                      foregroundColor
                                                  ? 50
                                                  : 40,
                                              height: foreColors[i] ==
                                                      foregroundColor
                                                  ? 50
                                                  : 40,
                                              decoration: BoxDecoration(
                                                  color: foreColors[i],
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 3)),
                                            )),
                                      GestureDetector(
                                        onTap: () => showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                                'Add new foreground Color'),
                                            content: SingleChildScrollView(
                                              child: ColorPicker(
                                                pickerColor: Colors.white,
                                                onColorChanged: (Color newCol) {
                                                  tempCol = newCol;
                                                },
                                              ),
                                            ),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                style: const ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors.blueAccent)),
                                                child: const Text('Add Color',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                onPressed: () {
                                                  if (foreColors
                                                      .contains(tempCol!)) {
                                                    showMessage(context,
                                                        'Color already present in pallete');
                                                  } else {
                                                    foreColors.add(tempCol!);
                                                    updateForeground(tempCol!);
                                                    saveColors(
                                                        foreColors, false);
                                                    // tempCol = null; redundant
                                                    setState(() {});
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ).then((value) => tempCol = null),
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade600,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 3),
                                          ),
                                          child: const Center(
                                              child: Icon(Icons.add,
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ])))
                      ]))),
            )
          : null,
      body: MouseRegion(
        cursor: isErase ? SystemMouseCursors.cell : SystemMouseCursors.precise,
        child: GestureDetector(
            onDoubleTap: () => setState(() {
                  showAppBar = !showAppBar;
                }),
            onPanUpdate: (details) {
              setState(() {
                drawPoints.add(drawPoint(
                    offset: details.localPosition,
                    paint: Paint()
                      ..color = foregroundColor
                      ..isAntiAlias = true
                      ..strokeCap = StrokeCap.round
                      ..strokeWidth = brushSize * 5,
                    isErased: isErase));
              });
            },
            onPanEnd: (details) {
              setState(() {
                drawPoints.add(null);
              });
            },
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: backgroundColor,
                ),
                CustomPaint(
                    painter: brushTool(drawPoints, eraserBrush),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ))
              ],
            )),
      ));
}
