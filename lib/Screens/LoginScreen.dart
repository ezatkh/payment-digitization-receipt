import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../Custom_Widgets/CustomButton.dart';
import '../Custom_Widgets/CustomTextField.dart';
import '../Custom_Widgets/LogoWidget.dart';
import '../Models/LoginState.dart';
import '../Services/LocalizationService.dart';
import 'DashboardScreen.dart';
import 'dart:async';

class LoginScreen extends StatelessWidget {
  static const List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'العربية', 'code': 'ar'},
    // Add more languages as needed
  ];

  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    final theme = Theme.of(context);
    double maxWidth =
        ScreenUtil().screenWidth > 600 ? 600.w : ScreenUtil().screenWidth * 0.9;

    final screenSize = MediaQuery.of(context).size;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocalizationService>(
          create: (_) {
            var localizationState = LocalizationService();
            localizationState.initLocalization(); // Initialize localization
            return localizationState;
          },
        ),
        ChangeNotifierProvider<LoginState>(
          create: (_) => LoginState(),
        ),
      ],
      child: Consumer2<LocalizationService, LoginState>(
        builder: (context, localizationService, loginState, _) {
          return Directionality(
            textDirection: localizationService.selectedLanguageCode == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xFFF7F7F7),
                elevation: 0,
                actions: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildLanguageDropdown(context, localizationService),
                      ],
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: Container(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: screenSize.width * 0.05,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const LogoWidget(),
                            const SizedBox(height: 32),
                            CustomTextField(
                              hint: localizationService.isLocalizationLoaded
                                  ? localizationService
                                      .getLocalizedString('userName')
                                  : 'Username', // Fallback if localization is not loaded
                              icon: Icons.person_outline,
                              onChanged: loginState.setUsername,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              hint: localizationService.isLocalizationLoaded
                                  ? localizationService
                                      .getLocalizedString('password')
                                  : 'Password', // Fallback if localization is not loaded
                              icon: Icons.lock_outline,
                              obscureText: true,
                              onChanged: loginState.setPassword,
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: localizationService
                                            .isLocalizationLoaded
                                        ? localizationService
                                            .getLocalizedString('login')
                                        : 'Login', // Fallback if localization is not loaded
                                    onPressed: () async {
                                      bool isValid =
                                          validateLoginInputs(loginState);
                                      if (isValid) {
                                        bool? loginResult = true;
                                        //  await loginState.login();
                                        if (loginResult ?? false) {
                                          _handleLogin(
                                              context, localizationService);
                                        } else {
                                          _showLoginFailedDialog(
                                            context,
                                            localizationService
                                                .getLocalizedString(
                                                    'loginFailedwrong'),
                                            localizationService
                                                    .isLocalizationLoaded
                                                ? localizationService
                                                    .getLocalizedString(
                                                        'loginfailed')
                                                : 'Login Failed',
                                            localizationService
                                                .selectedLanguageCode,
                                          );
                                        }
                                      } else {
                                        _showLoginFailedDialog(
                                          context,
                                          localizationService
                                              .getLocalizedString(
                                                  'loginFailedEmpty'),
                                          localizationService
                                                  .isLocalizationLoaded
                                              ? localizationService
                                                  .getLocalizedString(
                                                      'loginfailed')
                                              : 'Login Failed',
                                          localizationService
                                              .selectedLanguageCode,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: () {
                                  /* Forgot Password Logic */
                                },
                                child: Text(
                                  localizationService.isLocalizationLoaded
                                      ? localizationService
                                          .getLocalizedString('forgotPassword')
                                      : 'Forgot Password', // Fallback if localization is not loaded
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Color(0xFFC62828),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NotoSansUI',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 65,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      bool authenticated = await loginState
                                          .getAvailableBiometricsTypes();
                                      if (authenticated == true) {
                                        print(
                                            "authenticated successfully from screen");
                                      } else {
                                        print(
                                            "authenticated failed from screen");
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.fingerprint,
                                            size: 40, color: Color(0xFFC62828)),
                                        SizedBox(width: 10),
                                        Icon(Icons.face,
                                            size: 40, color: Color(0xFFC62828)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: screenSize.height * 0.09,
                            ),
                            _buildTrademarkNotice(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageDropdown(
      BuildContext context, LocalizationService localizationService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          // Open the PopupMenu when the Row is tapped
          final dynamic state = context.findRenderObject();
          state.showButtonMenu();
        },
        child: PopupMenuButton<String>(
          onSelected: (String newValue) {
            localizationService.selectedLanguageCode = newValue;
          },
          itemBuilder: (BuildContext context) {
            return LoginScreen.languages.map((Map<String, String> language) {
              return PopupMenuItem<String>(
                value: language['code']!,
                child: ListTile(
                  title: Text(
                    language['name']!,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              );
            }).toList();
          },
          child: Row(
            children: [
              Icon(Icons.language, color: Colors.black),
              SizedBox(width: 8.0),
              Text(
                getLanguageName(localizationService.selectedLanguageCode),
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getLanguageName(String code) {
    // Function to return the language name based on the language code
    for (var language in LoginScreen.languages) {
      if (language['code'] == code) {
        return language['name']!;
      }
    }
    return ''; // Return empty string if language code not found (should not happen in ideal scenarios)
  }

  // Builds a trademark notice at the bottom or any preferred location of the screen.
  Widget _buildTrademarkNotice() {
    return Text(
      '© Ooredoo 2024',
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.grey,
          fontSize: 14.sp,
          fontFamily: 'NotoSansUI',
          fontWeight: FontWeight.bold),
    );
  }

  void _showLoginFailedDialog(BuildContext context, String errorMessage,
      String loginFailed, String langauage) {
    showDialog(
      context: context,
      barrierDismissible: true,
      // Allow dismissing the dialog by tapping outside of it
      builder: (BuildContext dialogContext) {
        return Directionality(
          textDirection: langauage == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr, // Set text direction to left-to-right
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  width: 300.w,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    // Semi-transparent white for glass effect
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // Use the minimum space necessary
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        loginFailed,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansUI',
                          color: Color(0xFFC62828),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          decoration: TextDecoration.none,
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
                            Navigator.of(dialogContext)
                                .pop(); // Dismiss the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFC62828), // Button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              decoration: TextDecoration.none,
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
          ),
        );
      },
    );
  }

  bool validateLoginInputs(LoginState loginState) {
    print("validateLoginInputs invoked in loginScreen");
    String username = loginState.username ??
        ''; // Get username from loginState or use an empty string if null
    String password = loginState.password ??
        ''; // Get password from loginState or use an empty string if null

    // Check if username or password is empty
    if (username.isEmpty || password.isEmpty) {
      return false; // Validation failed
    }
    // Additional validation logic can be added here if needed

    return true; // Validation succeeded
  }

  void _handleLogin(
      BuildContext context, LocalizationService localizationService) async {
    print("_handleLogin invoked in loginScreen");
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
                  color: Colors.white.withOpacity(0.2),
                  // Semi-transparent white for glass effect
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
                            color: index.isEven
                                ? Colors.white
                                : Colors.grey[300], // Adjust color for effect
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    // Reduced space between spinner and text
                    Text(
                      localizationService.getLocalizedString('pleaseWait'),
                      style: TextStyle(
                        decoration: TextDecoration.none,
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
