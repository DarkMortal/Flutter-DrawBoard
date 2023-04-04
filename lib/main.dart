import 'dart:async';
import 'package:flutter/material.dart';
import 'package:draw_board/widgets/drawBoard.dart';
import 'package:draw_board/models/painterClass.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter DrawBoard',
        debugShowCheckedModeBanner: false,
        scrollBehavior: MyCustomScrollBehavior(),
        themeMode: ThemeMode.system,
        theme: ThemeData(
          brightness: Brightness.light,
          // primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? super.key});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DrawBoard())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : const Color.fromARGB(255, 34, 42, 57),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  FlutterLogo(
                    size: MediaQuery.of(context).size.height,
                    textColor: Theme.of(context).brightness != Brightness.light
                        ? Colors.white
                        : const Color.fromARGB(255, 34, 42, 57),
                  ),
                  Center(
                      child: Text(
                    'Flutter Drawboard App\n\nDeveloped and maintained by Saptarshi Dey',
                    style: TextStyle(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : const Color.fromARGB(255, 34, 42, 57),
                        color: Theme.of(context).brightness != Brightness.light
                            ? Colors.white
                            : const Color.fromARGB(255, 34, 42, 57)),
                  ))
                ],
              ))),
    );
  }
}
