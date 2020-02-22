import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/feed/views/commentRow.dart';
import 'package:provider/provider.dart';

void main() {
  group("Test Comment", () {
    User user1 = User(
      userId: "a",
      userName: "Abc",
      password: "a",
      friends: [],
      sex: "male",
      dateOfBirth: DateTime.now(),
    );

    User user2 = User(
      userId: "a",
      userName: "Def",
      password: "a",
      friends: [],
      sex: "male",
      dateOfBirth: DateTime.now(),
    );

    Comment comment;
    Comment replyComment;
    Feed feed;

    setUp(() {
      comment = Comment(
        content: "Dark Willow So Cute",
        user: user1,
        isReply: false,
        replyTo: user2,
        postedTime: DateTime.now(),
      );
      replyComment = Comment(
        content: "I agree",
        user: user2,
        isReply: true,
        replyTo: user1,
        postedTime: DateTime.now(),
      );

      feed = Feed(
          comments: [comment, replyComment],
          content: "My Day",
          user: user1,
          id: "1",
          images: [],
          likes: [],
          publishDate: DateTime.now());
    });

    testWidgets("Test show comment without reply", (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ChatModel(),
          child: MaterialApp(
            home: Material(
              child: CommentRow(
                comment: comment,
                feed: feed,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is RichText &&
            widget.text.toPlainText() == "Abc: Dark Willow So Cute"),
        findsOneWidget,
      );
    });

    testWidgets("Test show comment with reply", (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ChatModel(),
          child: MaterialApp(
            home: Material(
              child: CommentRow(
                comment: replyComment,
                feed: feed,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((Widget widget) {
          return widget is RichText &&
              widget.text.toPlainText() == "Def: @Abc I agree";
        }),
        findsOneWidget,
      );
    });
  });
}
