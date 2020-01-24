import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';

class ChatModel with ChangeNotifier {
  List<User> chatrooms = [
    User(
      userName: "Test 1",
      lastMessage: Message(messageBody: "Hello"),
    ),
    User(
      userName: "Test 2",
      lastMessage: Message(messageBody: "Hello world"),
    )
  ];
}
