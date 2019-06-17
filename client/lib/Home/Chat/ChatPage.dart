import 'package:client/Home/Chat/ChatDetail.dart';
import 'package:client/Home/Chat/data/ChatroomObj.dart';
import 'package:client/Home/Chat/data/MessageObj.dart';
import 'package:client/Home/Friend/data/FriendObj.dart';
import 'package:client/States/MessageState.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String userID;
  final String userName;
  final Function sendMessage;

  ChatPage(this.userID, this.userName, this.sendMessage);

  @override
  State<StatefulWidget> createState() {
    return ChatPageState(this.userID, this.userName, this.sendMessage);
  }
}

class ChatPageState extends State<ChatPage> {
  final String userID;
  final String userName;
  final Function sendMessage;
  List<ChatRoom> _chatRoom = [];

  ChatRoomProvider _chatRoomProvider = ChatRoomProvider();

  ChatPageState(this.userID, this.userName, this.sendMessage);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 10), () async {
      List<ChatRoom> chatRoom = await _getChatRoom();
      setState(() {
        _chatRoom = chatRoom;
      });

    });
  }

  Future<List<ChatRoom>> _getChatRoom() async {
    await _chatRoomProvider.open(context);
    var chatRoom = await _chatRoomProvider.getChatRoom();
    return chatRoom;
  }

  Future _removeChatRoom(ChatRoom chatRoom) async {
    await _chatRoomProvider.deleteChatRoom(chatRoom.id);
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("ChatRoom Removed"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if(_chatRoom.length == 0){
      return Container(child: Center(child: Text("Nothing here"),),);
    }
    return ListView.builder(
        itemCount: _chatRoom.length,
        itemBuilder: (context, index) {
          return ChatCard(_chatRoom[index], this.userName, this.sendMessage,
              this._removeChatRoom);
        });
  }
}

class ChatCard extends StatelessWidget {
  final ChatRoom _chatRoom;
  final String userName;
  final Function sendMessage;
  final Function remove;

  ChatCard(this._chatRoom, this.userName, this.sendMessage, this.remove);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<MessageState>(context).chatRoom = _chatRoom;
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatDetail(
              _chatRoom.sender,
              userName,
              Friend(
                  userName: _chatRoom.receiverName, userId: _chatRoom.receiver),
              this.sendMessage);
        }));
      },
      child: Dismissible(
        key: Key(_chatRoom.id.toString()),
        background: Container(color: Colors.red,),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
            remove(_chatRoom);
        },
        child: Container(
          child: Column(
            children: <Widget>[
              Divider(),
              ListTile(
                leading: CircleAvatar(
                  child: Text(_chatRoom.receiverName != null ? _chatRoom.receiverName[0].toUpperCase() : ""),
                ),
                title: Text(_chatRoom.receiverName),
                subtitle: Text(
                    _chatRoom.lastMessage == null ? "" : _chatRoom.lastMessage),
                trailing: Icon(Icons.chat)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
