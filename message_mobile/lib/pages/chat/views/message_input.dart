import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          side: BorderSide(width: 0), borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
