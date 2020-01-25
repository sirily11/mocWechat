import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/chat/views/message_bubble.dart';

class MessageList extends StatelessWidget {
  /// List Of Messages
  final List<Message> messages;

  /// The user on the left. Every message with this user's user id
  /// will be put on the left side of the screen
  final User leftUser;

  final User rightUser;

  MessageList(
      {@required this.messages,
      @required this.leftUser,
      @required this.rightUser});

  Widget _buildLeft(Message message, BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          backgroundColor: Theme.of(context).backgroundColor,
          child: Text(
            leftUser.userName.substring(0, 1).toUpperCase(),
            style: Theme.of(context).primaryTextTheme.body1,
          ),
        ),
        MessageBubble(
          message: message,
        )
      ],
    );
  }

  Widget _buildRight(Message message, BuildContext context) {
    return Row(
      children: <Widget>[
        Spacer(),
        MessageBubble(
          message: message,
        ),
        CircleAvatar(
          backgroundColor: Theme.of(context).backgroundColor,
          child: Text(
            leftUser.userName.substring(0, 1).toUpperCase(),
            style: Theme.of(context).primaryTextTheme.body1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          Message message = messages[index];
          if (message.sender == leftUser.userId) {
            return _buildLeft(message, context);
          }
          return _buildRight(message, context);
        },
      ),
    );
  }
}
