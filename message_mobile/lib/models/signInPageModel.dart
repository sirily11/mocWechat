import 'package:flutter/material.dart';

/// State for login page
enum LoginPageSelection { signUp, login, setting }

class SignInPageModel with ChangeNotifier {
  /// current login page status
  LoginPageSelection _currentSelection = LoginPageSelection.login;

  set currentSelection(LoginPageSelection currentSelection) {
    _currentSelection = currentSelection;
    notifyListeners();
  }

  LoginPageSelection get currentSelection => _currentSelection;
}
