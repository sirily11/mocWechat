import 'package:client/Home/HomePage.dart';
import 'package:client/Login/SignInWidget.dart';
import 'package:client/Login/SignUpWidget.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  final formKey = GlobalKey<FormState>();
  int _currentMode = 0;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
  }

  success(String userId, String userName) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return HomePage(userId, userName);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_currentMode == 0 ? "Login" : "Sign Up"),
          bottom: TabBar(
            onTap: (int index) {
              setState(() {
                _currentMode = index;
              });
            },
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                text: "Login",
              ),
              Tab(
                text: "Sign Up",
              )
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            SignInWidget(28.0, success),
            SignUpWidget(28.0, success)
          ],
        ));
  }
}
