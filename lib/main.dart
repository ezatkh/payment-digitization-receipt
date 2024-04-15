 import 'package:flutter/material.dart';

import 'Screens/SplashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // A lighter base color for the background
    const backgroundColor = Color(0xE4F2F2F2);

    // Define a complementary color for the theme that matches well with a lighter background
    const complementaryColor = Colors.red; // A vibrant blue that complements the red logo

    final ThemeData theme = ThemeData(
      brightness: Brightness.light,
      primaryColor: complementaryColor,
      hintColor: Colors.redAccent,
      scaffoldBackgroundColor: backgroundColor, // Light background for screens
      colorScheme: const ColorScheme.light().copyWith(
        primary: complementaryColor,
        secondary: Colors.redAccent,
        background: backgroundColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white, // White background for input fields
        contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Modern border radius
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: complementaryColor.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: complementaryColor, width: 2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: complementaryColor, // Text button color
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.red, // Button background color
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(double.infinity, 50),
          elevation: 2, // Slight elevation for a subtle shadow
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: complementaryColor),
        bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
        labelLarge: TextStyle(color: Colors.white),
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











