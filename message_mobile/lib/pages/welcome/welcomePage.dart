import 'package:flutter/material.dart';
import 'package:message_mobile/pages/welcome/views/firstPage.dart';
import 'package:message_mobile/pages/welcome/views/lastPage.dart';
import 'package:message_mobile/pages/welcome/views/secondPage.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final controller = PageController(initialPage: 0);
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      FirstPage(
        isShowing: currentPage == 0,
      ),
      SecondPage(
        isShowing: currentPage == 1,
      ),
      LastPage(
        isShowing: currentPage == 2,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          PageView(
            controller: controller,
            onPageChanged: (cur) {
              setState(() {
                currentPage = cur;
              });
            },
            children: pages,
          ),
          Positioned(
            child: LinearProgressIndicator(
              value: currentPage / (pages.length - 1),
            ),
          )
        ],
      ),
    );
  }
}
