import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Brand Colors
  // A soft purple extracted from buttons and icons
  static const Color primary = Color(0xFFA88BFA);
  // A lighter shade of the primary color
  static const Color primaryLight = Color(0xFFD1C4FB);
  // A darker shade of the primary color
  static const Color primaryDark = Color(0xFF7E57C2);

  // Accent colors from charts and icons
  static const Color accentYellow = Color(0xFFFFD700); // Gold/Yellow for stars
  static const Color accentGreen = Color(0xFF4CAF50); // Green for growth/success
  static const Color accentBlue = Color(0xFF2196F3); // Blue for charts
  static const Color accentPink = Color(0xFFE91E63); // Pink for charts

  // Neutral Colors (Light Mode)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF); // Card background
  static const Color textPrimaryLight = Color(0xFF111111); // Main headings
  static const Color textSecondaryLight = Color(0xFF444444); // Body text
  static const Color textTertiaryLight = Color(0xFF888888); // Subtitles, captions
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color iconLight = Color(0xFF111111);

  // Neutral Colors (Dark Mode)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E); // Card background
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // Main headings
  static const Color textSecondaryDark = Color(0xFFEEEEEE); // Body text
  static const Color textTertiaryDark = Color(0xFFAAAAAA); // Subtitles, captions
  static const Color borderDark = Color(0xFF333333);
  static const Color iconDark = Color(0xFFFFFFFF);

  // Functional Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFBC02D);
  static const Color info = Color(0xFF1976D2);

  // Shadows
  static const Color shadow = Color(0x1F000000); // Light shadow
}