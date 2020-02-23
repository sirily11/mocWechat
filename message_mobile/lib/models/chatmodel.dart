import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:path/path.dart' as p;

const int kImageQuality = 70;

class ChatModel with ChangeNotifier {
  final String chatroomDBPath = 'chatroomDB';
  final String messageDBPath = 'messageDB';

  /// System variable
  DatabaseFactory dbFactory = databaseFactoryIo;
  Dio networkProvider;
  Database chatroomDB;
  Database messageDB;
  IOWebSocketChannel channel;

  /// Settings string
  String websocketURL;
  String httpURL;
  User currentUser;

  /// display objects
  List<Feed> feeds = [];
  List<User> chatrooms = [];
  // List<User> chatrooms = [testFriend, testFriend2];
  List<Message> messages = [];
  bool isSignedIn = false;

  ChatModel({Dio dio}) {
    // this.currentUser = testOwner;
    this.networkProvider = dio ?? Dio();
    this.init();
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.websocketURL = prefs.get("websocket");
    this.httpURL = prefs.get("http");
    // =============Database==========================
    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    var p = join(dir.path, chatroomDBPath);
    var p2 = join(dir.path, messageDBPath);
    this.chatroomDB = await dbFactory.openDatabase(p);
    this.messageDB = await dbFactory.openDatabase(p2);
  }

  /// Get message for chat room
  Future getMessages(User user) async {
    var store = intMapStoreFactory.store();
    final finder = Finder(
      sortOrders: [SortOrder("time")],
      filter: Filter.or(
        [
          Filter.and([
            Filter.equals("receiver", user.userId),
            Filter.equals("sender", currentUser.userId),
          ]),
          Filter.and([
            Filter.equals("sender", user.userId),
            Filter.equals("receiver", currentUser.userId),
          ])
        ],
      ),
    );
    final snapshots = await store.find(messageDB, finder: finder);
    var list = snapshots.map((s) => Message.fromJson(s.value)).toList();
    this.messages = list;
    notifyListeners();
  }

  /// Call this function after successfully logined
  /// Such as sign up, and login functions have been called
  Future onSuccessfullyLogin(Response response) async {
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", response.data['token']);
    this.currentUser = User.fromJson(response.data);
    isSignedIn = true;
    connectWebsocket();

    //=============== Database =====================
    final finder = Finder(
        sortOrders: [SortOrder("userName")],
        filter: Filter.equals("owner", currentUser.userId));

    var store = intMapStoreFactory.store();

    final snapshots = await store.find(chatroomDB, finder: finder);

    for (var m in snapshots) {
      // get chatroom
      var user = User.fromJson(m.value['with']);
      var matchedUser = currentUser.friends.firstWhere(
          (element) => element.userId == user.userId,
          orElse: () => null);

      final messageFinder = Finder(
        sortOrders: [SortOrder("time", false)],
        filter: Filter.or(
          [
            Filter.and([
              Filter.equals("receiver", user.userId),
              Filter.equals("sender", currentUser.userId),
            ]),
            Filter.and([
              Filter.equals("sender", user.userId),
              Filter.equals("receiver", currentUser.userId),
            ])
          ],
        ),
      );
      // get last message
      var lastMessage = await store.findFirst(messageDB, finder: messageFinder);
      matchedUser.lastMessage =
          lastMessage != null ? Message.fromJson(lastMessage.value) : null;

      this.chatrooms.add(matchedUser);
    }
  }

  void connectWebsocket() {
    channel = IOWebSocketChannel.connect(
        "$websocketURL?userID=${currentUser.userId}");
    channel.stream.listen((event) async {
      var message = Message.fromJson(JsonDecoder().convert(event));
      messages.add(message);
      // If chatroom doesn't exist
      var foundChatroom = chatrooms.firstWhere(
          (element) => element.userId == message.sender,
          orElse: () => null);
      if (foundChatroom == null) {
        var withUser = currentUser.friends.firstWhere(
            (element) => element.userId == message.sender,
            orElse: () => null);
        if (withUser != null) {
          await createNewChatroom(withUser, message: message);
        }
      } else {
        foundChatroom.lastMessage = message;
      }
      notifyListeners();
    }, onError: (err) {
      print("Connection error");
      connectWebsocket();
    }, onDone: () async {
      // if (isSignedIn) {
      //   await Future.delayed(Duration(seconds: 5));
      //   print("Websocket was closed and will reconnect");
      //   connectWebsocket();
      // }
      print("websocket was closed");
    });
  }

  Future<void> signOut() async {
    this.messages.clear();
    this.chatrooms.clear();
    this.feeds.clear();
    isSignedIn = false;
    channel.sink.close();
  }

  Future createNewChatroom(User withUser, {Message message}) async {
    var finder = Finder(filter: Filter.equals("userID", withUser.userId));
    var store = intMapStoreFactory.store();
    var record = await store.find(chatroomDB, finder: finder);
    withUser.lastMessage = message;
    if (record.isEmpty) {
      var key = await store.add(
          chatroomDB, {"owner": currentUser.userId, "with": withUser.toJson()});
      this.chatrooms.add(withUser);
      notifyListeners();
    }
  }

  Future deleteChatroom(User chatroom) async {
    var finder = Finder(
      filter: Filter.and(
        [
          Filter.equals("owner", currentUser.userId),
          Filter.equals("with.userID", chatroom.userId)
        ],
      ),
    );

    var messageFinder = Finder(
      filter: Filter.or(
        [
          Filter.and([
            Filter.equals("receiver", chatroom.userId),
            Filter.equals("sender", currentUser.userId),
          ]),
          Filter.and([
            Filter.equals("sender", chatroom.userId),
            Filter.equals("receiver", currentUser.userId),
          ])
        ],
      ),
    );

    var store = intMapStoreFactory.store();
    var record = await store.delete(chatroomDB, finder: finder);
    var messageRecord = await store.delete(messageDB, finder: messageFinder);

    print("Delete chartroom number: $record");
    print("Delete message number: $messageRecord");
    this.chatrooms.removeWhere((c) => c.userId == chatroom.userId);
    notifyListeners();
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
    var store = intMapStoreFactory.store();

    /// Send image
    if (message.type == MessageType.image) {
      message.hasUploaded = false;
      this.messages.add(message);
      notifyListeners();
      message.hasUploaded = false;
      await uploadMessageImage(message);
    } else {
      this.messages.add(message);
    }
    channel.sink.add(JsonEncoder().convert(message.toJson()));
    // Store message into local database
    await store.add(this.messageDB, message.toJson());
    var chatroom =
        this.chatrooms.firstWhere((c) => c.userId == message.receiver);
    chatroom.lastMessage = message;
    notifyListeners();
  }

  /// Upload [message] image to server
  /// This will replace [messageBody] to real url
  /// after image has uploaded
  Future uploadMessageImage(Message message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    var data = FormData.fromMap({
      "messageImage": await MultipartFile.fromFile(message.uploadFile.path,
          filename: p.basename(message.uploadFile.path))
    });

    Response response =
        await this.networkProvider.post("$httpURL/upload/messageImage",
            data: data,
            options: Options(
              headers: {"Authorization": "Bearer $token"},
            ), onReceiveProgress: (cur, total) {
      message.uploadProgress = cur / total;
      notifyListeners();
    });

    String uploadedPath = response.data['path'];
    message.messageBody = uploadedPath;
    message.hasUploaded = true;
    notifyListeners();
  }

  /// Update user data
  Future updateUser(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    Response response = await this.networkProvider.patch(
          "$httpURL/update/info",
          data: data,
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );
    var newUser = User.fromJson(response.data);
    currentUser.dateOfBirth = newUser.dateOfBirth;
    currentUser.sex = newUser.sex;
    currentUser.userName = newUser.userName;
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
      comments: [],
      content: content,
      user: currentUser,
      publishDate: DateTime.now(),
      likes: [],
    );

    var data = FormData.fromMap({
      "content": feed.content,
      "publish_date": feed.toJson()['publish_date'],
    });

    for (var i in images) {
      data.files.add(MapEntry("images", MultipartFile.fromFileSync(i.path)));
    }

    Response response = await this.networkProvider.post(
          "$httpURL/feed",
          data: data,
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );
    var nFeed = Feed.fromJson(response.data);
    feed.id = nFeed.id;

    feed.images = nFeed.images;
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
            queryParameters: {"feedID": feed.id, "commentID": comment.id},
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

  Future setAvatar(File uploadFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    var data = FormData.fromMap({
      "avatar": await MultipartFile.fromFile(
        uploadFile.path,
      )
    });

    Response response = await this.networkProvider.post(
          "$httpURL/upload/avatar",
          data: data,
          options: Options(
            headers: {"Authorization": "Bearer $token"},
          ),
        );
    this.currentUser.avatar = "$httpURL/${response.data['path']}";
    notifyListeners();
  }
}
