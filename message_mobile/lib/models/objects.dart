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

  User(
      {this.dateOfBirth,
      this.friends,
      this.password,
      this.sex,
      this.userId,
      this.userName,
      this.lastMessage,
      this.avatar});

  factory User.fromJson(Map<String, dynamic> json) => User(
      dateOfBirth: json["dateOfBirth"] == null
          ? null
          : DateTime.parse(json["dateOfBirth"]),
      friends: json["friends"] == null
          ? null
          : List<User>.from(json["friends"].map((x) => User.fromJson(x))),
      password: json["password"] == null ? null : json["password"],
      sex: json["sex"] == null ? null : json["sex"],
      userId: json["userID"] == null ? null : json["userID"],
      userName: json["userName"] == null ? null : json["userName"],
      lastMessage: json['lastMessage'] == null ? null : json['lastMessage'],
      avatar: json['avatar']);

  Map<String, dynamic> toJson() => {
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
        "lastMessage": lastMessage
      };
}

class Message {
  String messageBody;
  String receiver;
  String receiverName;
  String sender;
  DateTime time;
  MessageType type = MessageType.text;

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
    this.type,
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
  String content;
  String id;
  List<String> images;
  List<String> likes;
  DateTime publishDate;
  User user;
  bool isLoading = false;

  Feed({
    @required this.content,
    @required this.id,
    @required this.images,
    @required this.likes,
    @required this.publishDate,
    @required this.user,
  });

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        content: json["content"],
        id: json["id"],
        images: List<String>.from(json["images"].map((x) => x)),
        likes: List<String>.from(json["likes"].map((x) => x)),
        publishDate: DateTime.parse(json["publish_date"]),
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "content": content,
        "id": id,
        "images": List<dynamic>.from(images.map((x) => x)),
        "likes": List<dynamic>.from(likes.map((x) => x)),
        "publish_date": publishDate.toIso8601String(),
        "user": user.toJson(),
      };
}
