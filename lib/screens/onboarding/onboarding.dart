import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';

// If you cannot import relative paths, use: import 'package:baby_care/utils/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data for the three screens based on your reference image
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Effortless\nTracking",
      "text": "Log feeds and sleep with one hand.",
      "icon":
          Icons.touch_app_rounded, // Placeholder for "Man relaxing with phone"
    },
    {
      "title": "Understand\nTheir Rhythm.",
      "text": "Spot patterns in growth and behavior.",
      "icon": Icons.bar_chart_rounded, // Placeholder for "Charts/Graphs"
    },
    {
      "title": "Your Village\nawaits.",
      "text": "Connect with parents on the same journey.",
      "icon": Icons.groups_rounded, // Placeholder for "Parents group"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // IMAGE / ICON AREA
                        // Replace this Container/Icon with Image.asset(...) for your real images
                        Container(
                          height: size.height * 0.35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors
                                .surfaceLight, // Using surface color for placeholder bg
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            _onboardingData[index]['icon'],
                            size: 100,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        // TITLE
                        Text(
                          _onboardingData[index]['title'],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.onBackground,
                            height:
                                1.2, // Fix line height for multi-line titles
                          ),
                        ),
                        const SizedBox(height: 16),
                        // DESCRIPTION
                        Text(
                          _onboardingData[index]['text'],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(
                              0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // BOTTOM SECTION (Dots + Button)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Dot Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => buildDot(index: index),
                      ),
                    ),
                    const Spacer(),

                    // Main Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            // TODO: Navigate to Login or Home Screen
                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            debugPrint("Navigate to Home/Login");
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          // Use the button style defined in AppTheme, but we can override specific props here if needed
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? "Get Started"
                              : "Next",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the pagination dots
  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primary
            : AppColors.borderLight, // Inactive color
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
