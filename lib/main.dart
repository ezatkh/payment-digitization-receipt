import 'package:digital_payment_app/screens/LoginScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define theme colors and the overall theme here
    final ThemeData theme = ThemeData(
      primaryColor: Color(0xFFE57373),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xFFFFCDD2)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Color(0xFFE57373)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color(0xFFE57373),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          minimumSize: Size(double.infinity, 50),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login Screen',
      theme: theme,
      home: const LoginScreen(),
    );
  }
}












