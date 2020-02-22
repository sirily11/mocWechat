import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/feedPageModel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/feed/views/commentDialog.dart';
import 'package:message_mobile/pages/friend/views/avatarView.dart';
import 'package:provider/provider.dart';

/// Show comment. If comment is reply, then show comment to user
/// as @to. And then show comment
class CommentRow extends StatelessWidget {
  final Comment comment;
  final Feed feed;
  CommentRow({this.comment, this.feed});

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    return InkWell(
      onTap: () {
        FeedPageModel feedPageModel = Provider.of(context, listen: false);
        feedPageModel.showReply = true;
        feedPageModel.comment = comment;
        feedPageModel.feed = feed;
      },
      onLongPress: () {
        showBottomSheet(
          context: context,
          builder: (context) => ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                onTap: () async {
                  await model.deleteComment(feed, comment);
                  Navigator.pop(context);
                },
                title: Text("Delete"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                title: Text("Cancel"),
              )
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: "${comment.user.userName}: ",
                style: Theme.of(context).primaryTextTheme.bodyText1),
            comment.isReply
                ? TextSpan(
                    text: "@${comment.replyTo?.userName} ",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .bodyText2
                        .apply(color: Colors.blue),
                  )
                : TextSpan(),
            TextSpan(
                text: "${comment.content}",
                style: Theme.of(context).primaryTextTheme.bodyText1)
          ]),
        ),
      ),
    );
  }
}
