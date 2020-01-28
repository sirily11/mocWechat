import 'dart:io';

import 'package:flutter/material.dart';

enum MessageType { image, video, text, unknown }

class User {
  DateTime dateOfBirth;
  List<User> friends;
  String password;
  String sex;
  String userId;
  String userName;
  Message lastMessage;
  String avatar;

  User({
    @required this.dateOfBirth,
    @required this.friends,
    @required this.password,
    @required this.sex,
    @required this.userId,
    @required this.userName,
    this.lastMessage,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
      dateOfBirth: json["dateOfBirth"] == null
          ? null
          : DateTime.parse(json["dateOfBirth"]),
      friends: json["friends"] == null
          ? null
          : List<User>.from(json["friends"].map((x) => User.fromJson(x))),
      password: json["password"] == null ? null : json["password"],
      sex: json["sex"] == null ? null : json["sex"],
      userId: json["userID"] == null ? json['_id'] : json["userID"],
      userName: json["userName"] == null ? null : json["userName"],
      lastMessage: json['lastMessage'] == null ? null : json['lastMessage'],
      avatar: json['avatar']);

  Map<String, dynamic> toJson() => {
        "_id": userId,
        "dateOfBirth":
            dateOfBirth == null ? null : dateOfBirth.toIso8601String(),
        "friends": friends == null
            ? null
            : List<dynamic>.from(friends.map((x) => x.toJson())),
        "password": password == null ? null : password,
        "sex": sex == null ? null : sex,
        "userID": userId == null ? null : userId,
        "userName": userName == null ? null : userName,
        "avatar": avatar,
      };
}

class Message {
  String messageBody;
  String receiver;
  String receiverName;
  String sender;
  DateTime time;
  MessageType type;

  /// Only use this value for image, video
  bool hasUploaded = true;
  double uploadProgress = 0;
  File uploadFile;

  Message({
    this.messageBody,
    this.receiver,
    this.receiverName,
    this.sender,
    this.time,
    this.type = MessageType.text,
    this.uploadFile,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    MessageType _messageType = MessageType.values.firstWhere(
        (e) => e.toString() == "MessageType.${json['messageType']}",
        orElse: () => MessageType.text);
    return Message(
        messageBody: json["messageBody"],
        receiver: json["receiver"],
        receiverName: json["receiverName"],
        sender: json["sender"],
        time: DateTime.parse(json["time"]),
        type: _messageType);
  }

  Map<String, dynamic> toJson() => {
        "messageBody": messageBody,
        "receiver": receiver,
        "receiverName": receiverName,
        "sender": sender,
        "time": time?.toIso8601String(),
        "messageType": type.toString(),
      };
}

class Feed {
  List<Comment> comments;
  String content;
  String id;
  List<String> images;
  List<String> likes;
  DateTime publishDate;
  User user;
  bool isLoading = false;

  Feed({
    @required this.comments,
    @required this.content,
    @required this.id,
    @required this.images,
    @required this.likes,
    @required this.publishDate,
    @required this.user,
  });

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        comments: json['comments'] != null
            ? List<Comment>.from(
                json["comments"].map((x) => Comment.fromJson(x)))
            : [],
        content: json["content"],
        id: json['_id'],
        images: json['images'] != null
            ? List<String>.from(json["images"].map((x) => x))
            : [],
        likes: json['likes'] != null
            ? List<String>.from(json["likes"].map((x) => x))
            : [],
        publishDate: json['publish_date'] != null
            ? DateTime.parse(json["publish_date"])
            : null,
        user: json['user'] is String || json['user'] == null
            ? null
            : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "content": content,
        "images": List<dynamic>.from(images.map((x) => x)),
        "publish_date": publishDate.toIso8601String(),
      };
}

class Comment {
  String id;
  String content;
  bool isReply;
  DateTime postedTime;
  User replyTo;
  User user;
  String feedID;

  Comment({
    @required this.id,
    @required this.content,
    @required this.isReply,
    @required this.postedTime,
    @required this.replyTo,
    @required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['_id'],
        content: json["content"],
        isReply: json["is_reply"],
        postedTime: DateTime.parse(json["posted_time"]),
        replyTo: json["reply_to"] == null || json["is_reply"] == false
            ? null
            : User.fromJson(json["reply_to"]),
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "content": content,
        "is_reply": isReply,
        "posted_time": postedTime.toIso8601String(),
        "reply_to": replyTo == null ? null : replyTo.userId,
        "user": user.userId,
      };
}
