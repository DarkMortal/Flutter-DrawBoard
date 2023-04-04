import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showMessage(BuildContext context, String message) {
  if (Platform.isAndroid) {
    Fluttertoast.showToast(
      msg: message,
      fontSize: 18,
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blueAccent)),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

Future<bool> confirm(BuildContext context, String message) async {
  return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(message),
            actions: [
              TextButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.blueAccent)),
                  onPressed: () => Navigator.of(context).pop(true),
                  child:
                      const Text('Yes', style: TextStyle(color: Colors.white))),
              TextButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.blueAccent)),
                  onPressed: () => Navigator.of(context).pop(false),
                  child:
                      const Text('No', style: TextStyle(color: Colors.white)))
            ],
          ));
}
