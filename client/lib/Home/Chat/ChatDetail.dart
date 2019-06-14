import 'dart:async';
import 'dart:convert';
import 'package:client/Home/Chat/ChatMessage.dart';
import 'package:client/Home/Chat/data/MessageObj.dart';
import 'package:client/Home/Friend/FriendObj.dart';
import 'package:client/Login/AlertWidget.dart';
import 'package:client/States/MessageState.dart';
import 'package:client/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ChatDetail extends StatefulWidget {
  final String userID;
  final String userName;
  final Friend friend;
  final Function sendMessage;

  ChatDetail(this.userID, this.userName, this.friend, this.sendMessage);

  @override
  State<StatefulWidget> createState() {
    return ChatDetailState(this.userID, this.userName, this.friend, this.sendMessage);
  }
}

class ChatDetailState extends State<ChatDetail> {
  final String userID;
  final String userName;
  final Friend friend;
  final Function sendMessage;

  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatDetailState(this.userID, this.userName, this.friend, this.sendMessage);

  @override
  void dispose() {
    _onClose();
    super.dispose();
  }

  void _onClose(){
//    var messageState = Provider.of<MessageState>(context);
//     messageState.messages.removeWhere((message){
//      message.senderId == userID && message.receiverId == friend.userId;
//    });
  }

  void _sendMessage() {
    String text = _textEditingController.text;
    _textEditingController.clear();
    if (text.length > 0) {
      setState(() {
        var now = DateTime.now();
        var message = Message(
            messageBody: text,
            receiverId: friend.userId,
            senderId: userID,
            time: now);
        Provider.of<MessageState>(context).addMessage(message);
        sendMessage(message);
//        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
                onSubmitted: (String s) => _sendMessage(),
                decoration: InputDecoration(hintText: "Enter message here"),
              ),
            ),
            Container(
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageState = Provider.of<MessageState>(context);
    Timer(Duration(milliseconds: 10), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
    return Scaffold(
        appBar: AppBar(
          title: Text(friend.userName),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  controller: _scrollController,
                  itemCount: messageState.messages.length,
                  itemBuilder: (context, index) {
                      return ChatMessage(
                       messageState.messages[index],
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
