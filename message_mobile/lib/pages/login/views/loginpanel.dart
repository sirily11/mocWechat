import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_schema_form/JSONSchemaForm.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/signInPageModel.dart';
import 'package:message_mobile/pages/home/homepage.dart';
import 'package:message_mobile/pages/login/views/errorDialog.dart';
import 'package:message_mobile/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class LoginPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pr = ProgressDialog(context);
    pr.style(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      messageTextStyle: Theme.of(context).primaryTextTheme.bodyText2,
    );

    ChatModel model = Provider.of(context);
    return JSONSchemaForm(
      schemaName: "Sign Up",
      schema: getSchema(LoginPageSelection.login),
      onSubmit: (value) async {
        try {
          pr.show();
          await model.login(info: value);
          await pr.hide();
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (c) => HomePage(),
            ),
          );
        } catch (err) {
          await pr.hide();
          showDialog(
            context: context,
            builder: (c) => ErrorDialog(
              content: err.toString(),
              title: "Sign In Error",
            ),
          );
        }
      },
    );
  }
}
