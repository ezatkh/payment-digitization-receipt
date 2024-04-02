import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Custom_Widgets/CustomButton.dart';
import '../Custom_Widgets/CustomTextField.dart';
import '../Custom_Widgets/LogoWidget.dart';
import '../main.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LogoWidget(),
                CustomTextField(hint: 'Username', icon: Icons.person),
                const SizedBox(height: 8), // Reduced space
                CustomTextField(hint: 'Password', icon: Icons.lock, obscureText: true),

                const SizedBox(height: 24), // Reduced space
                CustomButton(text: 'Login', onPressed: () {}),
                const SizedBox(height: 16), // Kept or adjust as needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}