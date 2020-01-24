import 'package:flutter/material.dart';
import 'package:json_schema_form/JSONSchemaForm.dart';
import 'package:message_mobile/models/signInPageModel.dart';
import 'package:message_mobile/utils/utils.dart';

class LoginPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return JSONSchemaForm(
      schemaName: "Sign Up",
      schema: getSchema(LoginPageSelection.login),
    );
  }
}
