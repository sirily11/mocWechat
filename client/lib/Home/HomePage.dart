import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:client/Home/BottomNavigation.dart';
import 'package:client/Home/Chat/ChatPage.dart';
import 'package:client/Home/Chat/data/MessageObj.dart';
import 'package:client/Home/Friend/FriendPage.dart';
import 'package:client/Home/Friend/FriendSearchPage.dart';
import 'package:client/Home/PopUpMenu.dart';
import 'package:client/Login/AlertWidget.dart';
import 'package:client/Login/Login.dart';
import 'package:client/States/MessageState.dart';
import 'package:client/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String userId;
  final String userName;

  HomePage(this.userId, this.userName);

  @override
  State<StatefulWidget> createState() {
    return HomePageState(userId, userName);
  }
}

class HomePageState extends State<HomePage> {
  final String _userId;
  final String _userName;
  WebSocket _socket;
  bool _isReConnecting = false;

  final List<Nav> _navItems = [
    Nav("Chat", Icons.chat),
    Nav("Friends", Icons.people)
  ];
  int _currentIndex = 0;

  HomePageState(this._userId, this._userName);

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _tryConnect() async {
    try {
      _socket =
          await WebSocket.connect(await getWebSocketURL(_userId, context));
      setState(() {
        _isReConnecting = false;
      });
      _socket.listen((dynamic data) {
        _onMessage(data);
      }, onError: (error) {
        showDialog(
            context: context,
            builder: (context) => CustomAlertWidget(
                "Connection error", "Cannot connect to websocket"));
      }, onDone: () {
        _socket.close();
        _socket = null;
        Future.delayed(Duration(seconds: 1), () async {
          print("Cannot connect to websocket1");
          await _onDisconnected();
        });
      });
      return true;
    } on Exception catch (err) {
      Future.delayed(Duration(seconds: 1), () async {
        print("Cannot connect to websocket2");
        await _onDisconnected();
      });
      return false;
    }
  }

  void _onMessage(dynamic data) {
      var messageState = Provider.of<MessageState>(context);
      var jsonData = json.decode(data);
      Message message = Message.fromJson(jsonData);
      messageState.addMessage(message);
      print("Get new data ${message.messageBody}");
  }

  Future _onDisconnected() async {
    setState(() {
      _isReConnecting = true;
    });
    if (_socket != null) {
      _socket = null;
      await _tryConnect();
      print("Closing socket");
      _socket.close();
    }
  }

  void addFriend() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FriendSearchPage(this._userId);
    }));
  }

  /// send message through webSocket
  void sendMessage(Message message) {
    _socket.add(json.encode(message));
  }

  /// logout, and then return to the login page
  void logout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      _socket.close();
      return LoginPage();
    }));
  }

  /// When User click on the bottom nav bar
  /// this method will be called
  /// and nav user to the right screen
  void switchTo(int nextIndex) {
    setState(() {
      _currentIndex = nextIndex;
    });
  }

  Widget renderTitle() {
    String statusText = _isReConnecting ? "-Reconnecing" : "";
    switch (_currentIndex) {
      case 0:
        return Text("Home $statusText");
        break;

      case 1:
        return Text("Friends $statusText");
        break;
    }
  }

  // ignore: missing_return
  Widget renderBodyWidget() {
    switch (_currentIndex) {
      case 0:
        return ChatPage(_userId);
        break;

      case 1:
        return FriendPage(_userId, _userName, this.sendMessage);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_socket == null) {
      _tryConnect();
    }
    return Scaffold(
      appBar: AppBar(
        title: renderTitle(),
        actions: <Widget>[
          PopUpMenu(["Logout", "Add friend"], [logout, addFriend])
        ],
      ),
      body: renderBodyWidget(),
      bottomNavigationBar: BottomNavigation(switchTo, _currentIndex, _navItems),
    );
  }
}
