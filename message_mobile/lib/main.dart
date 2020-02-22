import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';
import 'package:message_mobile/models/feedPageModel.dart';
import 'package:message_mobile/models/homePageModel.dart';
import 'package:message_mobile/models/signInPageModel.dart';
import 'package:message_mobile/pages/home/homepage.dart';
import 'package:message_mobile/pages/login/loginpage.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => FeedPageModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => SignInPageModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomePageModel(),
        )
      ],
      child: MaterialApp(
        darkTheme: ThemeData.dark().copyWith(
            highlightColor: Colors.teal, backgroundColor: Colors.teal),
        themeMode: ThemeMode.system,
        title: 'Chat App',
        theme: ThemeData(
            primarySwatch: Colors.blue, highlightColor: Colors.yellow),
        home: LoginPage(),
      ),
    );
  }
}
