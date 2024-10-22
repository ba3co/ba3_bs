import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData defaultTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xffE6E6E6),
    fontFamily: 'Almarai',
    appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xffE6E6E6),
        foregroundColor: Colors.black,
        surfaceTintColor: Color(0xffE6E6E6),
        elevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(Colors.white),
      backgroundColor: WidgetStatePropertyAll(Colors.blue.shade700),
      elevation: const WidgetStatePropertyAll(5),
    )),
    colorScheme: ColorScheme.fromSeed(
        primary: Colors.black, seedColor: Colors.black, surface: Colors.white),
    useMaterial3: true,
  );
}
