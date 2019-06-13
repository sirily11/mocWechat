import 'dart:convert';
import 'dart:io';

import 'package:client/Login/AlertWidget.dart';
import 'package:client/Login/LoginObj.dart';
import 'package:client/url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class SignUpWidget extends StatefulWidget {
  final double padding;
  final Function success;

  SignUpWidget(this.padding, this.success);

  @override
  State<StatefulWidget> createState() {
    return SignUpWidgetState(padding, success);
  }
}

class SignUpWidgetState extends State<SignUpWidget> {
  String _password;
  String _userName;
  final formKey = GlobalKey<FormState>();
  final List<String> _sex = ["Male", "Female"];

  // Padding for the widget
  final double padding;
  // Success
  final Function success;

  DateTime _selectedDate = DateTime.now();
  int _selectedSex = -1;
  bool _sexWarning = true;
  bool _dateOfBirthWarning = true;

  SignUpWidgetState(this.padding, this.success);

  // ignore: missing_return
  Future<SignUpObj> signUpReq() async {
    var url = await getURL("add/user", context);
    var body = {
      "userName": _userName,
      "password": _password,
      "dateOfBirth":
          "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}",
      "sex": _sex[_selectedSex]
    };
    try{
      final response = await http.post(url,
          body: json.encode(body),
          headers: {HttpHeaders.contentTypeHeader: "application/json"});

      if (response.statusCode == 200) {
        var result = SignUpObj.fromJson(json.decode(response.body));
        success(result.userId, _userName);
      } else {
        var result = SignUpObj.fromJson(json.decode(response.body));
        showDialog(
            context: context,
            builder: (context) => CustomAlertWidget("Error", result.err));
      }
    } on Exception catch(err){
      showDialog(
          context: context,
          builder: (context) => CustomAlertWidget("Connection error", "Cannot connect to the internet"));
    }

  }

  Future showSexPicker(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 220.0,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MaterialButton(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
                Expanded(
                    child: CupertinoPicker(
                        itemExtent: 40,
                        magnification: 1.5,
                        scrollController: FixedExtentScrollController(
                            initialItem: _selectedSex),
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            _sexWarning = false;
                            _selectedSex = index;
                          });
                        },
                        children: _sex.map((String s) {
                          return Center(
                            child: Text(
                              s,
                              style: TextStyle(fontSize: 19),
                            ),
                          );
                        }).toList()))
              ],
            ),
          );
        });
  }

  Future<Null> showBirthdayPicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1970),
        lastDate: DateTime.now());
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _dateOfBirthWarning = false;
        _selectedDate = picked;
      });
    }
  }

  void signUp() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (!_dateOfBirthWarning && !_sexWarning) {
        await signUpReq();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      child: Form(
        key: formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  labelText: "User Name",
                  helperText: "Your user name should not include space or special charcter"),
              onSaved: (String input) => _userName = input,
              validator: (String input) =>
                  input.length < 1 ? "Username not vaild" : null,
            ),
            TextFormField(
              autovalidate: true,
              decoration: InputDecoration(
                  labelText: "Password", helperText: "Your password should at least 8 characters"),
              obscureText: true,
              onSaved: (String input) => _password = input,
              validator: (String input) =>
                  input.length < 8 ? "You need at least 8 characters" : null,
            ),
            InkWell(
                onTap: () => showBirthdayPicker(context),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 8, 8),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.date_range,
                        color: Colors.blue,
                      ),
                      Text(
                        "Date of birth ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}",
                        style: TextStyle(
                            color: _dateOfBirthWarning
                                ? Colors.red
                                : Colors.black),
                      )
                    ],
                  ),
                )),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 8, 8),
              child: InkWell(
                onTap: () => showSexPicker(context),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.developer_board,
                      color: Colors.blue,
                    ),
                    Text(
                      _selectedSex == -1 ? "Sex:" : "Sex:${_sex[_selectedSex]}",
                      style: TextStyle(
                          color: _sexWarning ? Colors.red : Colors.black),
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: MaterialButton(
                    onPressed: signUp,
                    child: Text("Sign Up"),
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
