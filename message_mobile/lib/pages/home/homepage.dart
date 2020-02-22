import 'package:backdrop_widget/backdrop.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/homePageModel.dart';
import 'package:message_mobile/pages/feed/editPage.dart';
import 'package:message_mobile/pages/feed/feedPage.dart';
import 'package:message_mobile/pages/friend/addFriendPage.dart';
import 'package:message_mobile/pages/friend/friendPage.dart';
import 'package:message_mobile/pages/friend/views/addFriendView.dart';
import 'package:message_mobile/pages/home/views/chatroomList.dart';
import 'package:message_mobile/pages/home/views/menus.dart';
import 'package:message_mobile/pages/login/loginpage.dart';
import 'package:message_mobile/pages/master-detail/master_detail_container.dart';
import 'package:message_mobile/pages/master-detail/master_detail_route.dart';
import 'package:message_mobile/pages/settings/settingsPage.dart';
import 'package:message_mobile/utils/utils.dart';
import 'package:message_mobile/utils/utils.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  Widget _getPage(BuildContext context) {
    HomePageModel model = Provider.of(context);
    if (model.currentMenu == 0) {
      return ChatroomList();
    } else if (model.currentMenu == 1) {
      return FriendPage();
    } else if (model.currentMenu == 2) {
      return FeedPage();
    } else if (model.currentMenu == 3) {
      return SettingsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    HomePageModel model = Provider.of(context);
    ChatModel chatModel = Provider.of(context);
    return Stack(
      children: <Widget>[
        MasterDetailContainer(
          child: BackdropScaffold(
            actions: <Widget>[
              model.currentMenu == 2
                  ? IconButton(
                      onPressed: () {
                        pushTo(
                          context,
                          mobileView: FullPageEditorScreen(),
                          desktopView: FullPageEditorScreen(),
                        );
                      },
                      icon: Icon(CommunityMaterialIcons.file_document_edit),
                    )
                  : Container(),
              IconButton(
                onPressed: () async {
                  await chatModel.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (c) => LoginPage(),
                    ),
                  );
                },
                icon: Icon(Icons.exit_to_app),
              ),
            ],
            stickyFrontLayer: true,
            frontLayer: _getPage(context),
            backLayer: HomeMenus(),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 10,
          child: model.currentMenu == 1
              ? FloatingActionButton(
                  onPressed: () {
                    pushTo(
                      context,
                      mobileView: AddFriendPage(),
                      desktopView: AddFriendPage(),
                    );
                  },
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryIconTheme.color,
                  ),
                )
              : Container(),
        )
      ],
    );
  }
}
