import 'package:flutter/material.dart';
import 'package:message_mobile/models/objects.dart';

class FeedPageModel with ChangeNotifier {
  bool _showReply = false;
  TextEditingController textEditingController = TextEditingController();
  Comment _comment;
  Feed _feed;

  Feed get feed => _feed;

  set feed(Feed f) {
    _feed = f;
    notifyListeners();
  }

  bool get showReply => _showReply;

  set showReply(bool v) {
    _showReply = v;
    notifyListeners();
  }

  Comment get comment => _comment;

  set comment(Comment comment) {
    if (comment != _comment) {
      textEditingController.clear();
    }

    _comment = comment;

    notifyListeners();
  }

  Comment getReplyComment(User currentUser) {
    var comment = Comment(
      content: textEditingController.text,
      user: currentUser,
      postedTime: DateTime.now(),
      isReply: false,
      replyTo: null,
    );

    if (_comment != null) {
      comment.isReply = true;
      comment.replyTo = _comment.user;
    }
    return comment;
  }
}
