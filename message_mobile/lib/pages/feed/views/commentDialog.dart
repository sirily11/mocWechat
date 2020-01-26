import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:provider/provider.dart';

class CommentDialog extends StatefulWidget {
  final Feed feed;
  final Comment comment;

  CommentDialog({this.comment, this.feed});

  @override
  _CommentDialogState createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  TextEditingController controller = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    return AlertDialog(
      title: isLoading ? Text("Posting") : Text("Write your reply"),
      content: TextField(
        decoration: InputDecoration(labelText: "Comment..."),
        controller: controller,
        maxLines: 4,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text("Post"),
          onPressed: () async {
            Comment replyComment = Comment(
                content: controller.text,
                user: model.currentUser,
                postedTime: DateTime.now(),
                isReply: false,
                replayTo: null);
            if (widget.comment != null) {
              replyComment.isReply = true;
              replyComment.replayTo = widget.comment.user;
            }
            setState(() {
              isLoading = true;
            });
            await model.replyToFeed(widget.feed, replyComment);
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
