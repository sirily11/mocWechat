import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';

/// This Page is how to show list of friends on screen.
/// When any item row has been clicked,
/// it will navigate to friend detail page
class FriendList extends StatelessWidget {
  final List<User> friends;

  FriendList({this.friends});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: friends.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        User user = friends[index];
        return FriendRow(
          friend: user,
        );
      },
    );
  }
}

class FriendRow extends StatelessWidget {
  final User friend;
  FriendRow({this.friend});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("${friend.userName}"),
    );
  }
}
