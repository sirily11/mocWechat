import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/chat/chatpage.dart';
import 'package:message_mobile/pages/friend/views/avatarView.dart';
import 'package:message_mobile/pages/login/views/errorDialog.dart';
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

  String _renderLastMessageText(Message message) {
    if (message == null) {
      return "";
    }
    if (message.type == MessageType.image) {
      return "[image]";
    } else {
      return message.messageBody ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          onTap: () async {
            try {
              await model.deleteChatroom(chatroom);
            } catch (err) {
              showDialog(
                context: context,
                builder: (c) => ErrorDialog(
                  content: err,
                  title: "Delete Chatroom error",
                ),
              );
            }
          },
          color: Colors.red,
          caption: "Delete",
          icon: Icons.delete,
        )
      ],
      child: ListTile(
        onTap: () async {
          pushTo(
            context,
            mobileView: ChatPage(
              friend: chatroom,
              owner: model.currentUser,
            ),
            desktopView: ChatPage(
              friend: chatroom,
              owner: model.currentUser,
            ),
          );
        },
        leading: AvatarView(
          user: chatroom,
        ),
        title: Text(
          chatroom.userName,
        ),
        subtitle: Text(_renderLastMessageText(chatroom?.lastMessage)),
        trailing: Icon(Icons.more_horiz),
      ),
    );
  }
}
