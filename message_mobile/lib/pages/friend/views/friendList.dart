import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/friend/freindDetailPage.dart';
import 'package:message_mobile/utils/utils.dart';
import 'package:provider/provider.dart';

/// This Page is how to show list of friends on screen.
/// When any item row has been clicked,
/// it will navigate to friend detail page
class FriendList extends StatelessWidget {
  final List<User> friends;
  final User self;

  FriendList({@required this.friends, @required this.self});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: friends.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        User user = friends[index];
        return FriendRow(
          friend: user,
          self: this.self,
        );
      },
    );
  }
}

class FriendRow extends StatelessWidget {
  final User friend;
  final User self;
  FriendRow({this.friend, this.self});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        pushTo(
          context,
          mobileView: FriendDetailPage(
            self: self,
            friend: friend,
          ),
          desktopView: FriendDetailPage(
            self: self,
            friend: friend,
          ),
        );
      },
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).backgroundColor,
        child: Text(friend.userName.substring(0, 1).toUpperCase(),
            style: Theme.of(context).primaryTextTheme.body2),
      ),
      title: Text("${friend.userName}"),
    );
  }
}
