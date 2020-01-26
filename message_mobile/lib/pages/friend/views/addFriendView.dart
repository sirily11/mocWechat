import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/friend/views/friendList.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

class AddFriendView extends StatefulWidget {
  @override
  _AddFriendViewState createState() => _AddFriendViewState();
}

class _AddFriendViewState extends State<AddFriendView> {
  TextEditingController controller = TextEditingController();
  String searchUserName;

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          (14),
                        ),
                      ),
                    ),
                  ),
                  controller: controller,
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    searchUserName = controller.text;
                  });
                },
              )
            ],
          ),
        ),
        Expanded(
          child: searchUserName != null
              ? FutureBuilder<List<User>>(
                  future: model.searchFriend(userName: searchUserName),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      child: snapshot.hasData
                          ? FriendList(
                              friends: snapshot.data
                                  .where(
                                    (u) => u.userId != model.currentUser.userId,
                                  )
                                  .toList(),
                              self: model.currentUser,
                            )
                          : Center(
                              child: JumpingDotsProgressIndicator(
                                fontSize: 25,
                                numberOfDots: 5,
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .body1
                                    .color,
                              ),
                            ),
                    );
                  },
                )
              : Container(),
        )
      ],
    );
  }
}
