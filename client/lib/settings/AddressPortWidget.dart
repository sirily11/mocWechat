import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:client/States/SettingState.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:client/settings/SettingPage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddressPortSetting extends StatelessWidget {
  final String addressText;
  final String portText;
  final TextEditingController addressController;
  final TextEditingController portController;
  final double padding;

  AddressPortSetting(this.addressText, this.portText, this.addressController,
      this.portController,
      {this.padding = 10});

  @override
  Widget build(BuildContext context) {
    portController.addListener((){
      var provider = Provider.of<SettingState>(context);
      provider.isSet = false;
    });

    addressController.addListener((){
      var provider = Provider.of<SettingState>(context);
      provider.isSet = false;
      provider.set();
    });

    return Row(
      children: <Widget>[
        Flexible(
          flex: 6,
          child: Padding(
              padding: EdgeInsets.all(this.padding),
              child: TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                    labelText: addressText,
                    labelStyle: TextStyle(fontSize: 15)),
              )),
        ),
        Flexible(
          flex: 4,
          child: Padding(
              padding: EdgeInsets.all(this.padding),
              child: TextFormField(
                controller: portController,
                decoration: InputDecoration(
                  labelText: portText,
                  labelStyle: TextStyle(fontSize: 15),
                ),
                keyboardType: TextInputType.number,
              )),
        )
      ],
    );
  }
}