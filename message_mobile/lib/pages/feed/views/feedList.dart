import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/feed/views/feedRow.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FeedList extends StatelessWidget {
  final List<Feed> feeds;
  final User user;

  FeedList({@required this.feeds, @required this.user});

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    return LiquidPullToRefresh(
      showChildOpacityTransition: false,
      springAnimationDurationInMilliseconds: 300,
      onRefresh: () async {
        await model.getFeeds();
      },
      child: ListView.separated(
        itemCount: feeds.length,
        separatorBuilder: (c, i) => Divider(),
        itemBuilder: (context, index) {
          Feed feed = feeds[feeds.length - index - 1];
          return FeedRow(
            user: user,
            feed: feed,
          );
        },
      ),
    );
  }
}
