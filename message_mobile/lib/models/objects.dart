class User {
  String id;
  DateTime dateOfBirth;
  List<User> friends;
  String password;
  String sex;
  String userId;
  String userName;
  Message lastMessage;

  User(
      {this.id,
      this.dateOfBirth,
      this.friends,
      this.password,
      this.sex,
      this.userId,
      this.userName,
      this.lastMessage});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"] == null ? null : json["_id"],
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
      );

  Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id,
        "dateOfBirth":
            dateOfBirth == null ? null : dateOfBirth.toIso8601String(),
        "friends": friends == null
            ? null
            : List<dynamic>.from(friends.map((x) => x.toJson())),
        "password": password == null ? null : password,
        "sex": sex == null ? null : sex,
        "userID": userId == null ? null : userId,
        "userName": userName == null ? null : userName,
        "lastMessage": lastMessage?.toJson()
      };
}

class Message {
  String messageBody;
  String receiver;
  String receiverName;
  String sender;
  DateTime time;

  Message({
    this.messageBody,
    this.receiver,
    this.receiverName,
    this.sender,
    this.time,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        messageBody: json["messageBody"],
        receiver: json["receiver"],
        receiverName: json["receiverName"],
        sender: json["sender"],
        time: DateTime.parse(json["time"]),
      );

  Map<String, dynamic> toJson() => {
        "messageBody": messageBody,
        "receiver": receiver,
        "receiverName": receiverName,
        "sender": sender,
        "time": time.toIso8601String(),
      };
}
