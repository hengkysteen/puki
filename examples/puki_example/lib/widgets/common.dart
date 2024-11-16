import 'package:flutter/material.dart';

void loading(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        content: SizedBox(height: 50, width: 50, child: Center(child: CircularProgressIndicator())),
      );
    },
  );
}

void showSnackBar(BuildContext context, String msg, {int seconds = 2}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: Duration(seconds: seconds)));
}
