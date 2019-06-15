import 'dart:convert';
import 'dart:io';

import 'package:client/States/SettingState.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingTestCard extends StatelessWidget {
  Widget _testResult(String type, String address, String port,
      BuildContext context, int result) {
    Widget resultIndicator;
    switch (result) {
      case -1:
        resultIndicator = Icon(Icons.error, size: 23,color: Colors.red,);
        break;
      case 1:
        resultIndicator = CircleAvatar(child: Icon(Icons.done, size: 13),radius: 10,backgroundColor: Colors.green,);
        break;
      default:
        resultIndicator =
            SizedBox(height: 10, width: 10, child: CircularProgressIndicator(strokeWidth: 2,));
    }

    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Text(
            "$type:  $address:$port",
            style: Theme.of(context).textTheme.subhead,
          ),
          Padding(
            padding: EdgeInsets.all(4),
            child: resultIndicator,
          )
        ],
      ),
    );
  }

  void _set(SettingState settingState, BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    var file = File("${directory.path}/serverSettings.json");
    var data = json.encode(settingState);
    await file.writeAsString(data);
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Config has been wrote"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var settingState = Provider.of<SettingState>(context);
    return AnimatedOpacity(
      opacity: settingState.isSet ? 1.0 : 0.0,
      duration: Duration(milliseconds: 200),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Test Result",
                style: Theme.of(context).textTheme.title,
              ),
            ),
            _testResult(
                "HTTP",
                settingState.httpAddress,
                settingState.httpPort.toString(),
                context,
                settingState.isHttpConnect),
            _testResult(
                "WebSocket",
                settingState.socketAddress,
                settingState.socketPort.toString(),
                context,
                settingState.isWebSocketConnect),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RaisedButton(
                    onPressed: (){
                      if(settingState.isWebSocketConnect == 1 && settingState.isHttpConnect == 1){
                        return this._set(settingState, context);
                      }
                    },
                    child: Text("Set"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
