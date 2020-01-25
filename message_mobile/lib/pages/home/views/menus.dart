import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:backdrop_widget/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:message_mobile/models/homePageModel.dart';
import 'package:message_mobile/models/signInPageModel.dart';
import 'package:provider/provider.dart';

class HomeMenu {
  String name;
  int index;
  HomeMenu({this.index, this.name});
}

class HomeMenus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomePageModel model = Provider.of(context);
    Color normalColor = Theme.of(context).primaryTextTheme.body1.color;
    Color highlightedColor = Theme.of(context).highlightColor;

    return BackdropNavigationBackLayer(
      onTap: (index) {
        model.currentMenu = index;
      },
      items: [
        HomeMenu(index: 0, name: "Home"),
        HomeMenu(index: 1, name: "Friend"),
        HomeMenu(index: 2, name: "Settings")
      ]
          .map(
            (s) => ListTile(
              title: Text(
                "${s.name}",
                style: Theme.of(context).primaryTextTheme.body1.apply(
                    color: s.index == model.currentMenu
                        ? highlightedColor
                        : normalColor),
              ),
            ),
          )
          .toList(),
    );
  }
}
