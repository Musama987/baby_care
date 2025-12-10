import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  // Font Family - Assuming 'Poppins' based on the visual style.
  // Make sure to add this font to your pubspec.yaml.
  static const String _fontFamily = 'Poppins';

  // Spacing & Padding Constants
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border Radius Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  // Highly rounded corners for primary buttons.
  static const double borderRadiusButton = 30.0;

  // Typography Theme
  static TextTheme _textTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      // Large headings (e.g., "Find your child's doctor")
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
        height: 1.2,
      ),
      // Section headings (e.g., "Choose a service", "Top Doctors")
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      // Card titles, doctor names
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      // Sub-titles
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      // Main body text
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: primaryTextColor,
      ),
      // Secondary body text, descriptions
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
      ),
      // Button text style
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      // Captions, small labels (e.g., dates, reviews count)
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
      ),
    );
  }

  // Input Decoration Theme (Text Fields)
  static InputDecorationTheme _inputDecorationTheme(Color fillColor, Color hintColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: paddingMedium,
        vertical: paddingMedium,
      ),
      hintStyle: TextStyle(
        fontFamily: _fontFamily,
        color: hintColor,
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      prefixIconColor: hintColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        // Primary color border on focus
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  // Elevated Button Theme (Primary Buttons)
  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        padding: const EdgeInsets.symmetric(vertical: paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusButton),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0, // Flat style as seen in images
      ),
    );
  }

  // Outlined Button Theme (Secondary Buttons)
  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusButton),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Text Button Theme (e.g., "View all", "Forgot Password?")
  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Card Theme
  static CardThemeData _cardTheme(Color color) {
    return CardThemeData(
      color: color,
      elevation: 0, // Most cards appear flat or with a custom soft shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusLarge),
      ),
      margin: EdgeInsets.zero,
    );
  }
  
  // AppBar Theme
  static AppBarTheme _appBarTheme(Color backgroundColor, Color iconColor, Color titleColor) {
    return AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: iconColor),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: titleColor,
      ),
      // Ensure status bar icons are visible
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: titleColor == AppColors.textPrimaryLight ? Brightness.dark : Brightness.light,
      ),
    );
  }

  // Bottom Navigation Bar Theme
  static BottomNavigationBarThemeData _bottomNavigationBarTheme(Color backgroundColor, Color selectedItemColor, Color unselectedItemColor) {
    return BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
      ),
      elevation: 10.0, // Add elevation for a shadow effect
    );
  }

  // Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primary,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        error: AppColors.error,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textPrimaryLight,
        onBackground: AppColors.textPrimaryLight,
        onError: AppColors.textWhite,
      ),
      textTheme: _textTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight),
      inputDecorationTheme: _inputDecorationTheme(AppColors.inputFillLight, AppColors.textHint),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      cardTheme: _cardTheme(AppColors.surfaceLight),
      appBarTheme: _appBarTheme(AppColors.backgroundLight, AppColors.textPrimaryLight, AppColors.textPrimaryLight),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(AppColors.surfaceLight, AppColors.primary, AppColors.iconGrey),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      dividerColor: AppColors.divider,
    );
  }

  // Dark Theme Configuration (Inferred)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primary,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.error,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textPrimaryDark,
        onBackground: AppColors.textPrimaryDark,
        onError: AppColors.textWhite,
      ),
      textTheme: _textTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
      inputDecorationTheme: _inputDecorationTheme(AppColors.inputFillDark, AppColors.textSecondaryDark),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      cardTheme: _cardTheme(AppColors.surfaceDark),
      appBarTheme: _appBarTheme(AppColors.backgroundDark, AppColors.textPrimaryDark, AppColors.textPrimaryDark),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(AppColors.surfaceDark, AppColors.primary, AppColors.textSecondaryDark),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      dividerColor: const Color(0xFF333333),
    );
  }
}