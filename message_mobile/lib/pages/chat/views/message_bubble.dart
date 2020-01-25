import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final double maxWidth = 300;
  final bubbleColor = Colors.blue;

  MessageBubble({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth * 0.6),
          child: Text(
            message.messageBody,
            style: Theme.of(context).primaryTextTheme.body1,
            maxLines: 30,
          ),
        ),
      ),
    );
  }
}
