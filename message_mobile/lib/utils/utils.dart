import 'package:flutter/material.dart';
import 'package:message_mobile/models/signInPageModel.dart';
import 'package:message_mobile/pages/master-detail/master_detail_container.dart';
import 'package:message_mobile/pages/master-detail/master_detail_route.dart';

List<Map<String, dynamic>> getSchema(LoginPageSelection selection) {
  switch (selection) {
    case LoginPageSelection.signUp:
      return [
        {
          "label": "User Name",
          "readonly": false,
          "extra": {},
          "name": "userName",
          "widget": "text",
          "required": true,
          "translated": false,
          "validations": {}
        },
        {
          "label": "Password",
          "readonly": false,
          "extra": {"help": "Please Enter your password", "default": ""},
          "name": "password",
          "widget": "text",
          "required": true,
          "translated": false,
          "validations": {
            "length": {"maximum": 1024}
          }
        },
        {
          "label": "sex",
          "readonly": false,
          "extra": {
            "choices": [
              {"label": "Male", "value": "male"},
              {"label": "Female", "value": "female"},
            ],
            "default": "male"
          },
          "name": "sex",
          "widget": "select",
          "required": false,
          "translated": false,
          "validations": {}
        },
        {
          "label": "Birthday",
          "readonly": false,
          "extra": {"help": "Please enter your birthday"},
          "name": "dateOfBirth",
          "widget": "datetime",
          "required": true,
          "translated": false,
          "validations": {}
        },
      ];

    case LoginPageSelection.login:
      return [
        {
          "label": "User Name",
          "readonly": false,
          "extra": {},
          "name": "userName",
          "widget": "text",
          "required": true,
          "translated": false,
          "validations": {}
        },
        {
          "label": "Password",
          "readonly": false,
          "extra": {"help": "Please Enter your password", "default": ""},
          "name": "password",
          "widget": "text",
          "required": true,
          "translated": false,
          "validations": {
            "length": {"maximum": 1024}
          }
        },
      ];
      break;
    case LoginPageSelection.setting:
      return [
        {
          "label": "Websocket URL",
          "readonly": false,
          "extra": {"help": "Websocket Server URL starts with ws://"},
          "name": "websocket",
          "widget": "text",
          "required": false,
          "translated": false,
          "validations": {}
        },
        {
          "label": "HTTP Server URL",
          "readonly": false,
          "extra": {"help": "HTTP Server URL Starts with http://"},
          "name": "http",
          "widget": "text",
          "required": false,
          "translated": false,
          "validations": {}
        },
      ];
  }
}

void pushTo(BuildContext context,
    {@required Widget mobileView, @required Widget desktopView}) {
  // while (Navigator.of(context).canPop()) {
  //   Navigator.of(context).pop();
  // }
  if (!isTablet(context)) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => mobileView,
      ),
    );
  } else {
    Navigator.of(context).push(
      DetailRoute(
        builder: (context) => desktopView,
      ),
    );
  }
}
