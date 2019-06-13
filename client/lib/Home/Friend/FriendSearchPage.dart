import 'dart:io';

import 'package:client/Home/Friend/FriendDetail.dart';
import 'package:client/Home/Friend/FriendObj.dart';
import 'package:client/Login/AlertWidget.dart';
import 'package:client/url.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class FriendSearchPage extends StatefulWidget {
  final String userID;

  FriendSearchPage(this.userID);

  @override
  State<StatefulWidget> createState() {
    return FriendSearchPageState(userID);
  }
}

class FriendSearchPageState extends State<FriendSearchPage> {
  final String userID;
  final formKey = GlobalKey<FormState>();
  List<Friend> _friends = [];
  String searchWord;

  FriendSearchPageState(this.userID);

  Future<List<Friend>> searchFriend(String userName) async {
    String url = await getURL("search/user", context);
    url = "$url?userName=$userName";

    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<Friend> friends = [];
      var data = json.decode(response.body);
      for (var d in data) {
        var friend = Friend.fromJson(d);
        friends.add(friend);
      }
      return friends;
    } else {
      return null;
    }
  }

  Future addFriend(Friend friend, BuildContext c) async {
    String url = await getURL("add/friend", context);
    var body = {
      "user": {"_id": userID},
      "friend": {"_id": friend.userId}
    };
    final response = await http.post(url,
        body: json.encode(body),
        headers: {HttpHeaders.contentTypeHeader: "application/json"});
    if (response.statusCode == 200) {
      var friends = await searchFriend(searchWord);
      setState(() {
        _friends = friends;
      });
      Navigator.pop(c);
    } else {
      showDialog(
          context: context,
          builder: (c) =>
              CustomAlertWidget("Error", "Failed to add friend"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Friend"),
      ),
      body: Container(
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                TextField(
                    onChanged: (String userName) {
                      if (userName.length > 0) {
                        searchFriend(userName).then((List<Friend> friends) {
                          if (friends != null) {
                            setState(() {
                              searchWord = userName;
                              _friends = friends;
                            });
                          }
                        });
                      }
                    },
                    decoration: InputDecoration(labelText: "Search User")),
                Container(
                  child: Expanded(
                    child: ListView.builder(
                        itemCount: _friends.length,
                        itemBuilder: (BuildContext context, int i) {
                          return ListTile(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return FriendDetail(
                                    userID, _friends[i], addFriend);
                              }));
                            },
                            leading: CircleAvatar(
                              backgroundColor: _friends[i].sex == "female"
                                  ? Colors.pink
                                  : Colors.blue[800],
                              foregroundColor: Colors.white,
                              child: Icon(Icons.people),
                            ),
                            title: Text(_friends[i].userName),
                          );
                        }),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
