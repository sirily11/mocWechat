import 'package:client/Home/BottomNavigation.dart';
import 'package:client/Home/Friend/FriendPage.dart';
import 'package:client/Home/Friend/FriendSearchPage.dart';
import 'package:client/Home/PopUpMenu.dart';
import 'package:client/Login/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  final String userId;

  HomePage(this.userId);

  @override
  State<StatefulWidget> createState() {
    return HomePageState(userId);
  }
}

class HomePageState extends State<HomePage> {
  final String _userId;
  final List<Nav> _navItems = [
    Nav("Chat", Icons.chat),
    Nav("Friends", Icons.people)
  ];
  int _currentIndex = 0;

  HomePageState(this._userId);

  void addFriend() {
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return FriendSearchPage(this._userId);
    }));
  }

  void logout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return LoginPage();
    }));
  }

  void switchTo(int nextIndex) {
    setState(() {
      _currentIndex = nextIndex;
    });
  }

  Widget renderBodyWidget(){
    switch(_currentIndex){
      case 0:
        break;

      case 1:
        print("Friend page");
        return FriendPage();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>[
          PopUpMenu(["Logout", "Add friend"], [logout, addFriend])
        ],
      ),
      body: renderBodyWidget(),
      bottomNavigationBar: BottomNavigation(switchTo, _currentIndex, _navItems),
    );
  }
}
