import 'package:flutter/material.dart';
import 'package:message_mobile/pages/home/homepage.dart';

class LastPage extends StatelessWidget {
  final bool isShowing;

  LastPage({@required this.isShowing});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline3;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedOpacity(
          opacity: isShowing ? 1 : 0,
          duration: Duration(milliseconds: 300),
          child: RaisedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (c) => HomePage(),
                ),
              );
            },
            child: Text(
              "Start Chatting",
            ),
          ),
        ),
      ),
    );
  }
}
