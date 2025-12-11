import 'package:baby_care/screens/auth/login/login.dart';
import 'package:baby_care/screens/auth/signup/signup.dart';
import 'package:baby_care/screens/baby_relationship/baby_setup.dart';
import 'package:baby_care/screens/baby_relationship/realtionship.dart';
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
      // Start with Onboarding
      home: const OnboardingScreen(),

      // Define routes for easier navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/relationship': (context) => const RelationshipScreen(),
        '/baby-setup': (context) => const BabySetupScreen(), // New Route
      },
    );
  }
}
