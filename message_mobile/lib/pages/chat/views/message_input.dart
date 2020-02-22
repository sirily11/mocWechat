import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:provider/provider.dart';

class MessageInput extends StatefulWidget {
  final User owner;
  final User friend;

  MessageInput({@required this.owner, @required this.friend});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ChatModel model = Provider.of(context);

    return Card(
      shape: RoundedRectangleBorder(
          side: BorderSide(width: 0), borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: CupertinoTextField(
                    style: Theme.of(context).primaryTextTheme.bodyText1,
                    controller: controller,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await model.sendMessage(
                      Message(
                        sender: widget.owner.userId,
                        receiver: widget.friend.userId,
                        receiverName: widget.friend.userName,
                        messageBody: controller.text,
                        time: DateTime.now(),
                      ),
                    );
                    controller.clear();
                  },
                  icon: Icon(Icons.send),
                )
              ],
            ),
            Wrap(
              children: <Widget>[
                IconButton(
                  onPressed: () async {
                    File imageFile = await ImagePicker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (imageFile != null) {
                      await model.sendMessage(
                        Message(
                          type: MessageType.image,
                          time: DateTime.now(),
                          sender: widget.owner.userId,
                          receiver: widget.friend.userId,
                          receiverName: widget.friend.userName,
                          uploadFile: imageFile,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.camera_alt),
                ),
                IconButton(
                  onPressed: () async {
                    File imageFile = await ImagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (imageFile != null) {
                      await model.sendMessage(
                        Message(
                          type: MessageType.image,
                          time: DateTime.now(),
                          sender: widget.owner.userId,
                          receiver: widget.friend.userId,
                          receiverName: widget.friend.userName,
                          uploadFile: imageFile,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.photo_library),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
