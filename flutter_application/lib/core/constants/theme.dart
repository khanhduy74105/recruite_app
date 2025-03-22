import 'package:flutter/material.dart';

final ThemeData linkedInTheme = ThemeData(
  useMaterial3: true,  // Enable Material 3 design
  brightness: Brightness.light, // Light theme as default

  // Primary color (LinkedIn blue)
  primaryColor: const Color(0xFF0077B5),

  // AppBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 1,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.black),
  ),

  // Color Scheme
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF0077B5),
    secondary: Colors.grey[600]!,
    background: Colors.white,
    surface: Colors.white,
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black,
    onSurface: Colors.black,
  ),

  // Text Theme
  textTheme: TextTheme(
    displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
    titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
    bodyLarge: const TextStyle(fontSize: 16, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[800]),
    labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0077B5)),
  ),

  // Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0077B5),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF0077B5),
      side: const BorderSide(color: Color(0xFF0077B5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),

  // TextField Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF0077B5), width: 2),
    ),
  ),

  // Card Theme
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    color: Colors.white,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),

  // Chip Theme
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[300]!,
    labelStyle: const TextStyle(color: Colors.black),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
  ),

  // Icon Theme
  iconTheme: IconThemeData(
    color: Colors.grey[700],
    size: 24,
  ),

  // Bottom Navigation Bar
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFF0077B5),
    unselectedItemColor: Colors.grey[600],
    showUnselectedLabels: true,
  ),
);
