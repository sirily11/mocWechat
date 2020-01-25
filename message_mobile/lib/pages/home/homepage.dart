import 'package:backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:message_mobile/pages/home/views/chatroomList.dart';
import 'package:message_mobile/pages/home/views/menus.dart';
import 'package:message_mobile/pages/master-detail/master_detail_container.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MasterDetailContainer(
      child: BackdropScaffold(
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.exit_to_app),
          )
        ],
        stickyFrontLayer: true,
        frontLayer: ChatroomList(),
        backLayer: HomeMenus(),
      ),
    );
  }
}
