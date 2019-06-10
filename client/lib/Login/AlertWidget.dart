import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomAlertWidget extends StatelessWidget{
  final String title;
  final String message;

  CustomAlertWidget(this.title, this.message);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}