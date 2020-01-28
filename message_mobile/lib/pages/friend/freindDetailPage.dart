import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/chat/chatpage.dart';
import 'package:message_mobile/pages/friend/views/avatarView.dart';
import 'package:message_mobile/pages/login/views/errorDialog.dart';
import 'package:message_mobile/utils/utils.dart';
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

  bool getIsFriend() {
    return self.friends
            .firstWhere((f) => f.userId == friend.userId, orElse: () => null) !=
        null;
  }

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    bool isFriend = getIsFriend();
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
          isFriend
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
          isFriend
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () async {
                      await model.createNewChatroom(friend);
                      pushTo(
                        context,
                        desktopView:
                            ChatPage(friend: friend, owner: model.currentUser),
                        mobileView:
                            ChatPage(friend: friend, owner: model.currentUser),
                      );
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
