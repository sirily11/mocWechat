import 'dart:convert';
import 'package:client/Home/Chat/data/MessageObj.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sqflite/sqflite.dart';

final _chatRoomTableName = "chatroom";
final _senderColumn = "sender";
final _receiverColumn = "receiver";
final _receiverNameColumn = "receiverName";
final _idColumn = "id";
final _lastMessageColumn = "lastMessage";
final _messageTableName = "message";
final _messageColumn = "message";
final _messageBodyColumnName = "messageBody";
final _senderColumnName = "sender";
final _receiverColumnName = "receiver";
final _chatRoomColumnName = "chatRoomID";
final _timeColumnName = "time";

class ChatRoom {
  int id;
  String sender;
  String receiver;
  String receiverName;

  @override
  String toString() {
    return 'ChatRoom{id: $id, sender: $sender, receiver: $receiver}';
  }

  String lastMessage;
  Message message;

  ChatRoom({this.sender,
    this.receiver,
    this.lastMessage,
    this.receiverName,
    this.message,
    this.id});

  ChatRoom.fromMap(Map<String, dynamic> map) {
    id = map[_idColumn];
    sender = map[_senderColumn];
    receiver = map[_receiverColumn];
    receiverName = map[_receiverNameColumn];
    lastMessage = map[_lastMessageColumn];
    if (message != null) {
      message = Message.fromMap(map[_messageColumn]);
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      _receiverNameColumn: receiverName,
      _receiverColumn: receiver,
      _senderColumn: sender,
      _lastMessageColumn: lastMessage
    };
    if (id != null) {
      map[_idColumn] = id;
    }
    return map;
  }
}

class ChatRoomProvider {
  Database db;

  Future open(BuildContext context) async {
    var value = await DefaultAssetBundle.of(context)
        .loadString("assets/serverSettings.json");
    final settings = json.decode(value);
    final path = settings['chatRoomDatabasePath'];
    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
     create table if not exists $_chatRoomTableName (
      $_idColumn integer primary key autoincrement,
      $_senderColumn text,
      $_receiverColumn text,
      $_receiverNameColumn text,
      $_lastMessageColumn text,
      unique($_receiverColumn)  
      );
      ''');
      print("Created chatroom");
      await db.execute(''' 
      create table if not exists $_messageTableName (
       $_idColumn integer primary key autoincrement,
       $_messageBodyColumnName text,
       $_senderColumnName text,
       $_receiverColumnName text,
       $_timeColumnName text,
       $_chatRoomColumnName integer,
       foreign key ($_chatRoomColumnName) references $_chatRoomTableName($_idColumn) on DELETE cascade
      );
      ''');
      print("created message");
    });
  }

  Future<ChatRoom> addChatRoom(ChatRoom chatRoom) async {
    try {
      chatRoom.id = await db.insert(_chatRoomTableName, chatRoom.toMap());
    } on Exception catch (err) {
      List<Map> maps = await db.query(_chatRoomTableName,
          columns: [_idColumn],
          where: "$_senderColumn = ? and $_receiverColumn = ?",
          whereArgs: [chatRoom.sender, chatRoom.receiver]);
      chatRoom.id = ChatRoom
          .fromMap(maps.first)
          .id;
    }
    return chatRoom;
  }

  /// insert message to message table
  /// and update last message in chatRoom table
  Future<Message> addMessage(ChatRoom chatRoom, Message message) async {
    if (chatRoom.id == null) {
      throw Exception("ChatRoom id should not be null");
    }
    message.chatRoomID = chatRoom.id;
    message.id = await db.insert(_messageTableName, message.toMap());
    chatRoom.lastMessage = message.messageBody;
    await db.update(_chatRoomTableName, chatRoom.toMap());
    return message;
  }

  /// delete chatRoom and its message
  Future deleteChatRoom(int id) async {
    // delete chatRoom
    int num =  await db
        .delete(_chatRoomTableName, where: '$_idColumn = ?', whereArgs: [id]);
    print(num);
    return num;
  }

  /// get all chatRoom
  Future<List<ChatRoom>> getChatRoom() async {
    List<Map> maps = await db.query(_chatRoomTableName, columns: [
      _idColumn,
      _senderColumn,
      _receiverColumn,
      _receiverNameColumn,
      _lastMessageColumn
    ]);
    return maps.map((map) => ChatRoom.fromMap(map)).toList();
  }

  Future<ChatRoom> getChatRoomByReceiver(String receiver,
      Message message) async {
    List<Map> maps = await db.query(_chatRoomTableName,
        columns: [
          _idColumn,
          _senderColumn,
          _receiverColumn,
          _receiverNameColumn,
          _lastMessageColumn
        ],
        where: "$_receiverColumn = ?",
        whereArgs: [receiver]);
    if (maps.length > 0) {
      return ChatRoom.fromMap(maps.first);
    } else {
      return await this.addChatRoom(ChatRoom(
          sender: message.senderId,
          receiver: message.receiverId,
          receiverName: message.receiverName,
          lastMessage: message.messageBody));
    }
  }

  Future<List<Message>> getMessages(ChatRoom chatRoom) async {
    if (chatRoom.id == null) {
      throw Exception("ChatRoom id should not be null");
    }
    List<Map> maps = await db.query(_messageTableName,
        columns: [
          _messageBodyColumnName,
          _senderColumnName,
          _receiverColumnName,
          _timeColumnName
        ],
        where: "$_chatRoomColumnName = ?",
        whereArgs: [chatRoom.id],
        limit: 100);
    var result = maps.map((map) => Message.fromMap(map)).toList();
    print(result);
    return result;
  }

  Future close() async {
    await db.close();
  }
}
