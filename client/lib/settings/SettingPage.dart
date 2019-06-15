import 'package:client/settings/SettingConfigCard.dart';
import 'package:client/settings/SettingTestCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setting"),
      ),
      body: ListView(
        children: <Widget>[
          SettingConfigCard(),
          SettingTestCard()
        ],
      )
    );
  }
}
