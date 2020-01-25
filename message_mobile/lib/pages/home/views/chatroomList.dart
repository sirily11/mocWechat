import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/chat/chatpage.dart';
import 'package:message_mobile/pages/master-detail/master_detail_container.dart';
import 'package:message_mobile/pages/master-detail/master_detail_route.dart';
import 'package:message_mobile/utils/utils.dart';
import 'package:provider/provider.dart';

class ChatroomList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    return ListView.separated(
      itemCount: model.chatrooms.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        User chatroom = model.chatrooms[index];
        return ChatroomListRow(
          chatroom: chatroom,
        );
      },
    );
  }
}

class ChatroomListRow extends StatelessWidget {
  final User chatroom;

  ChatroomListRow({this.chatroom});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Colors.red,
          caption: "Delete",
          icon: Icons.delete,
        )
      ],
      child: ListTile(
        onTap: () {
          pushTo(
            context,
            mobileView: ChatPage(
              friend: testFriend,
              owner: testOwner,
            ),
            desktopView: ChatPage(
              friend: testFriend,
              owner: testOwner,
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).backgroundColor,
          child: Text(chatroom.userName.substring(0, 1),
              style: Theme.of(context).primaryTextTheme.body2),
        ),
        title: Text(
          chatroom.userName,
        ),
        subtitle: Text(chatroom.lastMessage.messageBody),
        trailing: Icon(Icons.more_horiz),
      ),
    );
  }
}
