import 'package:flutter/material.dart';
import 'app_pallete.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimaryColor,
    shadowColor: grey300,

    scaffoldBackgroundColor: const Color(0xFFF7F7F7),
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF7F7F7),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold
      ),
      titleMedium: TextStyle(
        color: Colors.black54,
        fontSize: 16
      )
    )
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    shadowColor: grey800,

    scaffoldBackgroundColor: const Color(0xFF000000),
    cardColor: const Color(0xFF1A1A1A),

    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF000000),
      foregroundColor: Colors.white,
    ),

    textTheme: const TextTheme(
        titleLarge: TextStyle(
            color: whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),
        titleMedium: TextStyle(
            color: Colors.white70,
            fontSize: 16
        )
    )
  );
}