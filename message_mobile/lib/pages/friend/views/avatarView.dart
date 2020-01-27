import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:provider/provider.dart';

class AvatarView extends StatelessWidget {
  final User user;
  final double size;

  AvatarView({this.user, this.size});

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    return CircleAvatar(
      radius: size,
      backgroundImage: user.avatar != null
          ? NetworkImage(user.avatar.startsWith("http")
              ? user.avatar
              : "${model.httpURL}/${user.avatar}")
          : null,
      child: user.avatar == null
          ? Text(
              user.userName.substring(0, 1).toUpperCase(),
              style: Theme.of(context).primaryTextTheme.bodyText2,
            )
          : null,
    );
  }
}
