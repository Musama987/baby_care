import 'package:baby_care/screens/auth/login/login.dart';
import 'package:baby_care/screens/auth/signup/signup.dart';
import 'package:baby_care/screens/baby_relationship/baby_setup.dart';
import 'package:baby_care/screens/baby_relationship/realtionship.dart';
import 'package:baby_care/screens/navbar/navbar.dart';
import 'package:baby_care/screens/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'utils/app_themes.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:baby_care/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Check Onboarding & Auth Status
  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final user = FirebaseAuth.instance.currentUser;

  Widget initialScreen;
  if (!seenOnboarding) {
    initialScreen = const OnboardingScreen();
  } else if (user != null) {
    initialScreen = const NavbarScreen();
  } else {
    initialScreen = const LoginScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Care',
      debugShowCheckedModeBanner: false,

      // Apply the Custom Themes defined in app_themes.dart
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Uses device system setting (Light/Dark)
      // Start with determined screen
      home: initialScreen,

      // Define routes for easier navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/relationship': (context) => const RelationshipScreen(),
        '/baby-setup': (context) => const BabySetupScreen(),
        '/home': (context) => const NavbarScreen(), // Updated Route
      },
    );
  }
}
