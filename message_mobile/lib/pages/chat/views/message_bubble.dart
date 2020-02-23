import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/chat/views/imageView.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final double maxWidth = 300;
  final double imageSize = 150;
  final bubbleColor = Colors.blue;

  MessageBubble({@required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.image) {
      return buildImageBubble(context);
    }

    return Container(
      padding: EdgeInsets.all(3),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth * 0.6),
          child: Text(
            "${message.messageBody}",
            style: Theme.of(context).primaryTextTheme.bodyText1,
            maxLines: 30,
          ),
        ),
      ),
    );
  }

  Widget buildImageBubble(BuildContext context) {
    ChatModel chatModel = Provider.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          message.hasUploaded
              ? GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (c) => ImageView(
                          url: "${chatModel.httpURL}/${message.messageBody}",
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    "${chatModel.httpURL}/${message.messageBody}",
                    height: imageSize,
                    width: imageSize,
                  ),
                )
              : Image.file(
                  message.uploadFile,
                  height: imageSize,
                  width: imageSize,
                ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 100),
            child: message.uploadProgress < 1 && !message.hasUploaded
                ? Container(
                    height: imageSize,
                    width: imageSize,
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.red,
                        value: message.uploadProgress,
                      ),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
