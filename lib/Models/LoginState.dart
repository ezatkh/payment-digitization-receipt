import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../Services/networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';

class LoginState with ChangeNotifier {
  String _username = '';
  String _password = '';
  bool _rememberMe = false;
  bool _hasInternetConnection =
      true; // You should check internet connectivity and set this flag accordingly
  final LocalAuthentication auth = LocalAuthentication();

  bool _isLoading = false;
  bool _isLoginSuccessful = false;

  bool get isLoading => _isLoading;
  bool get isLoginSuccessful => _isLoginSuccessful;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String get username => _username;
  String get password => _password;
  bool get rememberMe => _rememberMe;
  bool get hasInternetConnection => _hasInternetConnection;

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

  void checkInternetConnection() {
    _hasInternetConnection = true;
    notifyListeners();
  }

  Future<bool> login() async {
    Map<String, dynamic> map = {
      "username": _username,
      "password": _password,
    };
    print("Attempting login with username, password: $map");

    var url = "http://192.168.20.65:8080/authentication-server/mobile/login";
    NetworkHelper helper = NetworkHelper(url: url, map: map);

    try {
      print("before send api");
      var userData = await helper.getData();
      print("Login response data: $userData");

      if (userData.containsKey('token')) {
        String token = userData['token'].toString().substring(6);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        print("Token stored successfully: $token");
        return true;
      } else {
        print("Token not found in the response");
        return false;
      }
    } catch (e) {
      print("Login failed");
      return false;
    }
  }

  Future<bool> getAvailableBiometricsTypes() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      if (availableBiometrics.isNotEmpty) {
        print("Available biometrics: ");
        for (BiometricType type in availableBiometrics) {
          if (type == BiometricType.face) {
            print("Face ID is available.");
            bool authResult = await authWithFaceId();
            return authResult;
          } else if (type == BiometricType.fingerprint) {
            print("Touch ID is available.");
            return false;
          } else if (type == BiometricType.iris) {
            print("Iris authentication is available.");
            return false;
          }
        }
      } else {
        print("No biometric authentication methods are available.");
      }
      return false;
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
      return false;
    }
  }

  Future<bool> authWithFaceId() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason:
            'Please authenticate using Face ID to access this feature',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true, // Ensure only biometrics are used
        ),
      );
    } on PlatformException catch (e) {
      print(e);
    }
    if (authenticated) {
      print("Face ID authentication successful!");
      return true;
    } else
      print("Face ID authentication failed.");
    return false;
  }

  // Future<bool> authenticate(context) async {
  //   try {
  //     bool didAuthenticate = await auth.authenticate(
  //       localizedReason: 'Please authenticate to proceed',
  //       options: const AuthenticationOptions(
  //         biometricOnly: true,
  //       ),
  //     );

  //     if (didAuthenticate) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Authenticated successfully')),
  //       );
  //       return true;
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Authentication failed')),
  //       );
  //       return false;
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error during authentication: $e')),
  //     );
  //   }
  //   return false;
  // }
}
