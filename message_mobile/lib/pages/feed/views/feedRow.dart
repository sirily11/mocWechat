import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/feedPageModel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/chat/views/imageView.dart';
import 'package:message_mobile/pages/feed/views/commentDialog.dart';
import 'package:message_mobile/pages/feed/views/commentList.dart';
import 'package:message_mobile/pages/feed/views/image.dart';
import 'package:message_mobile/pages/friend/views/avatarView.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';

class FeedRow extends StatelessWidget {
  final Feed feed;
  final User user;

  FeedRow({@required this.feed, @required this.user});

  Delta getDelta(doc) {
    return Delta.fromJson(json.decode(doc) as List);
  }

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    FeedPageModel feedPageModel = Provider.of(context);
    var pr = ProgressDialog(context);
    pr.style(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      messageTextStyle: Theme.of(context).primaryTextTheme.bodyText2,
    );

    return Column(
      children: <Widget>[
        ListTile(
          leading: AvatarView(
            user: feed.user,
          ),
          title: Text("@${feed.user.userName}"),
          subtitle: ZefyrView(
            document: NotusDocument.fromJson(
              jsonDecode(feed.content),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: StaggeredGridView.countBuilder(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: feed.images.length,
            staggeredTileBuilder: (index) => StaggeredTile.count(1, 1),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (c) => ImageView(
                      url: "${model.httpURL}/${feed.images[index]}",
                    ),
                  ),
                );
              },
              child: CachedNetworkImage(
                imageUrl: "${model.httpURL}/${feed.images[index]}",
              ),
            ),
          ),
        ),
        Row(
          children: <Widget>[
            IconButton(
              color: feed.likes.contains(user.userId)
                  ? Colors.red
                  : Theme.of(context).disabledColor,
              onPressed: () async {
                await model.pressLike(feed.id);
              },
              icon: Icon(CommunityMaterialIcons.thumb_up),
            ),
            Text("${feed.likes.length}"),
            IconButton(
              icon: Icon(Icons.comment),
              onPressed: () async {
                feedPageModel.showReply = true;
                feedPageModel.feed = feed;
                feedPageModel.comment = null;
              },
            ),
            feed.user.userId == user.userId
                ? IconButton(
                    onPressed: () async {
                      await model.deleteFeed(feed);
                    },
                    icon: Icon(Icons.delete),
                  )
                : Container(),
            Spacer(),
            feed.isLoading
                ? JumpingDotsProgressIndicator(
                    color: Theme.of(context).primaryTextTheme.bodyText2.color,
                    fontSize: 27,
                  )
                : Container(),
            SizedBox(
              width: 10,
            )
          ],
        ),
        feed.comments.length > 0 ? Divider() : Container(),
        CommentList(
          feed: feed,
          comments: feed.comments,
        )
      ],
    );
  }
}
