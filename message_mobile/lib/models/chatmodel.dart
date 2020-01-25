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
    ),
    Message(
      messageBody: "abcde",
      sender: testOwner.userId,
      receiver: testFriend.userId,
    ),
    Message(
      messageBody:
          "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg",
      sender: testFriend.userId,
      receiver: testOwner.userId,
      type: MessageType.image,
    ),
    Message(
      messageBody:
          "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg",
      sender: testOwner.userId,
      receiver: testFriend.userId,
      type: MessageType.image,
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

  Future sendMessage(Message message) async {
    await Future.delayed(Duration(milliseconds: 30));
    this.messages.add(message);
    if (message.type == MessageType.image) {
      message.hasUploaded = false;
      while (message.uploadProgress <= 1) {
        await Future.delayed(Duration(milliseconds: 100));
        message.uploadProgress += 0.05;
        notifyListeners();
      }
    }
    notifyListeners();
  }
}
