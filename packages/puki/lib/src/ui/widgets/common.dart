import 'package:flutter/material.dart';

Future showAlertDialog(BuildContext context, {String? title, String? content, required VoidCallback onPositive, String? positiveText}) {
  return showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text(title ?? "Confirmation"),
        content: Text(content ?? "Are you sure ?"),
        actionsPadding: EdgeInsets.fromLTRB(15, 0, 15, 15),
        actions: [
          TextButton(
            onPressed: onPositive,
            child: Text(positiveText ?? "Yes"),
          )
        ],
      );
    },
  );
}

void showSnackBar(BuildContext context, String msg, {int seconds = 1}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: Duration(seconds: seconds)));
}
