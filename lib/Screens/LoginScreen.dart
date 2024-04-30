import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../Custom_Widgets/CustomButton.dart';
import '../Custom_Widgets/CustomTextField.dart';
import '../Custom_Widgets/LogoWidget.dart';
import '../Models/LoginState.dart';
import 'DashboardScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Make sure to add flutter_screenutil to your pubspec.yaml

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    final LocalAuthentication auth = LocalAuthentication();
    final theme = Theme.of(context);
    double maxWidth = ScreenUtil().screenWidth > 600 ? 600.w : ScreenUtil().screenWidth * 0.9;
    Future<void> _authenticateWithBiometrics(BuildContext context) async {
      bool authenticated = false;
      try {
        // Check if we can check biometrics
        bool canCheckBiometrics = await auth.canCheckBiometrics;

        if (canCheckBiometrics) {
          // Authenticate using biometrics
          authenticated = await auth.authenticate(
            localizedReason: 'Scan your face to authenticate',
            options: const AuthenticationOptions(
              useErrorDialogs: true,
              stickyAuth: true,
              biometricOnly: true,
            ),
          );
        }

        // If successfully authenticated
        if (authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        }
      } catch (e) {
        // If an error occurs, handle it here
      }
    }
     final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
// Ensure the maxWidth is not larger than the design width

    final baseColor = theme.primaryColor.withOpacity(0.05);
    return ChangeNotifierProvider<LoginState>(
      create: (_) => LoginState(),
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Color(0xFFF7F7F7),elevation: 0,
        //   actions: [
        //     _buildLanguageSwitchButton(
        //         context), // Moved language switch to AppBar
        //   ],
        // ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [
                theme.primaryColor.withOpacity(0.05),
                theme.primaryColorLight.withOpacity(0.2)
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: screenSize.width * 0.05),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Consumer<LoginState>(
                    builder: (_, loginState, __) {
                      return Column(
                        children: <Widget>[
                          const LogoWidget(),
                          const SizedBox(height: 32),

                          CustomTextField(
                              hint: 'Username',
                              icon: Icons.person_outline,
                              onChanged: loginState.setUsername),
                          const SizedBox(height: 20),
                          CustomTextField(
                              hint: 'Password',
                              icon: Icons.lock_outline,
                              obscureText: true,
                              onChanged: loginState.setPassword),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.fingerprint),
                                onPressed: () {
                                  _showLoginFailedDialog(context);
                                },
                                tooltip: 'Touch ID',
                              ),
                              IconButton(
                                icon: const Icon(Icons.face),
                                onPressed: () {            _authenticateWithBiometrics(context);

                                },
                                tooltip: 'Face ID',
                              ),
                              Expanded(
                                child: CustomButton(
                                  text: 'Login',
                                  onPressed: () => _handleLogin(context,
                                      loginState), // Corrected function call
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {/* Forgot Password Logic */},
                              child: Text('Forgot Password / Username?',
                                  style: TextStyle(fontSize: 14.sp,
                                    color: Color(0xFFC62828),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoSansUI',
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: screenSize.height * 0.25,
                          ),
                          _buildTrademarkNotice(), // Trademark notice
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _switchLanguage() {
    // Implement language switching functionality here.
  }
  // Builds a trademark notice at the bottom or any preferred location of the screen.
  Widget _buildTrademarkNotice() {
    return Text(
      '© Ooredoo 2024',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey,fontSize: 14.sp,
        fontFamily: 'NotoSansUI',fontWeight: FontWeight.bold
      ),
    );
  }

  void _showLoginFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing the dialog by tapping outside of it
      builder: (BuildContext dialogContext) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                width: 300.w,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Semi-transparent white for glass effect
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Use the minimum space necessary
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Login Failed',
                      style: TextStyle(decoration: TextDecoration.none,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansUI',
                        color: Color(0xFFC62828),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Incorrect username or password. Please try again.',
                      style: TextStyle(decoration: TextDecoration.none,
                        fontSize: 14.sp,
                        fontFamily: 'NotoSansUI',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Dismiss the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC62828), // Button color
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,decoration: TextDecoration.none,
                            fontFamily: 'NotoSansUI',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleLogin(BuildContext context, LoginState loginState) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: 130.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Semi-transparent white for glass effect
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpinKitFadingCircle(
                      itemBuilder: (BuildContext context, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index.isEven ? Colors.white : Colors.grey[300], // Adjust color for effect
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h), // Reduced space between spinner and text
                    Text(
                      'Please Wait',
                      style: TextStyle(decoration: TextDecoration.none,
                        color: Colors.white,
                        fontFamily: 'NotoSansUI',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop(); // Dismiss the progress indicator dialog

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
  }
}
