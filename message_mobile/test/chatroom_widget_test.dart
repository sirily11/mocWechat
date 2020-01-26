import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/objects.dart';
import 'package:message_mobile/pages/chat/chatpage.dart';
import 'package:message_mobile/pages/chat/views/message_list.dart';
import 'package:message_mobile/pages/home/views/chatroomList.dart';
import 'package:provider/provider.dart';

void main() {
  group("Test Chatroom message list", () {
    User self = User(
      userId: "a",
      userName: "ABC",
      password: "a",
      friends: [],
      dateOfBirth: null,
      sex: "male",
    );
    User user1 = User(
      userId: "b",
      userName: "CDE",
      password: "a",
      friends: [],
      dateOfBirth: null,
      sex: "male",
    );
    User user2 = User(
      userId: "c",
      userName: "EDG",
      password: "a",
      friends: [],
      dateOfBirth: null,
      sex: "male",
    );

    List<Message> messages = [
      Message(
          sender: self.userId, receiver: user1.userId, messageBody: "Hello 1"),
      Message(
          sender: user1.userId, receiver: self.userId, messageBody: "Hello 2"),
      Message(
          sender: self.userId, receiver: user2.userId, messageBody: "Hello 3"),
      Message(
          sender: user2.userId, receiver: self.userId, messageBody: "Hello 4")
    ];

    testWidgets("Test In User 1's chat room", (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ChatModel(),
          child: MaterialApp(
            home: ChatPage(
              friend: user1,
              owner: self,
              messages: messages,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text("Hello 1"), findsOneWidget);
      expect(find.text("Hello 2"), findsOneWidget);
      expect(find.text("Hello 3"), findsNothing);
      expect(find.text("Hello 4"), findsNothing);
    });

    testWidgets("Test In User 2's chat room", (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ChatModel(),
          child: MaterialApp(
            home: ChatPage(
              friend: user2,
              owner: self,
              messages: messages,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Hello 1"), findsNothing);
      expect(find.text("Hello 2"), findsNothing);
      expect(find.text("Hello 3"), findsOneWidget);
      expect(find.text("Hello 4"), findsOneWidget);
    });
  });
}
