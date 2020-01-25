import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';

final User testOwner = User(
  userName: "Owner",
  userId: "abcd",
  lastMessage: Message(messageBody: "Hello"),
);

final User testFriend = User(
  userName: "test friend",
  userId: "cdef",
  lastMessage: Message(messageBody: "Hello"),
);

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

  List<Message> messages = [
    Message(
      messageBody: "abcde",
      sender: testFriend.userId,
      receiver: testOwner.userId,
    ),
    Message(
      messageBody: "abcde",
      sender: testOwner.userId,
      receiver: testFriend.userId,
    ),
    Message(
      messageBody: "abcde",
      sender: testFriend.userId,
      receiver: testOwner.userId,
    ),
    Message(
      messageBody: "abcde",
      sender: testOwner.userId,
      receiver: testFriend.userId,
    ),
    Message(
      messageBody: "abcde",
      sender: testFriend.userId,
      receiver: testOwner.userId,
    )
  ];
}
