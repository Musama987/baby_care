import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Color
  // Estimated from the "Get Started" button and icons.
  static const Color primary = Color(0xFFFD6B8C);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);

  // Surface Colors (Cards, Sheets, Dialogs)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  // Light pink background seen in some cards (e.g., "General Consultation").
  static const Color cardPink = Color(0xFFFFF0F3);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121); // Dark grey for main text
  static const Color textSecondaryLight = Color(0xFF757575); // Medium grey for subtitles
  static const Color textHint = Color(0xFF9E9E9E); // Lighter grey for hints
  static const Color textWhite = Color(0xFFFFFFFF); // For text on primary buttons

  // Dark Mode Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);

  // Input Field Colors
  static const Color inputFillLight = Color(0xFFF5F5F5); // Light grey background for inputs
  static const Color inputFillDark = Color(0xFF2C2C2C);
  static const Color inputBorder = Color(0xFFE0E0E0);

  // State & Status Colors
  static const Color success = Color(0xFF4CAF50); // E.g., for "Active" status
  static const Color warning = Color(0xFFFFC107); // E.g., for star ratings
  static const Color error = Color(0xFFD32F2F);

  // Other Colors
  static const Color iconGrey = Color(0xFF9E9E9E); // For inactive icons
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shadow = Color(0x1F000000); // Light, subtle shadow
}