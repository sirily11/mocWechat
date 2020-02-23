import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_schema_form/JSONSchemaForm.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/signInPageModel.dart';
import 'package:message_mobile/pages/friend/views/avatarView.dart';
import 'package:message_mobile/pages/login/views/errorDialog.dart';
import 'package:message_mobile/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);
    var pr = ProgressDialog(context);
    pr.style(
      message: "Setting URL",
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      messageTextStyle: Theme.of(context).primaryTextTheme.bodyText2,
    );
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () async {
              try {
                File file = await ImagePicker.pickImage(
                    source: ImageSource.gallery, imageQuality: kImageQuality);
                if (file != null) {
                  pr.show();
                  await model.setAvatar(file);
                  await Future.delayed(Duration(milliseconds: 200));
                  await pr.hide();
                }
              } catch (err) {
                showDialog(
                  context: context,
                  builder: (c) => ErrorDialog(
                    content: err.toString(),
                    title: "Update avatar error",
                  ),
                );
              }
            },
            leading: AvatarView(
              user: model.currentUser,
            ),
            title: Text("Upload Profile Image"),
          ),
          ListTile(
            onTap: () async {
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
                        try {
                          await model.updateUser(v);
                          Navigator.pop(context);
                        } catch (err) {
                          await showDialog(
                            context: context,
                            builder: (c) => ErrorDialog(
                              content: err.response.data['errmsg'].toString(),
                              title: "Update info error",
                            ),
                          );
                        }
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
