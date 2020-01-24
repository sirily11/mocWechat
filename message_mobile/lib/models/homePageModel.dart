import 'package:flutter/material.dart';

class HomePageModel with ChangeNotifier {
  int _currentMenu = 0;

  set currentMenu(int menu) {
    _currentMenu = menu;
    notifyListeners();
  }

  int get currentMenu => _currentMenu;
}
