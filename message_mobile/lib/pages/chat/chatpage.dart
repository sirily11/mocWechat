import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/chat/views/message_input.dart';
import 'package:message_mobile/pages/chat/views/message_list.dart';
import 'package:message_mobile/pages/friend/freindDetailPage.dart';
import 'package:message_mobile/pages/master-detail/master_detail_container.dart';
import 'package:message_mobile/utils/utils.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  /// Owner of the chatroom
  final User owner;
  final List<Message> messages;

  /// The user who is chatting with
  final User friend;
  ChatPage({@required this.owner, @required this.friend, this.messages});

  @override
  Widget build(BuildContext context) {
    List<Message> msgs =
        (this.messages ?? Provider.of<ChatModel>(context).messages)
            .where(
              (m) =>
                  (m.sender == friend.userId && m.receiver == owner.userId) ||
                  (m.sender == owner.userId && m.receiver == friend.userId),
            )
            .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("${friend.userName}"),
        leading: BackButton(),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              pushTo(
                context,
                mobileView: FriendDetailPage(
                  self: owner,
                  friend: friend,
                ),
                desktopView: FriendDetailPage(
                  self: owner,
                  friend: friend,
                ),
              );
            },
            icon: Icon(Icons.people),
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Expanded(
              child: MessageList(
                leftUser: friend,
                rightUser: owner,
                messages: msgs,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: MessageInput(
                owner: owner,
                friend: friend,
              ),
            )
          ],
        ),
      ),
    );
  }
}
