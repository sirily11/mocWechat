import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_schema_form/JSONSchemaForm.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/signInPageModel.dart';
import 'package:message_mobile/pages/friend/views/avatarView.dart';
import 'package:message_mobile/utils/utils.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () async {
              File file =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
              await model.setAvatar(file);
            },
            leading: AvatarView(
              user: model.currentUser,
            ),
            title: Text("Upload Profile Image"),
          ),
          ListTile(
            onTap: () {
              TextEditingController controller =
                  TextEditingController(text: model.currentUser.userName);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Change User Info"),
                  content: Container(
                    height: 400,
                    width: 300,
                    child: JSONSchemaForm(
                      schema: getSchema(LoginPageSelection.signUp),
                      values: model.currentUser.toJson(),
                      onSubmit: (v) async {
                        await model.updateUser(v);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              );
            },
            title: Text(model.currentUser.userName),
            trailing: Icon(Icons.edit),
          ),
          SwitchListTile(
            value: false,
            title: Text("Save Data To Local"),
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
