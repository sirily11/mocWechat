import 'dart:convert';

import 'package:flutter/widgets.dart';

Future<String> getURL(String path, BuildContext context) async {
  var value = await DefaultAssetBundle.of(context).loadString("assets/serverSettings.json");
  final settings = json.decode(value);
  var base = settings['httpWebServer'];
  return base + path;
}

Future<String> getWebSocketURL(String userID, BuildContext context) async{
  var value = await DefaultAssetBundle.of(context).loadString("assets/serverSettings.json");
  final settings = json.decode(value);
  var base = settings['webSocketServer'];
  return "$base?userID=$userID";
}