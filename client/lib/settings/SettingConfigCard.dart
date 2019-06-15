import 'dart:convert';
import 'package:client/settings/AddressPortWidget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:client/States/SettingState.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingConfigCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingConfigCardState();
  }
}

class SettingConfigCardState extends State<SettingConfigCard> {
  final TextEditingController _httpAddress = TextEditingController();
  final TextEditingController _webSocket = TextEditingController();
  final TextEditingController _httpPort = TextEditingController();
  final TextEditingController _webSocketPort = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 20), () {
      getSetting(context);
    });
  }

  Future _httpTest() async {
    var provider = Provider.of<SettingState>(context);
    var url = "${provider.httpAddress}:${provider.httpPort}";
    try {
      await http.get(url);
      provider.isHttpConnect = 1;
      provider.set();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("HTTP Connected"),
      ));
    } on Exception catch (err) {
      provider.isHttpConnect = -1;
      provider.set();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Cannot connect to the HTTP Server"),
      ));
    }
  }

  Future _webSocketTest() async {
    var provider = Provider.of<SettingState>(context);
    var url = "${provider.socketAddress}:${provider.socketPort}";
    try {
      await WebSocket.connect(url);
      provider.isWebSocketConnect = 1;
      provider.set();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("WebSocket Connected"),
      ));
    } on Exception catch (err) {
      provider.isWebSocketConnect = -1;
      provider.set();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Cannot connect to the webSocket server"),
      ));
    }
  }

  _submit(BuildContext context) async {
    var provider = Provider.of<SettingState>(context);
    provider.httpAddress = _httpAddress.text;
    provider.socketAddress = _webSocket.text;
    provider.socketPort = int.parse(_webSocketPort.text);
    provider.httpPort = int.parse(_httpPort.text);
    provider.isSet = true;
    provider.isHttpConnect = -1;
    provider.isWebSocketConnect = -1;
    provider.set();
    Future.delayed(Duration(milliseconds: 400), () async {
      await _httpTest();
      await _webSocketTest();
    });
  }

  Future getSetting(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      var file = File("${directory.path}/serverSettings.json");
      var value = await file.readAsString();
      final settings = json.decode(value);

      String http = settings['httpWebServer'];
      int httpPort = settings['httpPort'];
      String webSocket = settings['webSocketServer'];
      int webSocketPort = settings['webSocketPort'];
      _httpAddress.text = http;
      _httpPort.text = httpPort.toString();
      _webSocket.text = webSocket;
      _webSocketPort.text = webSocketPort.toString();
      return true;
    } on Exception catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          "Config HTTP Server and WebSocket Server",
          style: Theme.of(context).textTheme.subhead,
          textAlign: TextAlign.start,
        ),
        AddressPortSetting(
            "HTTP Address", "HTTP Port", _httpAddress, _httpPort),
        AddressPortSetting(
            "WebSocket Address", "WebSocket Port", _webSocket, _webSocketPort),
        Text(
          "Note: WebSokcet is the server to do the real-time communication between "
          "server and client. ",
          style: Theme.of(context).textTheme.caption,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RaisedButton(
                onPressed: () => _submit(context),
                child: Text("Submit"),
              ),
            ),
          ],
        )
      ],
    ));
  }
}
