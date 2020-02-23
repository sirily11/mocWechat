import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:backdrop_widget/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_form/JSONSchemaForm.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/signInPageModel.dart';
import 'package:message_mobile/pages/home/homepage.dart';
import 'package:message_mobile/pages/login/views/loginpanel.dart';
import 'package:message_mobile/pages/login/views/menus.dart';
import 'package:message_mobile/pages/login/views/settingspanel.dart';
import 'package:message_mobile/pages/login/views/signuppanel.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  Widget _getPanel(LoginPageSelection selection) {
    switch (selection) {
      case LoginPageSelection.signUp:
        return SignUpPanel();
      case LoginPageSelection.login:
        return LoginPanel();
      case LoginPageSelection.setting:
        return SettingPanel();
    }
    return SignUpPanel();
  }

  @override
  Widget build(BuildContext context) {
    SignInPageModel signInPageModel = Provider.of(context);

    return BackdropScaffold(
      title: Text("Chat App"),
      stickyFrontLayer: true,
      backLayer: Menus(),
      frontLayer: _getPanel(signInPageModel.currentSelection),
    );
  }
}
