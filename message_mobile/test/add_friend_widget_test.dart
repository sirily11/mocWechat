import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/friend/freindDetailPage.dart';
import 'package:provider/provider.dart';

void main() {
  group("friend detail page test", () {
    User user1;
    User user2;
    User user3;

    setUp(() {
      user1 = User(
        userId: "a",
        userName: "Abc",
        password: "a",
        friends: [user2],
        sex: "male",
        dateOfBirth: DateTime.now(),
      );

      user2 = User(
        userId: "b",
        userName: "Cde",
        password: "a",
        friends: [user1],
        sex: "male",
        dateOfBirth: DateTime.now(),
      );
      user3 = User(
        userId: "c",
        userName: "Edf",
        password: "a",
        friends: [],
        sex: "male",
        dateOfBirth: DateTime.now(),
      );
    });

    testWidgets("Test for user 1", (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ChatModel(),
          child: MaterialApp(
            home: FriendDetailPage(
              friend: user1,
              self: user2,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Add Friend"), findsNothing);
      expect(find.text("Delete Friend"), findsOneWidget);
      expect(find.text("Abc"), findsOneWidget);
    });

    testWidgets("Test for user 1", (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ChatModel(),
          child: MaterialApp(
            home: FriendDetailPage(
              friend: user3,
              self: user2,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Add Friend"), findsOneWidget);
      expect(find.text("Delete Friend"), findsNothing);
      expect(find.text("Edf"), findsOneWidget);
    });
  });
}
