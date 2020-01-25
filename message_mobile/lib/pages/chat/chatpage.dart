import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/chat/views/message_input.dart';
import 'package:message_mobile/pages/chat/views/message_list.dart';
import 'package:message_mobile/pages/master-detail/master_detail_container.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  /// Owner of the chatroom
  final User owner;

  /// The user who is chatting with
  final User friend;
  ChatPage({@required this.owner, @required this.friend});

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("${friend.userName}"),
        leading: BackButton(),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageList(
              leftUser: friend,
              rightUser: owner,
              messages: model.messages,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: MessageInput(),
          )
        ],
      ),
    );
  }
}
