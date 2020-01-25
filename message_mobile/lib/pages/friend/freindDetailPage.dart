import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';

class FriendDetailPage extends StatelessWidget {
  /// Friend
  final User friend;

  /// The current user
  final User self;

  FriendDetailPage({@required this.friend, @required this.self});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: CircleAvatar(
              radius: 50,
              child: Text(
                friend.userName.substring(0, 1).toUpperCase(),
                style: Theme.of(context).primaryTextTheme.display3,
              ),
            ),
          ),
          Center(
            child: Text(
              friend.userName,
              style: Theme.of(context).primaryTextTheme.title,
            ),
          ),
          self.friends.contains(friend)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text("Delete Friend"),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text("Add Friend"),
                  ),
                )
        ],
      ),
    );
  }
}
