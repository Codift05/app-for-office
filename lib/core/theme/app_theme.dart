// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // ==================== PALET WARNA UTAMA ====================

  // Primary Colors (Teal/Dark Green - dari design reference)
  static const Color primary = Color(0xFF2C5F5F); // Dark teal
  static const Color primaryDark = Color(0xFF1E4343); // Darker teal
  static const Color primaryLight = Color(0xFF3D7575); // Light teal

  // Secondary/Accent Color (Orange/Peach)
  static const Color secondary = Color(0xFFF5A962); // Warm orange
  static const Color accent = Color(0xFFF5A962); // Warm orange
  static const Color accentLight = Color(0xFFFDD5A8); // Light orange

  // Status Colors
  static const Color success = Color(0xFF4DD0A1); // Green
  static const Color warning = Color(0xFFF5A962); // Orange
  static const Color error = Color(0xFFE74C3C); // Red
  static const Color info = Color(0xFF5FC8E8); // Sky blue

  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5); // Light gray
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50); // Dark blue-gray
  static const Color textSecondary = Color(0xFF7F8C8D); // Medium gray
  static const Color textHint = Color(0xFFBDC3C7); // Light gray
  static const Color divider = Color(0xFFECF0F1);

  // ==================== MODERN DASHBOARD COLORS ====================

  // Header Gradient (Teal)
  static const Color headerGradientStart = Color(0xFF2C5F5F);
  static const Color headerGradientEnd = Color(0xFF1E4343);

  // Stat Card Accent Colors
  static const Color blueAccent = Color(0xFF5FC8E8);
  static const Color orangeAccent = Color(0xFFF5A962);
  static const Color greenAccent = Color(0xFF4DD0A1);
  static const Color purpleAccent = Color(0xFF9B8AC4);

  // Chart Colors (Multi-color bars) - Modern palette
  static const Color chartPink = Color(0xFFE88D8D);
  static const Color chartPurple = Color(0xFF9B8AC4);
  static const Color chartNavy = Color(0xFF2C5F5F);
  static const Color chartTeal = Color(0xFF3D7575);
  static const Color chartYellow = Color(0xFFFDD5A8);
  static const Color chartOrange = Color(0xFFF5A962);

  // Modern Backgrounds
  static const Color modernBg = Color(0xFFF5F5F5); // Light gray
  static const Color cardBg = Colors.white;

  // Shadow helper
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );

  // ==================== THEME DATA ====================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: card,
        onSurface: textPrimary,
        // DIHAPUS: Properti 'background' di dalam ColorScheme sudah deprecated.
        // background: background,
      ),

      // Scaffold
      // Pengaturan ini sudah benar untuk mengatur warna latar belakang utama aplikasi.
      scaffoldBackgroundColor: background,

      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 1,
        centerTitle: false,
        backgroundColor: card,
        foregroundColor: textPrimary,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins', // Contoh penggunaan custom font
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: card,
        margin: EdgeInsets.zero,
      ),

      // TextTheme
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleMedium: TextStyle(fontSize: 16, color: textSecondary),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      ),

      // ListTileTheme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        subtitleTextStyle: const TextStyle(fontSize: 14, color: textSecondary),
        iconColor: primary,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: primary.withAlpha(26),
        labelStyle: const TextStyle(
          color: primary,
          fontWeight: FontWeight.bold,
        ),
        side: BorderSide.none,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: divider,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
