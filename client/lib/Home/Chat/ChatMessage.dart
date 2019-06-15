import 'package:client/Home/Chat/data/MessageObj.dart';
import 'package:client/Home/Friend/data/FriendObj.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Message's list and bubble
class ChatMessage extends StatelessWidget {
  final Message message;
  final Friend friend;
  final Friend me;

  ChatMessage(this.message, {this.friend, this.me});

  /// Render message bubble
  Widget messageTextBox(double maxWidth, Color textColor, Color backgroundColor){
    return Container(
        padding: EdgeInsets.all(3),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth * 0.6),
            child: Text(
              message.messageBody,
              style: TextStyle(color: textColor),
              maxLines: 30,
            ),
          ),
        ));
  }

  Widget renderSentMessage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          messageTextBox(width, Colors.white, Colors.blue),
          CircleAvatar(
            child: Text(
              me.userName[0].toUpperCase(),
            ),
          ),
        ],
      ),
    );
  }

  Widget renderReceivedMessage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            child: Text(friend.userName[0].toUpperCase()),
          ),
          messageTextBox(width, Colors.black, Colors.grey[300]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (message.senderId == me.userId) {
      return renderSentMessage(context);
    } else {
      return renderReceivedMessage(context);
    }
  }
}
