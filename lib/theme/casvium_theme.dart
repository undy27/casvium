import 'package:flutter/material.dart';

class CasviumColors {
  static const Color canvas = Color(0xFFF6F1E7);
  static const Color surface = Color(0xFFFFFCF5);
  static const Color surfaceAlt = Color(0xFFEDE5D5);
  static const Color ink = Color(0xFF1E1C1A);
  static const Color inkMuted = Color(0xFF655E54);
  static const Color border = Color(0xFF1E1C1A);

  // Paleta artesanal de acentos
  static const Color terracotta = Color(0xFFE06D53);
  static const Color sage = Color(0xFF4A7C59);
  static const Colorochre = Color(0xFFE5A93C);
  static const Color mustard = Color(0xFFE5A93C);
  static const Color Aegean = Color(0xFF3B7097);
  static const Color cobalt = Color(0xFF3B7097);
  static const Color plum = Color(0xFF845EC2);
  static const Color coral = Color(0xFFD9534F);
  static const Color mint = Color(0xFF68B0AB);

  static const List<Color> memberPalette = [
    terracotta,
    sage,
    cobalt,
    mustard,
    plum,
    mint,
    Color(0xFFC85A32),
    Color(0xFF2B580C),
  ];

  static Color fromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    return terracotta;
  }

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

class CasviumTheme {
  static ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: CasviumColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CasviumColors.terracotta,
        surface: CasviumColors.surface,
        primary: CasviumColors.terracotta,
        secondary: CasviumColors.sage,
        onSurface: CasviumColors.ink,
      ),
      fontFamily: 'Georgia',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: CasviumColors.ink,
          letterSpacing: -0.8,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: CasviumColors.ink,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: CasviumColors.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: CasviumColors.ink,
          fontFamily: 'Segoe UI',
        ),
        bodyMedium: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: CasviumColors.inkMuted,
          fontFamily: 'Segoe UI',
        ),
      ),
    );
  }
}
