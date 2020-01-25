import 'dart:convert';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/chat/views/imageView.dart';
import 'package:message_mobile/pages/feed/views/image.dart';
import 'package:message_mobile/pages/friend/views/avatarView.dart';
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
                      url: feed.images[index],
                    ),
                  ),
                );
              },
              child: Image.network(feed.images[index]),
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
            Text("${feed.likes.length}")
          ],
        )
      ],
    );
  }
}
