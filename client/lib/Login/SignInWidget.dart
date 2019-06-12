import 'dart:convert';
import 'dart:io';

import 'package:client/Login/AlertWidget.dart';
import 'package:client/Login/LoginObj.dart';
import 'package:client/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class SignInWidget extends StatefulWidget {
  final double padding;
  final Function success;

  SignInWidget(this.padding, this.success);

  @override
  State<StatefulWidget> createState() {
    return SignInWidgetState(this.padding, this.success);
  }
}

class SignInWidgetState extends State<SignInWidget> {
  String _password;
  String _userName;
  final double padding;
  final formKey = GlobalKey<FormState>();
  final Function success;

  SignInWidgetState(this.padding, this.success);

  Future signInReq() async {
    var url = getURL("login");
    var body = {"userName": _userName, "password": _password};
    print(url);
    try{
      final response = await http.post(url,
          body: json.encode(body),
          headers: {HttpHeaders.contentTypeHeader: "application/json"});

      if (response.statusCode == 200) {
        var result = SignUpObj.fromJson(json.decode(response.body));
        success(result.userId, _userName);
      } else {
        var result = SignUpObj.fromJson(json.decode(response.body));
        print(result.err);
        showDialog(
            context: context,
            builder: (context) => CustomAlertWidget("Login error", result.err));
      }
    } on Exception  catch(e){
      showDialog(
          context: context,
          builder: (context) => CustomAlertWidget("Connection error", "Cannot connect to the internet"));
    }

  }

  void signIn() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      await signInReq();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(this.padding),
      child: Form(
        key: formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: "User Name"),
              onSaved: (String input) => _userName = input,
              validator: (String input) =>
                  input.length < 1 ? "Input user name" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              onSaved: (String input) => _password = input,
              validator: (String input) =>
                  input.length < 8 ? "You need at least 8 characters" : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: MaterialButton(
                    onPressed: signIn,
                    child: Text("Login"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
