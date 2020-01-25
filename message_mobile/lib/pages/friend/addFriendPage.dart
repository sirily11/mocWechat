import 'package:flutter/material.dart';
import 'package:message_mobile/pages/friend/views/addFriendView.dart';

class AddFriendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AddFriendView(),
    );
  }
}
