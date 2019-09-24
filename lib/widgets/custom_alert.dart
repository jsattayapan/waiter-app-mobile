import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String label;
  CustomAlertDialog({this.label});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(label),
      actions: <Widget>[
        new FlatButton(
          child: Text("ปิด"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
