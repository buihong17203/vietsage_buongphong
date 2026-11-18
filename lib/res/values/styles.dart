import 'package:flutter/material.dart';
import 'colors.dart';

class ResStyles {
  ResStyles._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'sans-serif',
      colorScheme: ColorScheme.fromSeed(
        seedColor: ResColors.brand,
        primary: ResColors.brand,
        onPrimary: Colors.white,
        surface: ResColors.surface,
      ),
      scaffoldBackgroundColor: ResColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: ResColors.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: ResColors.cardBg,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ResColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ResColors.brand,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ResColors.brand,
          side: const BorderSide(color: ResColors.brand, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ResColors.brand,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ResColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ResColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ResColors.brand, width: 2),
        ),
        hintStyle: const TextStyle(color: ResColors.textMuted, fontSize: 14.5),
      ),
    );
  }

  // Common TextStyles
  static const TextStyle titleBold = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: ResColors.textDark,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: ResColors.textDark,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14.5,
    color: ResColors.text,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 13,
    color: ResColors.textMuted,
  );
}
