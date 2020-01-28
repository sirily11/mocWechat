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
  List<Feed> feeds = [];
  // List<Feed> feeds = [
  //   Feed(
  //       id: "1",
  //       content: doc,
  //       publishDate: DateTime.now(),
  //       likes: [],
  //       user: testFriend,
  //       comments: [
  //         Comment(
  //           content: "Dark Willow So Cute",
  //           isReply: false,
  //           user: testFriend,
  //           replayTo: null,
  //           postedTime: DateTime.now(),
  //         ),
  //         Comment(
  //           content: "I agree",
  //           isReply: true,
  //           user: testFriend2,
  //           replayTo: testFriend,
  //           postedTime: DateTime.now(),
  //         )
  //       ],
  //       images: [
  //         "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg"
  //       ]),
  //   Feed(
  //       id: "2",
  //       content: doc,
  //       publishDate: DateTime.now(),
  //       likes: [],
  //       user: testFriend,
  //       comments: [],
  //       images: [
  //         "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg",
  //         "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg",
  //         "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg",
  //         "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg",
  //         "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg"
  //       ])
  // ];

  ChatModel({Dio dio}) {
    // this.currentUser = testOwner;
    this.networkProvider = dio ?? Dio();
    this.init();
  }
  List<User> chatrooms = [];
  // List<User> chatrooms = [testFriend, testFriend2];

  List<Message> messages = [];
  // List<Message> messages = [
  //   Message(
  //     messageBody: "abcde",
  //     sender: testFriend.userId,
  //     receiver: testOwner.userId,
  //   ),
  //   Message(
  //     messageBody: "abcde",
  //     sender: testOwner.userId,
  //     receiver: testFriend.userId,
  //   ),
  //   Message(
  //     messageBody: "abcde",
  //     sender: testFriend.userId,
  //     receiver: testOwner.userId,
  //   ),
  //   Message(
  //     messageBody: "abcde",
  //     sender: testOwner.userId,
  //     receiver: testFriend.userId,
  //   ),
  //   Message(
  //     messageBody: "abcde",
  //     sender: testFriend.userId,
  //     receiver: testOwner.userId,
  //   ),
  //   Message(
  //     messageBody: "abcde",
  //     sender: testOwner.userId,
  //     receiver: testFriend.userId,
  //   ),
  //   Message(
  //     messageBody: "abcde",
  //     sender: testFriend.userId,
  //     receiver: testOwner.userId,
  //   ),
  //   Message(
  //     messageBody: "abcde",
  //     sender: testOwner.userId,
  //     receiver: testFriend.userId,
  //   ),
  //   Message(
  //     messageBody: "abcde",
  //     sender: testFriend.userId,
  //     receiver: testOwner.userId,
  //   ),
  //   Message(
  //     messageBody: "abcde",
  //     sender: testOwner.userId,
  //     receiver: testFriend.userId,
  //   ),
  //   Message(
  //     messageBody:
  //         "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg",
  //     sender: testFriend.userId,
  //     receiver: testOwner.userId,
  //     type: MessageType.image,
  //   ),
  //   Message(
  //     messageBody:
  //         "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg",
  //     sender: testOwner.userId,
  //     receiver: testFriend.userId,
  //     type: MessageType.image,
  //   )
  // ];

  /// Call this function after successfully logined
  /// Such as sign up, and login functions have been called
  Future onSuccessfullyLogin(Response response) async {
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", response.data['token']);
    this.currentUser = User.fromJson(response.data);
  }

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
    return currentUser.friends;
  }

  Future<void> addFriend(User friend) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    Response response = await this.networkProvider.post(
          "$httpURL/add/friend",
          data: {"friend": friend.toJson()},
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );
    this.currentUser.friends.add(friend);
    notifyListeners();
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

  /// Update user data
  Future updateUser(Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 300));
    var user = User.fromJson(data);
    user.userId = currentUser.userId;
    user.avatar = currentUser.avatar;
    user.friends = currentUser.friends;
    this.currentUser = user;
    notifyListeners();
  }

  /// get all user's feed
  Future<void> getFeeds() async {
    // await Future.delayed(Duration(milliseconds: 300));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    Response<List> response = await this.networkProvider.get(
          "$httpURL/feed",
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );

    this.feeds = response.data.map((d) => Feed.fromJson(d)).toList();
    notifyListeners();
  }

  /// Write feed
  Future writeFeed(String content, List<File> images) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    Feed feed = Feed(
      id: null,
      comments: [],
      content: content,
      user: currentUser,
      publishDate: DateTime.now(),
      likes: [],
      images: images
          .map((i) =>
              "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f3/f3290d49e20dbd8f02d5920f7485bd777fdb3f33_full.jpg")
          .toList(),
    );
    Response response = await this.networkProvider.post(
          "$httpURL/feed",
          data: feed.toJson(),
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );
    var nFeed = Feed.fromJson(response.data);
    feed.id = nFeed.id;
    feeds.add(feed);
    notifyListeners();
  }

  /// reply to the feed
  /// if the reply is a [comment], then comment need to be provided,
  /// otherwise, set [comment] to null
  Future replyToFeed(Feed feed, Comment comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    await Future.delayed(Duration(milliseconds: 300));
    final Feed f = feeds.firstWhere((f) => f.id == feed.id, orElse: () => null);
    if (f != null) {
      Response response = await this.networkProvider.post(
            "$httpURL/comment",
            queryParameters: {"feedID": feed.id},
            data: comment.toJson(),
            options: Options(headers: {"Authorization": "Bearer $token"}),
          );
      comment.id = response.data['_id'];
      f.comments.add(comment);
    }
    notifyListeners();
  }

  ///Delete a particlar comment,
  ///if the comment you delete is a comment's reply,
  ///then [comment] need to be provided, otherwise, set
  ///[comment] to null
  Future deleteComment(Feed feed, Comment comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    final Feed f = feeds.firstWhere((f) => f.id == feed.id, orElse: () => null);
    if (f != null) {
      Response response = await this.networkProvider.delete(
            "$httpURL/comment",
            queryParameters: {"feedID": feed.id},
            data: {"_id": comment.id},
            options: Options(headers: {"Authorization": "Bearer $token"}),
          );
      f.comments.remove(comment);
    }
    notifyListeners();
  }

  /// Delete a feed based on [feed]'s id
  Future deleteFeed(Feed feed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    feed.isLoading = true;
    notifyListeners();
    await this.networkProvider.delete(
          "$httpURL/feed",
          data: feed.toJson(),
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );
    this.feeds.removeWhere((f) => f.id == feed.id);
    notifyListeners();
  }

  /// Press like button on on feed. If the feed
  /// is already be liked by the user,
  /// then unlike it
  Future pressLike(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    final Feed feed = feeds.firstWhere((f) => f.id == id, orElse: () => null);
    if (feed.likes.contains(currentUser.userId)) {
      await pressUnLike(id);
    } else {
      await Future.delayed(
        Duration(milliseconds: 300),
      );
      await this.networkProvider.post(
            "$httpURL/feed-like",
            data: feed.toJson(),
            options: Options(
              headers: {"Authorization": "Bearer $token"},
            ),
          );
      feed.likes.add(currentUser.userId);
      notifyListeners();
    }
  }

  /// Press unlike
  Future pressUnLike(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    await Future.delayed(Duration(milliseconds: 300));
    final Feed feed = feeds.firstWhere((f) => f.id == id, orElse: () => null);
    await this.networkProvider.delete(
          "$httpURL/feed-like",
          data: feed.toJson(),
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ),
        );
    feed.likes.remove(currentUser.userId);
    notifyListeners();
  }

  /// Login
  Future<void> login({@required Map<String, dynamic> info}) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      Response response =
          await this.networkProvider.post("$httpURL/login", data: info);
      await onSuccessfullyLogin(response);
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

      await onSuccessfullyLogin(response);
    } on DioError catch (err) {
      throw (err.response);
    } finally {
      notifyListeners();
    }
  }

  /// Set up http and websocket url
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

  Future setAvatar(File uploadFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    var data = FormData.fromMap({
      "avatar": await MultipartFile.fromFile(
        uploadFile.path,
        filename:
            "${currentUser.userId}-${DateTime.now().toIso8601String()}.jpg",
      )
    });

    Response response = await this.networkProvider.post(
          "$httpURL/upload/avatar",
          data: data,
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ),
        );
    this.currentUser.avatar = "$httpURL/${response.data['data']['path']}";
    notifyListeners();
  }
}
