import 'package:flutter/widgets.dart';

class ChatPage extends StatefulWidget {
  final String userID;

  ChatPage(this.userID);

  @override
  State<StatefulWidget> createState() {
    return ChatPageState(this.userID);
  }
}

class ChatPageState extends State<ChatPage> {
  final String userID;

  ChatPageState(this.userID);

  @override
  Widget build(BuildContext context) {
    return Container(child: Center(child: Text("Nothing here"),),);
  }
}
