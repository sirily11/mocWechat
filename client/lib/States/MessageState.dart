import 'package:flutter/widgets.dart';
import 'package:client/Home/Chat/data/MessageObj.dart';

class MessageState with ChangeNotifier{
  List<Message> _messages = [];

  List<Message> get messages{
    if(_messages == null){
      return [];
    } else{
      return _messages;
    }
  }

  addMessage(Message message){
    _messages.add(message);
    notifyListeners();
  }

  deleteMessage(String sender, String receiver){
    _messages.removeWhere((Message msg){
      return msg.senderId == sender && msg.receiverId == receiver;
    });
  }

  set messages(List<Message> value) {
    _messages = value;
  }


}