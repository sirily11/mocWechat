import 'package:flutter/material.dart';
import 'package:json_schema_form/JSONSchemaForm.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/signInPageModel.dart';
import 'package:message_mobile/pages/login/views/errorDialog.dart';
import 'package:message_mobile/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class SettingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pr = ProgressDialog(context);
    pr.style(
      message: "Setting URL",
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      messageTextStyle: Theme.of(context).primaryTextTheme.bodyText2,
    );

    ChatModel model = Provider.of(context);

    return JSONSchemaForm(
      schemaName: "Settings",
      schema: getSchema(LoginPageSelection.setting),
      values: {"websocket": model.websocketURL, "http": model.httpURL},
      onSubmit: (value) async {
        try {
          pr.show();
          await model.setURL(info: value);
          pr.dismiss();
        } catch (err) {
          await pr.hide();
          showDialog(
            context: context,
            builder: (c) => ErrorDialog(
              title: "Connection Error",
              content: err.toString(),
            ),
          );
        } finally {}
      },
    );
  }
}
