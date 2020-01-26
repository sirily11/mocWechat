import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/feed/views/commentRow.dart';

class CommentList extends StatelessWidget {
  final List<Comment> comments;
  final Feed feed;

  CommentList({this.comments, @required this.feed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        separatorBuilder: (c, i) => Container(),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: comments.length,
        itemBuilder: (context, index) {
          return CommentRow(comment: comments[index], feed: feed);
        },
      ),
    );
  }
}
