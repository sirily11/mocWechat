import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

final _tableName = "message";
final _messageBodyColumnName = "messageBody";
final _senderColumnName = "sender";
final _receiverColumnName = "receiver";
final _timeColumnName = "time";

/// This is the message object for
/// chatting
class Message {
  int id;
  String messageBody;
  String senderId;
  String receiverId;
  DateTime time;

  Message({this.messageBody, this.receiverId, this.senderId, this.time});

  Map<String, dynamic> toJson() => {
        _messageBodyColumnName: messageBody,
        _senderColumnName: senderId,
        _receiverColumnName: receiverId,
        _timeColumnName: time.toString()
      };

  Map<String, dynamic> toMap() => {
        _messageBodyColumnName: messageBody,
        _senderColumnName: senderId,
        _receiverColumnName: receiverId,
        _timeColumnName: time.toString()
      };

  Message.fromMap(Map<String, dynamic> map) {
    messageBody = map[_messageBodyColumnName];
    senderId = map[_senderColumnName];
    receiverId = map[_receiverColumnName];
    time = map[_timeColumnName];
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        messageBody: json['messageBody'],
        receiverId: json['receiverId'],
        senderId: json['senderId'],
        time: DateTime.parse(json['time']));
  }
}

/// Message database helper class
/// This class is used to communicate between
/// sqLite database
class MessageProvider {
  Database db;

  Future open(BuildContext context) async {
    var value = await DefaultAssetBundle.of(context)
        .loadString("assets/serverSettings.json");
    final settings = json.decode(value);
    final path = settings['databasePath'];

    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
      create table if not exists $_tableName (
      id interger primary key autoincrement,
      $_messageBodyColumnName text,
      $_senderColumnName text,
      $_receiverColumnName text,
      $_timeColumnName text
      )
      ''');
    });
  }

  Future<Message> insert(Message message) async {
    message.id = await db.insert(_tableName, message.toMap());
    return message;
  }

  Future<List<Message>> getMessage(String senderID, String receiverID) async {
    List<Map> maps = await db.query(_tableName,
        columns: [
          _messageBodyColumnName,
          _senderColumnName,
          _receiverColumnName,
          _timeColumnName
        ],
        where: '$_senderColumnName = ? and $_receiverColumnName = ?',
        whereArgs: [senderID, receiverID]);
    return maps.map((m) {
      return Message.fromMap(m);
    }).toList();
  }

  Future<int> delete(int id) async {
    return await db.delete(_tableName, where: "id = ?", whereArgs: [id]);
  }

  Future<int> update(Message message) async {
    return await db.update(_tableName, message.toMap(),
        where: "id = ?", whereArgs: [message.id]);
  }

  Future close() async => db.close();
}
