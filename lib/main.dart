 import 'package:flutter/material.dart';

import 'Screens/SplashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFD32F2F); // Adjust this hex to match exact color from image
    const Color backgroundGrey = Color(0xFFF7F7F7); // Adjust this hex to match exact color from image
    const Color inputFieldGrey = Color(0xFFE0E0E0); // Adjust this hex to match exact color from image

    final ThemeData theme = ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: backgroundGrey,
      colorScheme: const ColorScheme.light().copyWith(
        primary: primaryRed,
        onPrimary: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFieldGrey,
        contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryRed.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryRed, width: 2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryRed,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: primaryRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
      textTheme: TextTheme(
        subtitle1: TextStyle(color: primaryRed, fontWeight: FontWeight.bold),
        bodyText2: TextStyle(color: Colors.black),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OoPay', // App title
      theme: theme,
      home: SplashScreen()
    );
  }
}











