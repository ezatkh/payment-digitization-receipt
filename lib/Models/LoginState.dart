import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Services/apiConstants.dart';
import '../Services/networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';

class LoginState with ChangeNotifier {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String _username = '';
  String _password = '';
  String _usernameLogin = '';
  bool _isLoading = false;
  bool _isLoginSuccessful = false;


  bool get isLoading => _isLoading;
  bool get isLoginSuccessful => _isLoginSuccessful;
  String get username => _username;
  String get usernameLogin => _usernameLogin;
  String get password => _password;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setUsernameLogin(String username) {
    _usernameLogin = username;
    print("UsernameLogin set to: $_usernameLogin");
    notifyListeners();
  }

  void setUsername(String username) {
    _username = username;
    print("Username set to: $_username");
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    Map<String, dynamic> map = {
      "username": username,
      "password": password,
    };
    print("Attempting login with username, password: $map");

    NetworkHelper helper = NetworkHelper(url: apiUrlLogin, map: map);

    try {
      var userData = await helper.getData();
      print("userData.status :${userData}");

      if (userData.containsKey('token')) {
        String token = userData['token'].toString().substring(6);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('usernameLogin', username.toLowerCase());
        await prefs.setString('token', token);
        print("Token stored successfully: $token");

        return true;
      } else {
        print("Token not found in the response");
        return false;
      }
    } catch (e) {
      print("Login failed :${e}");
      return false;
    }
  }

}
