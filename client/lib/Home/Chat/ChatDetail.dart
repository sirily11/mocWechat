import 'package:client/Home/Chat/ChatMessage.dart';
import 'package:client/Home/Chat/MessageObj.dart';
import 'package:client/Home/Friend/FriendObj.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatDetail extends StatefulWidget {
  final String userID;
  final String userName;
  final Friend friend;

  ChatDetail(this.userID, this.userName, this.friend);

  @override
  State<StatefulWidget> createState() {
    return ChatDetailState(this.userID, this.userName, this.friend);
  }
}

class ChatDetailState extends State<ChatDetail> {
  final String userID;
  final String userName;
  final Friend friend;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [
    Message(
        messageBody: "Hello", receiverId: "sirily11", senderId: "liqiwei1111")
  ];

  ChatDetailState(this.userID, this.userName, this.friend);

  void sendMessage() {
    String text = _textEditingController.text;
    _textEditingController.clear();
    if(text.length > 0){
      setState(() {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        _messages.add(Message(
            messageBody: text, receiverId: friend.userId, senderId: userID));
      });
    }
  }

  Widget sendBox() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textEditingController,
                onSubmitted: (String s) => sendMessage(),
                decoration: InputDecoration(hintText: "Enter message here"),
              ),
            ),
            Container(
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: sendMessage,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(friend.userName),
        ),
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return ChatMessage(
                      _messages[index],
                      friend: friend,
                      me: Friend(userId: userID, userName: userName),
                    );
                  },
                ),
              ),
              Divider(),
              Container(
                child: sendBox(),
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
              )
            ],
          ),
        ));
  }
}
