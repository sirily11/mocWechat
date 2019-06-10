import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Nav {
  String title;
  IconData icon;
  Nav(this.title, this.icon);
}

class BottomNavigation extends StatelessWidget {
  final Function switchTo;
  final int currentIndex;
  final List<Nav> bottomNav;

  BottomNavigation(this.switchTo, this.currentIndex, this.bottomNav);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (int next){
        switchTo(next);
      },
      items: bottomNav.map((Nav nav) {
        return BottomNavigationBarItem(
            icon: Icon(nav.icon), title: Text(nav.title));
      }).toList(),
    );
  }
}
