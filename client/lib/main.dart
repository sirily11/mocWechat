import 'dart:io';

import 'package:client/Home/Chat/data/ChatroomObj.dart';
import 'package:client/States/SettingState.dart';
import 'package:path_provider/path_provider.dart';
import 'package:client/Login/Login.dart';
import 'package:client/States/MessageState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final ChatRoomProvider _chatRoomProvider = ChatRoomProvider();

  Future moveDataToApplicationFolder(BuildContext context) async{
    var value = await DefaultAssetBundle.of(context)
        .loadString("assets/serverSettings.json");
    final directory = await getApplicationDocumentsDirectory();
    var file = File("${directory.path}/serverSettings.json");
    return file.writeAsString(value);
  }

  @override
  Widget build(BuildContext context) {
    moveDataToApplicationFolder(context);
    return MultiProvider(
      providers: [ChangeNotifierProvider(builder: (_) => MessageState()), ChangeNotifierProvider(builder: (_) =>SettingState())],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginPage(),
      ),
    );
  }
}
