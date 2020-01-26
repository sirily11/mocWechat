import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:shared_preferences/shared_preferences.dart';

final doc = r'[{"insert":"Zefyr"},{"insert":"\n","attributes":{"heading": 3}}]';

class ChatModel with ChangeNotifier {
  Dio networkProvider;

  String websocketURL;
  String httpURL;
  static User testFriend = User(
    userName: "test friend",
    sex: "male",
    friends: [],
    userId: "cdef",
    password: "a",
    dateOfBirth: DateTime.now(),
    lastMessage: Message(messageBody: "Hello"),
    avatar:
        "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg",
  );

  static User testFriend2 = User(
    userName: "test friend 2",
    sex: "male",
    userId: "cdef",
    password: "a",
    friends: [],
    dateOfBirth: DateTime.now(),
    lastMessage: Message(messageBody: "Hello"),
    avatar:
        "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg",
  );

  static User testOwner = User(
      dateOfBirth: DateTime.now(),
      userName: "Owner",
      userId: "abcd",
      sex: "male",
      password: "a",
      lastMessage: Message(messageBody: "Hello"),
      friends: [testFriend],
      avatar:
          "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg");

  User currentUser;
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

  ChatModel({Dio dio}) {
    // this.currentUser = testOwner;
    this.networkProvider = dio ?? Dio();
    this.init();
  }

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
    Response<List> response = await this.networkProvider.get<List>(
        "$httpURL/search/user",
        queryParameters: {"userName": userName});
    List<User> users = response.data.map((d) => User.fromJson(d)).toList();

    return users;
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

  /// Login
  Future<void> login({@required Map<String, dynamic> info}) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      Response response =
          await this.networkProvider.post("$httpURL/login", data: info);
      this.currentUser = User.fromJson(response.data);
    } on DioError catch (err) {
      throw (err.response);
    } finally {
      notifyListeners();
    }
  }

  /// Sign Up
  Future<void> signUp({@required Map<String, dynamic> info}) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      Response response =
          await this.networkProvider.post("$httpURL/add/user", data: info);
      this.currentUser = User.fromJson(response.data);
    } on DioError catch (err) {
      throw (err.response);
    } finally {
      notifyListeners();
    }
  }

  Future setURL({@required Map<String, dynamic> info}) async {
    await Future.delayed(Duration(milliseconds: 300));
    if ((info['http'] as String).endsWith("/") ||
        (info['websocket'] as String).endsWith("/")) {
      throw Exception("url should not end with /");
    }
    if (!(info['http'] as String).startsWith("http://") &&
        !(info['http'] as String).startsWith("https://")) {
      throw Exception("HTTP Server URL should start with http or https");
    }
    if (!(info['websocket'] as String).startsWith("ws")) {
      throw Exception("Websocket URL should start with ws");
    }

    this.httpURL = info['http'];
    this.websocketURL = info['websocket'];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("websocket", websocketURL);
    await prefs.setString("http", httpURL);

    await this.networkProvider.get("$httpURL/");
    return;
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.websocketURL = prefs.get("websocket");
    this.httpURL = prefs.get("http");
  }
}
