import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/pages/friend/views/avatarView.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class SecondPage extends StatelessWidget {
  final bool isShowing;

  SecondPage({@required this.isShowing});

  @override
  Widget build(BuildContext context) {
    var pr = ProgressDialog(context);
    pr.style(
      message: "Setting URL",
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      messageTextStyle: Theme.of(context).primaryTextTheme.bodyText2,
    );

    final titleStyle = Theme.of(context).textTheme.headline3;
    ChatModel model = Provider.of(context);

    return AnimatedOpacity(
      opacity: isShowing ? 1 : 0,
      duration: Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AvatarView(
              size: 80,
              user: model.currentUser,
            ),
            Text(
              "Before your start",
              style: titleStyle,
            ),
            RaisedButton(
              onPressed: () async {
                var file = await ImagePicker.pickImage(
                    source: ImageSource.gallery, imageQuality: kImageQuality);
                if (file != null) {
                  pr.show();
                  await model.setAvatar(file);
                  await Future.delayed(Duration(milliseconds: 200));
                  await pr.hide();
                }
              },
              child: Text("Set Up Your Avatar"),
            ),
          ],
        ),
      ),
    );
  }
}
