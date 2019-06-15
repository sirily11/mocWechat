import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

final _messageBodyColumnName = "messageBody";
final _senderColumnName = "sender";
final _receiverColumnName = "receiver";
final _timeColumnName = "time";
final _chatRoomColumnName = "chatRoomID";

/// This is the message object for
/// chatting
class Message {
  int id;
  String messageBody;
  String senderId;
  String receiverId;
  String receiverName;
  DateTime time;
  int chatRoomID;

  Message(
      {this.messageBody,
      this.receiverName,
      this.receiverId,
      this.senderId,
      this.time,
      this.chatRoomID});

  Map<String, dynamic> toJson() => {
        _messageBodyColumnName: messageBody,
        _senderColumnName: senderId,
        _receiverColumnName: receiverId,
        _timeColumnName: time.toString(),
      };

  @override
  String toString() {
    return 'Message{id: $id, messageBody: $messageBody, senderId: $senderId, receiverId: $receiverId, time: $time}';
  }

  Map<String, dynamic> toMap() => {
        _messageBodyColumnName: messageBody,
        _senderColumnName: senderId,
        _receiverColumnName: receiverId,
        _timeColumnName: time.toString(),
        _chatRoomColumnName: chatRoomID
      };

  Message.fromMap(Map<String, dynamic> map) {
    messageBody = map[_messageBodyColumnName];
    senderId = map[_senderColumnName];
    receiverId = map[_receiverColumnName];
    time = DateTime.parse(map[_timeColumnName]);
    chatRoomID = map[_chatRoomColumnName];
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        messageBody: json['messageBody'],
        receiverId: json['receiver'],
        senderId: json['sender'],
        time: DateTime.parse(json['time']),
        receiverName: json['receiverName']);
  }
}
