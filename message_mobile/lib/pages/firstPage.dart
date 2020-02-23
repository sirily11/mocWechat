import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/pages/home/homepage.dart';
import 'package:message_mobile/pages/login/loginpage.dart';
import 'package:provider/provider.dart';

/// If user is logined before this will
/// goto home page, otherwise, go to login page
class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool hasLoaded = false;

  @override
  void initState() {
    super.initState();
    ChatModel model = Provider.of(context, listen: false);
    model.init().then((value) {
      setState(() {
        hasLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: !hasLoaded ? Container() : renderPage(context),
    );
  }

  StatelessWidget renderPage(BuildContext context) {
    ChatModel model = Provider.of(context, listen: false);
    if (model.currentUser != null) {
      return HomePage();
    } else {
      return LoginPage();
    }
  }
}
