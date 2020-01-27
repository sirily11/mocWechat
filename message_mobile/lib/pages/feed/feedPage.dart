import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/feed/views/feedList.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    ChatModel model = Provider.of(context, listen: false);
    model.getFeeds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      child: FeedList(
        user: model.currentUser,
        feeds: model.feeds,
      ),
    );
  }
}
