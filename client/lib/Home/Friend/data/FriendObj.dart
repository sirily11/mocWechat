import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

final _tableName = "friend";
final _userIDColumn = "userID";
final _userNameColumn = "userName";

class Friend {
  int id;
  String userId;
  String userName;
  String dateOfBirth;
  String sex;
  String description;
  List<dynamic> friends;

//  Friend(this.userName, this.sex, this.dateOfBirth, this.userId);
  Friend(
      {this.userId,
      this.userName,
      this.dateOfBirth,
      this.sex,
      this.description,
      this.friends});

  Map<String, dynamic> toMap() =>
      {_userIDColumn: this.userId, _userNameColumn: this.userName};

  Friend.fromMap(Map<String, dynamic> friend) {
    this.userName = friend[_userNameColumn];
    this.userId = friend[_userIDColumn];
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
        userId: json['_id'],
        userName: json['userName'],
        dateOfBirth: json['dateOfBirth'],
        sex: json['sex'],
        description: json['description'],
        friends: json['friends']);
  }
}

/// Message database helper class
/// This class is used to communicate between
/// sqLite database
class FriendProvider {
  Database db;

  Future open(BuildContext context) async {
    var value = await DefaultAssetBundle.of(context)
        .loadString("assets/serverSettings.json");
    final settings = json.decode(value);
    final path = settings['databasePath'];

    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
      create table if not exists $_tableName (
      id INTEGER primary key autoincrement,
      $_userNameColumn text,
      $_userIDColumn text
      )
      ''');
    });
  }

  Future<Friend> insert(Friend friend) async {
    friend.id = await db.insert(_tableName, friend.toMap());
    return friend;
  }

  Future<List<Friend>> getFriend() async {
    try {
      List<Map> maps =
          await db.query(_tableName, columns: [_userIDColumn, _userNameColumn]);
      if (maps.length == 0) {
        return [];
      }
      return maps.map((m) {
        return Friend.fromMap(m);
      }).toList();
    } on Exception catch (err) {
      return [];
    }
  }

  Future<int> delete(int id) async {
    return await db.delete(_tableName, where: "id = ?", whereArgs: [id]);
  }

  Future<int> update(Friend friend) async {
    return await db.update(_tableName, friend.toMap(),
        where: "id = ?", whereArgs: [friend.id]);
  }

  Future close() async => db.close();
}
