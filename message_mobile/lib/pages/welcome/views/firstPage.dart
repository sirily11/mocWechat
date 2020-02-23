import 'package:flutter/material.dart';

class FirstPage extends StatelessWidget {
  final bool isShowing;

  FirstPage({@required this.isShowing});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline3;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedOpacity(
          opacity: isShowing ? 1 : 0,
          duration: Duration(milliseconds: 300),
          child: Text(
            "Welcome to Open Message",
            style: titleStyle,
          ),
        ),
      ),
    );
  }
}
