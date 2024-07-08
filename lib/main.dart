import 'package:digital_payment_app/Models/LoginState.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'Screens/SplashScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:digital_payment_app/generated/l10n.dart;
import 'Services/LocalizationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalizationService localizeService = LocalizationService();
  print("Initializing localization...");

  try {
    await localizeService.initLocalization();
    print("Localization initialized successfully.");
  } catch (e) {
    print("Error initializing localization: $e");
    // Handle initialization error as needed
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocalizationService()),
        ChangeNotifierProvider(create: (context) => LoginState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    const Color primaryRed =
        Color(0xFFD32F2F); // Adjust this hex to match exact color from image
    const Color backgroundGrey =
        Color(0xFFF7F7F7); // Adjust this hex to match exact color from image
    const Color inputFieldGrey =
        Color(0xFFE0E0E0); // Adjust this hex to match exact color from image

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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
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
          foregroundColor: Colors.white,
          backgroundColor: primaryRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
      textTheme: TextTheme(
        titleMedium: TextStyle(color: primaryRed, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );

    return Consumer<LocalizationService>(
      builder: (context, localizeService, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OoPay', // App title
          theme: theme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'), // English
            Locale('ar', 'AE'), // Arabic
            // Add more locales as needed
          ],
          locale: Locale(localizeService.selectedLanguageCode),
          home: SplashScreen(),
          builder: (context, child) {
            return Directionality(
              textDirection: localizeService.selectedLanguageCode == 'en'
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: child!,
            );
          },
        );
      },
    );
  }
}
