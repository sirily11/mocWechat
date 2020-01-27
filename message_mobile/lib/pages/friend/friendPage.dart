import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/friend/views/friendList.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

class FriendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChatModel chatModel = Provider.of(context);
    return FutureBuilder<List<User>>(
      future: chatModel.getFriends(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        return AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          child: snapshot.hasData
              ? FriendList(
                  friends: snapshot.data,
                  self: chatModel.currentUser,
                )
              : Center(
                  child: JumpingDotsProgressIndicator(
                    fontSize: 25,
                    numberOfDots: 5,
                    color: Theme.of(context).primaryTextTheme.bodyText1.color,
                  ),
                ),
        );
      },
    );
  }
}
