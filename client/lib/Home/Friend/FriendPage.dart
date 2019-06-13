import 'package:client/Home/BottomNavigation.dart';
import 'package:client/Home/Chat/ChatDetail.dart';
import 'package:client/Home/Chat/MessageObj.dart';
import 'package:client/Home/Friend/FriendDetail.dart';
import 'package:client/Home/Friend/FriendObj.dart';
import 'package:client/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class FriendPage extends StatefulWidget {
  final String userID;
  final String userName;
  final List<Message> messages;
  final Function sendMessage;

  FriendPage(this.userID, this.userName, this.messages, this.sendMessage);

  @override
  State<StatefulWidget> createState() {
    return FriendPageState(this.userID, this.userName, this.messages, this.sendMessage);
  }
}

class FriendPageState extends State<FriendPage> {
  final String userID;
  final String userName;
  final List<Message> _messages;
  final Function sendMessage;

  FriendPageState(this.userID, this.userName, this._messages, this.sendMessage);

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

          return ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ChatDetail(userID, userName, friends[index], this._messages, this.sendMessage);
              }));
            },
            leading: CircleAvatar(
              backgroundColor: friends[index].sex == "female"
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
    return FutureBuilder(
      future: getFriendList(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        List<Friend> friends = snapshot.data;
        return CustomScrollView(
          slivers: <Widget>[
            renderContactCard(),
            renderList(friends),
          ],
        );
      },
    );
  }
}
