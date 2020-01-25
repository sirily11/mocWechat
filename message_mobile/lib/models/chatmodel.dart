import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';

final User testFriend = User(
  userName: "test friend",
  userId: "cdef",
  lastMessage: Message(messageBody: "Hello"),
);

final User testOwner = User(
  userName: "Owner",
  userId: "abcd",
  lastMessage: Message(messageBody: "Hello"),
  friends: [testFriend],
);

class ChatModel with ChangeNotifier {
  List<User> chatrooms = [
    testFriend,
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

  /// Search friend by their [userName]
  /// This will return a list of friend
  Future<List<User>> searchFriend({@required String userName}) async {
    await Future.delayed(Duration(milliseconds: 300));
    return [testFriend];
  }

  /// Get friends
  Future<List<User>> getFriends() async {
    await Future.delayed(Duration(milliseconds: 300));
    return [testFriend];
  }
}
