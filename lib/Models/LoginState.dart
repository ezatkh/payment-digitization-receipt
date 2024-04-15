import 'dart:ui';

import 'package:flutter/foundation.dart';

class LoginState with ChangeNotifier {
  String _username = '';
  String _password = '';
  bool _rememberMe = false;
  bool _hasInternetConnection = true; // You should check internet connectivity and set this flag accordingly

  bool _isLoading = false;
  bool _isLoginSuccessful = false;

  bool get isLoading => _isLoading;
  bool get isLoginSuccessful => _isLoginSuccessful;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }


  // Getters
  String get username => _username;
  String get password => _password;
  bool get rememberMe => _rememberMe;
  bool get hasInternetConnection => _hasInternetConnection;

  // Setters
  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setRememberMe(bool? value) {
    if (value != null) {
      _rememberMe = value;
      notifyListeners();
    }
  }


  // Placeholder function to simulate internet connectivity check
  void checkInternetConnection() {
    // Implement your logic to check internet connectivity
    // For now, we're just setting it to true
    _hasInternetConnection = true;
    notifyListeners();
  }

  Future<void> login() async {
    notifyListeners();
  }
}
