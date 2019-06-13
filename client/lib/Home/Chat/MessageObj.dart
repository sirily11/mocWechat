class Message {
  final String messageBody;
  final String senderId;
  final String receiverId;
  final DateTime time;

  Message({this.messageBody, this.receiverId, this.senderId, this.time});

  Map<String, dynamic> toJson() => {
        "messageBody": messageBody,
        "sender": senderId,
        "receiver": receiverId,
        "time": time.toString()
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        messageBody: json['messageBody'],
        receiverId: json['receiverId'],
        senderId: json['senderId'],
        time: DateTime.parse(json['time']));
  }
}
