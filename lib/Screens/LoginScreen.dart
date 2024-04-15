import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Custom_Widgets/CustomButton.dart';
import '../Custom_Widgets/CustomTextField.dart';
import '../Custom_Widgets/LogoWidget.dart';
import '../Models/LoginState.dart';
import 'DashboardScreen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    double maxWidth = isLandscape ? 500 : 600;
    final baseColor = theme.primaryColor.withOpacity(0.05);
    return ChangeNotifierProvider<LoginState>(
      create: (_) => LoginState(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: baseColor,
          actions: [
            _buildLanguageSwitchButton(
                context), // Moved language switch to AppBar
          ],
        ),
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
                                  /* Add Touch ID login logic here */
                                },
                                tooltip: 'Touch ID',
                              ),
                              IconButton(
                                icon: const Icon(Icons.face),
                                onPressed: () {
                                  /* Add Face ID login logic here */
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
                                  style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(
                            height: 120,
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

  Widget _buildLanguageSwitchButton(BuildContext context) {
    // Placeholder function for language switching logic.
    void _switchLanguage() {
      // Implement language switching functionality here.
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: const Icon(Icons.language, color: Colors.white),
          onPressed: _switchLanguage,
          tooltip: 'Switch Language', // Tooltip for accessibility.
        ),
      ),
    );
  }

  // Builds a trademark notice at the bottom or any preferred location of the screen.
  Widget _buildTrademarkNotice() {
    return const Align(
      alignment: Alignment.center,
      child: Text(
        '© 2024 OoPay. All rights reserved.',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // Builds a button for biometric authentication, currently set to a placeholder action.
  Widget _buildBiometricLoginButton(
      BuildContext context, LoginState loginState) {
    return Column(
      children: [
        TextButton(
          onPressed: () =>
              null, // Placeholder for actual biometric login logic.
          child: const Icon(Icons.fingerprint, size: 24),
          style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor),
        ),
        const Text("Quick Login",
            style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

// Handles the login process with visual feedback and error handling.
  void _handleLogin(BuildContext context, LoginState loginState) async {
    // loginState.setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    // loginState.setLoading(false);

    // if (loginState.isLoginSuccessful) {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(const SnackBar(content: Text('Login Failed')));
    // } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    // }
  }
}
