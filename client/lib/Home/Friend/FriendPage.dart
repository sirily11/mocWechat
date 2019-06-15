import 'package:client/Home/BottomNavigation.dart';
import 'package:client/Home/Chat/ChatDetail.dart';
import 'package:client/Home/Chat/data/ChatroomObj.dart';
import 'package:client/Home/Chat/data/MessageObj.dart';
import 'package:client/Home/Friend/FriendDetail.dart';
import 'package:client/Home/Friend/data/FriendObj.dart';
import 'package:client/States/MessageState.dart';
import 'package:client/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

class FriendPage extends StatefulWidget {
  final String userID;
  final String userName;
  final Function sendMessage;

  FriendPage(this.userID, this.userName, this.sendMessage);

  @override
  State<StatefulWidget> createState() {
    return FriendPageState(this.userID, this.userName, this.sendMessage);
  }
}

class FriendPageState extends State<FriendPage> {
  final String userID;
  final String userName;
  final Function sendMessage;
  final ChatRoomProvider _chatRoomProvider = ChatRoomProvider();
  List<Friend> _friends;

  FriendPageState(this.userID, this.userName, this.sendMessage);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 10), () async{
      var friends = await getFriendList();
      setState(() {
        _friends = friends;
      });
    });
  }

  Future<List<Friend>> getFriendList() async {
    var url = await getURL("get/friends", context);
    url = "$url?userID=$userID";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<Friend> friends = [];
      var data = json.decode(response.body);
      for (var d in data) {
        Friend friend = Friend.fromJson(d);
        friends.add(friend);
      }
      return friends;
    } else {
      return null;
    }
  }

  Widget renderList(List<Friend> friends) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;
          var friend = friends[index];

          return ListTile(
            onTap: () async {
              ChatRoom chatRoom = ChatRoom(sender: userID, receiver: friend.userId, receiverName: friend.userName);
              await _chatRoomProvider.open(context);
              chatRoom = await _chatRoomProvider.addChatRoom(chatRoom);
              Provider.of<MessageState>(context).chatRoom = chatRoom;
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ChatDetail(
                    userID, userName, friend, this.sendMessage);
              }));
            },
            leading: CircleAvatar(
              backgroundColor: friend.sex == "female"
                  ? Colors.pink
                  : Colors.blue[800],
              foregroundColor: Colors.white,
              child: Icon(Icons.people),
            ),
            title: Text(friends[index].userName),
          );
        },
        childCount: 2 * friends.length,
      ),
    );
  }

  /// Contact card which indicate the current user
  Widget renderContactCard() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: EdgeInsets.all(18.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.people),
                    ),
                    title: Text(userName),
                  )
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
        if(_friends == null){
          return Center(child: CircularProgressIndicator(semanticsLabel: "Loading friends",),);
        }
        return RefreshIndicator(
          onRefresh: () async{
            var friends = await getFriendList();
            setState(() {
              _friends = friends;
            });
          },
          child: CustomScrollView(
            slivers: <Widget>[
              renderContactCard(),
              renderList(_friends),
            ],
          ),
        );

  }
}
