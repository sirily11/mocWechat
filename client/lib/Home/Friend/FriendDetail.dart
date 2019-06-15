import 'package:client/Home/Friend/data/FriendObj.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FriendDetail extends StatelessWidget {
  final String userID;
  final Friend friend;
  final Function addFriend;

  FriendDetail(this.userID, this.friend, this.addFriend);

  Widget listRow(String title, String subtitle) {
    if (subtitle == null) {
      subtitle = "Empty";
    }
    return ListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.blueAccent)));
  }

  @override
  Widget build(BuildContext context) {
    print(friend.friends == null || (!friend.friends.contains(userID) &&
            !friend.userId.contains(userID)));
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(friend.userName),
              centerTitle: true,
              background: Center(
                  child: CircleAvatar(
                child: Icon(
                  Icons.people,
                  size: 50,
                ),
                radius: 50.0,
              )),
            ),
          ),
          SliverFillRemaining(
            child: ListView(
              children: <Widget>[
                listRow("Date Of Birth", friend.dateOfBirth),
                Divider(),
                listRow("User ID", friend.userId),
                Divider(),
                listRow("Description", friend.description),
                Divider(),
                // If user is your friend
                // Or user is yourself
                // then don't display the add friend button
                friend.friends == null ||
                        (!friend.friends.contains(userID) &&
                            !friend.userId.contains(userID))
                    ? MaterialButton(
                        onPressed: () {
                          addFriend(friend, context);
                        },
                        child: Text(
                          "Add Friend",
                          style: TextStyle(color: Colors.pink),
                        ),
                      )
                    : Container()
              ],
            ),
          )
        ],
      ),
    );
  }
}
