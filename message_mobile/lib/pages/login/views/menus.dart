import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:backdrop_widget/backdrop.dart';

import 'package:flutter/material.dart';
import 'package:message_mobile/models/signInPageModel.dart';
import 'package:provider/provider.dart';

class Menus extends StatelessWidget {
  bool hasSelected(BuildContext context, String str) {
    SignInPageModel model = Provider.of(context);
    if (str == "Sign Up" &&
        model.currentSelection == LoginPageSelection.signUp) {
      return true;
    }
    if (str == "Sign In" &&
        model.currentSelection == LoginPageSelection.login) {
      return true;
    }
    if (str == "Settings" &&
        model.currentSelection == LoginPageSelection.setting) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SignInPageModel model = Provider.of(context);
    Color normalColor = Theme.of(context).primaryTextTheme.body1.color;
    Color highlightedColor = Theme.of(context).highlightColor;

    return BackdropNavigationBackLayer(
      onTap: (index) {
        if (index == 0) {
          model.currentSelection = LoginPageSelection.signUp;
        } else if (index == 1) {
          model.currentSelection = LoginPageSelection.login;
        } else {
          model.currentSelection = LoginPageSelection.setting;
        }
      },
      items: ["Sign Up", "Sign In", "Settings"]
          .map(
            (s) => ListTile(
              title: Text(
                "$s",
                style: Theme.of(context).primaryTextTheme.body1.apply(
                    color: hasSelected(context, s)
                        ? highlightedColor
                        : normalColor),
              ),
            ),
          )
          .toList(),
    );
  }
}
