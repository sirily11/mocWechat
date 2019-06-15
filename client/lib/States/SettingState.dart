import 'package:flutter/widgets.dart';

class SettingState with ChangeNotifier {
  String _socketAddress;
  String _httpAddress;
  int _socketPort;
  int _httpPort;

  /// 1 : connected, 0 : connecting, -1: fail
  int isWebSocketConnect;
  int isHttpConnect;
  bool isSet = false;

  Map<String, dynamic> toJson() => {
        "webSocketServer": _socketAddress,
        "httpWebServer": _httpAddress,
        "httpPort": _httpPort,
        "webSocketPort": _socketPort
      };

  String get socketAddress => _socketAddress;

  set socketAddress(String value) {
    _socketAddress = value;
  }

  @override
  String toString() {
    return 'SettingState{webSocket: $_socketAddress:$_socketPort, http:$_httpAddress:$_httpPort}';
  }

  void set() {
    notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  String get httpAddress => _httpAddress == null ? "" : _httpAddress;

  set httpAddress(String value) {
    _httpAddress = value;
  }

  int get socketPort => _socketPort == null ? 0 : _socketPort;

  set socketPort(int value) {
    _socketPort = value;
  }

  int get httpPort => _httpPort;

  set httpPort(int value) {
    _httpPort = value;
  }
}
