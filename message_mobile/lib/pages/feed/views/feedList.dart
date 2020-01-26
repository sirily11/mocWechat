import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/feed/views/feedRow.dart';
import 'package:provider/provider.dart';

class FeedList extends StatelessWidget {
  final List<Feed> feeds;
  final User user;

  FeedList({@required this.feeds, @required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      reverse: true,
      itemCount: feeds.length,
      separatorBuilder: (c, i) => Divider(),
      itemBuilder: (context, index) {
        Feed feed = feeds[index];
        return FeedRow(
          user: user,
          feed: feed,
        );
      },
    );
  }
}
