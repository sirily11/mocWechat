import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/friend/views/avatarView.dart';
import 'package:message_mobile/pages/login/views/errorDialog.dart';
import 'package:provider/provider.dart';

/// Friend Detail Page where user can see the user
/// If the friend is in the self's friend list,
/// then there will be a delete friend button,
/// otherwise, add friend button will show up.
class FriendDetailPage extends StatelessWidget {
  /// Friend
  final User friend;

  /// The current user
  final User self;

  FriendDetailPage({@required this.friend, @required this.self});

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: <Widget>[
          Center(
              child: AvatarView(
            size: 50,
            user: friend,
          )),
          Center(
            child: Text(
              friend.userName,
              style: Theme.of(context)
                  .primaryTextTheme
                  .bodyText1
                  .copyWith(fontSize: 30),
            ),
          ),
          self.friends.contains(friend)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () {
                      //TODO: Add Delete Friend function
                    },
                    child: Text("Delete Friend"),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () async {
                      try {
                        await model.addFriend(friend);
                      } catch (err) {
                        showDialog(
                          context: context,
                          builder: (c) => ErrorDialog(
                            title: "Add Friend Error",
                            content: err,
                          ),
                        );
                      }
                    },
                    child: Text("Add Friend"),
                  ),
                ),
          self.friends.contains(friend)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () {
                      //TODO: Add start chatting
                    },
                    child: Text("Start Chatting"),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
