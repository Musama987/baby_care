import 'package:baby_care/screens/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'utils/app_themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Care',
      debugShowCheckedModeBanner: false,

      // Apply the Custom Themes defined in app_themes.dart
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Uses device system setting (Light/Dark)

      // Set Onboarding as the home screen
      home: const OnboardingScreen(),
    );
  }
}
