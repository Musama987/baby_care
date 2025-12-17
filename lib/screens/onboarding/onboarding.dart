import 'package:baby_care/screens/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:baby_care/utils/app_colors.dart'; // Uncomment if you use your file
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Effortless\nTracking",
      "text": "Log feeds and sleep with one hand.",
      "image": "assets/images/men.png",
    },
    {
      "title": "Understand\nTheir Rhythm.",
      "text": "Spot patterns in growth and behavior.",
      "image": "assets/images/growthh.png",
    },
    {
      "title": "Your Village\nawaits.",
      "text": "Connect with parents on the same journey.",
      "image": "assets/images/family.png",
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FIX LAG: Precache images so they don't load while swiping
    for (var data in _onboardingData) {
      precacheImage(AssetImage(data['image']), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define your specific green color here to match the design exactly
    const Color primaryGreen = Color(0xFF8CAE93);
    const Color darkText = Color(0xFF2C3E50);

    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Slight off-white/cream background
      body: SafeArea(
        child: Column(
          children: [
            // TOP SECTION: CONTENT (Text + Image)
            Expanded(
              flex: 4, // Gives more space to the content
              child: PageView.builder(
                controller: _pageController,
                physics:
                    const ClampingScrollPhysics(), // Smoother feel than default
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ), // Wider padding like design
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // LEFT ALIGNMENT
                      children: [
                        const SizedBox(height: 40),

                        // TITLE
                        Text(
                          _onboardingData[index]['title'],
                          textAlign: TextAlign.left,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            color: darkText,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // DESCRIPTION
                        Text(
                          _onboardingData[index]['text'],
                          textAlign: TextAlign.left,
                          style: GoogleFonts.dmSans(
                            fontSize: 17,
                            height: 1.4,
                            color: darkText.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // IMAGE
                        // Using Expanded ensures image fills remaining space nicely
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              height: 400,
                              width: 300,
                              _onboardingData[index]['image'],
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),

            // BOTTOM SECTION: DOTS + BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Compacts the bottom
                children: [
                  // Dot Indicator
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Dots are centered in design
                    children: List.generate(
                      _onboardingData.length,
                      (index) =>
                          buildDot(index: index, activeColor: primaryGreen),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Main Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentPage == _onboardingData.length - 1) {
                          // Save seenOnboarding flag
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('seenOnboarding', true);

                          if (context.mounted) {
                            // Navigate to Login Screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          }
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        elevation: 0, // Flat design like image
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? "Get Started"
                            : "Next",
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({required int index, required Color activeColor}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? activeColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
