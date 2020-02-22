import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/feedPageModel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/feed/views/feedList.dart';
import 'package:progress_dialog/progress_dialog.dart';
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
    FeedPageModel feedModel = Provider.of(context);
    var pr = ProgressDialog(context);
    pr.style(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      messageTextStyle: Theme.of(context).primaryTextTheme.bodyText2,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        feedModel.showReply = false;
      },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: Stack(
          children: <Widget>[
            FeedList(
              user: model.currentUser,
              feeds: model.feeds,
            ),
            feedModel.showReply
                ? Positioned(
                    bottom: 0,
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: feedModel.textEditingController,
                                onEditingComplete: () {
                                  feedModel.showReply = false;
                                },
                                decoration:
                                    InputDecoration(labelText: "Comment"),
                                autofocus: true,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                pr.show();

                                var replyComment = feedModel
                                    .getReplyComment(model.currentUser);
                                await model.replyToFeed(
                                    feedModel.feed, replyComment);
                                feedModel.comment = null;
                                feedModel.feed = null;
                                feedModel.showReply = false;
                                feedModel.textEditingController.clear();
                                await pr.hide();
                              },
                              icon: Icon(Icons.send),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
