import 'package:baby_care/screens/navbar/insights/widgets/feed_history.dart';
import 'package:baby_care/screens/navbar/insights/widgets/sleep_history.dart';
import 'package:baby_care/screens/navbar/insights/widgets/diaper_history.dart';
import 'package:baby_care/screens/navbar/insights/widgets/appointment.dart';
import 'package:baby_care/screens/navbar/insights/widgets/growth.dart';
import 'package:baby_care/screens/navbar/insights/widgets/medication.dart';
import 'package:baby_care/screens/navbar/insights/widgets/vaccines.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../utils/app_colors.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // Matches your app background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Section ---
              // "BabyCare 360" text removed as requested
              const SizedBox(height: 10),
              Text(
                "Health Hub",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2623),
                ),
              ),
              const SizedBox(height: 30),

              // --- Log Feed Card ---
              _buildHealthCard(
                context,
                title: "Feed History",
                subtitle: "Track breastfeeding, bottle, and solids.",
                icon: Icons.baby_changing_station,
                buttonText: "View Feed Log",
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const FeedHistoryScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
              const SizedBox(height: 24),

              // --- Log Sleep Card ---
              _buildHealthCard(
                context,
                title: "Sleep History",
                subtitle: "Monitor sleep patterns and duration.",
                icon: Icons.nightlight_round,
                buttonText: "View Sleep Log",
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const SleepHistoryScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
              const SizedBox(height: 24),

              // --- Log Diaper Card ---
              _buildHealthCard(
                context,
                title: "Diaper History",
                subtitle: "Track diaper changes and health indicators.",
                icon: Icons.layers,
                buttonText: "View Diaper Log",
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const DiaperHistoryScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
              const SizedBox(height: 24),

              // --- Growth Card ---
              _buildHealthCard(
                context,
                title: "Growth",
                subtitle: "Recent: 14.5 lbs (+0.5)",
                icon: Icons.show_chart_rounded,
                buttonText: "View Charts",
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const GrowthScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
              const SizedBox(height: 24),

              // --- Vaccines Card ---
              _buildHealthCard(
                context,
                title: "Vaccines",
                subtitle: "Next vaccine due in 2 weeks (Rotavirus).",
                icon: Icons.access_time_rounded,
                buttonText: "View Schedule",
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const VaccinesScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
              const SizedBox(height: 24),

              // --- Meds Card ---
              _buildHealthCard(
                context,
                title: "Meds",
                subtitle: "No active medications.",
                icon: Icons.medication_outlined,
                buttonText: "Add Med",
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const Medication(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
              const SizedBox(height: 24),

              // --- Appointments Card ---
              _buildHealthCard(
                context,
                title: "Appointments",
                subtitle: "Pediatrician check-up in 3 days.",
                icon: Icons.calendar_month_rounded,
                buttonText: "View Appointments",
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const AppointmentScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),

              // Extra space for bottom nav bar
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFF1E2623), // Dark icon color
                ),
              ),
              const SizedBox(width: 8),
              // Text Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E2623),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF5A5A5A),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
