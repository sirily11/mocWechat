import 'dart:io';

import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';

final doc = r'[{"insert":"Zefyr"},{"insert":"\n","attributes":{"heading": 3}}]';

final User testFriend = User(
  userName: "test friend",
  userId: "cdef",
  lastMessage: Message(messageBody: "Hello"),
  avatar:
      "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg",
);

final User testFriend2 = User(
  userName: "test friend 2",
  userId: "cdef",
  lastMessage: Message(messageBody: "Hello"),
  avatar:
      "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg",
);

final User testOwner = User(
    dateOfBirth: DateTime.now(),
    userName: "Owner",
    userId: "abcd",
    sex: "male",
    lastMessage: Message(messageBody: "Hello"),
    friends: [testFriend],
    avatar:
        "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg");

class ChatModel with ChangeNotifier {
  User currentUser = testOwner;
  //TODO: Remove this field when finished implementing request
  List<Feed> feeds = [
    Feed(
        id: "1",
        content: doc,
        publishDate: DateTime.now(),
        likes: [],
        user: testFriend,
        comments: [
          Comment(
            content: "Dark Willow So Cute",
            isReply: false,
            user: testFriend,
            replayTo: null,
            postedTime: DateTime.now(),
          ),
          Comment(
            content: "I agree",
            isReply: true,
            user: testFriend2,
            replayTo: testFriend,
            postedTime: DateTime.now(),
          )
        ],
        images: [
          "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg"
        ]),
    Feed(
        id: "2",
        content: doc,
        publishDate: DateTime.now(),
        likes: [],
        user: testFriend,
        comments: [],
        images: [
          "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg",
          "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg",
          "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg",
          "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg",
          "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg"
        ])
  ];

  List<User> chatrooms = [testFriend, testFriend2];

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

  Future updateUser(Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 300));
    var user = User.fromJson(data);
    user.userId = currentUser.userId;
    user.avatar = currentUser.avatar;
    user.friends = currentUser.friends;
    this.currentUser = user;
    notifyListeners();
  }

  Future<List<Feed>> getFeeds() async {
    await Future.delayed(Duration(milliseconds: 300));
    //TODO: Add real requests
    return feeds;
  }

  Future writeFeed(String content, List<File> images) async {
    Feed feed = Feed(
      content: content,
      id: DateTime.now().toString(),
      user: currentUser,
      publishDate: DateTime.now(),
      likes: [],
      images: images
          .map((i) =>
              "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg")
          .toList(),
    );
    feeds.add(feed);
    notifyListeners();
  }

  Future replyToFeed(Feed feed, Comment comment) async {
    await Future.delayed(Duration(milliseconds: 300));
    final Feed f = feeds.firstWhere((f) => f.id == feed.id, orElse: () => null);
    if (f != null) {
      f.comments.add(comment);
    }
    notifyListeners();
  }

  Future deleteComment(Feed feed, Comment comment) async {
    await Future.delayed(Duration(milliseconds: 300));
    final Feed f = feeds.firstWhere((f) => f.id == feed.id, orElse: () => null);
    if (f != null) {
      f.comments.remove(comment);
    }
    notifyListeners();
  }

  Future deleteFeed(Feed feed) async {
    feed.isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 2300));
    this.feeds.remove(feed);
    notifyListeners();
  }

  Future pressLike(String id) async {
    final Feed feed = feeds.firstWhere((f) => f.id == id, orElse: () => null);
    if (feed.likes.contains(currentUser.userId)) {
      await pressUnLike(id);
    } else {
      await Future.delayed(
        Duration(milliseconds: 300),
      );
      feed.likes.add(currentUser.userId);
      notifyListeners();
    }
  }

  Future pressUnLike(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    final Feed feed = feeds.firstWhere((f) => f.id == id, orElse: () => null);
    feed.likes.remove(currentUser.userId);
    notifyListeners();
  }
}
