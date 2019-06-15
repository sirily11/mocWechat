import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';


Future<String> getURL(String path, BuildContext context) async {
  final directory = await getApplicationDocumentsDirectory();
  var file = File("${directory.path}/serverSettings.json");
  var value = await file.readAsString();
  final settings = json.decode(value);
  var base = settings['httpWebServer'];
  var port = settings['httpPort'];
  return "$base:$port/$path";
}

Future<String> getWebSocketURL(String userID, BuildContext context) async{
  final directory = await getApplicationDocumentsDirectory();
  var file = File("${directory.path}/serverSettings.json");
  var value = await file.readAsString();final settings = json.decode(value);
  var base = settings['webSocketServer'];
  var port = settings['webSocketPort'];
  return "$base:$port?userID=$userID";
}