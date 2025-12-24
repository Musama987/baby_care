import 'package:baby_care/screens/navbar/home/widgets/log_diaper.dart';
import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/scheduler.dart';
import 'package:baby_care/screens/navbar/home/widgets/log_feed.dart';
import 'package:baby_care/screens/navbar/home/widgets/log_sleep.dart';
import 'package:baby_care/screens/navbar/home/widgets/log_vaccine.dart';
import 'package:baby_care/screens/navbar/home/widgets/log_growth.dart';
import 'package:baby_care/screens/navbar/home/widgets/log_appointment.dart';
import 'package:baby_care/screens/navbar/home/widgets/log_medication.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/database_service.dart';
import '../../../models/user_model.dart';
import '../../../models/baby_model.dart';
import '../../baby_relationship/baby_setup.dart';

// HomeScreen wrapper removed. Navbar logic moved to lib/screens/navbar/navbar.dart.

// --- Main Dashboard Widget (The Home Tab) ---
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  // Dropdown state - managed by Firestore now
  // String _selectedChild = "Leo";
  // final List<String> _children = ["Leo", "Mia", "Noah"];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in"));
    }

    return StreamBuilder<UserModel>(
      stream: DatabaseService().getUserStream(user.uid),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data;
        final userName = userData?.name ?? "User";
        final currentBabyId = userData?.currentBabyId;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header with Functional Dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${_getGreeting()},\n$userName",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E2623),
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Baby Selection Section
                    StreamBuilder<List<BabyModel>>(
                      stream: DatabaseService().getUserBabiesStream(user.uid),
                      builder: (context, babiesSnapshot) {
                        final babies = babiesSnapshot.data ?? [];

                        // Determine selected value.
                        String? effectiveBabyId = currentBabyId;
                        if (babies.isNotEmpty &&
                            (effectiveBabyId == null ||
                                !babies.any((b) => b.id == effectiveBabyId))) {
                          effectiveBabyId = babies.first.id;
                          // Optional: Auto-update user's selection if invalid
                          // DatabaseService().updateUserCurrentBaby(user.uid, effectiveBabyId);
                        }

                        return Row(
                          children: [
                            if (babies.isNotEmpty)
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: effectiveBabyId,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 20,
                                    ),
                                    elevation: 2,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E2623),
                                      fontSize: 14,
                                    ),
                                    onChanged: (String? newBabyId) {
                                      if (newBabyId != null &&
                                          newBabyId != currentBabyId) {
                                        DatabaseService().updateUserCurrentBaby(
                                          user.uid,
                                          newBabyId,
                                        );
                                      }
                                    },
                                    items: babies.map<DropdownMenuItem<String>>(
                                      (BabyModel baby) {
                                        return DropdownMenuItem<String>(
                                          value: baby.id,
                                          child: Text(baby.name),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),

                            const SizedBox(width: 8),

                            // Add Baby Button
                            GestureDetector(
                              onTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: const BabySetupScreen(),
                                  withNavBar: false,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary, // Make it distinct
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Last Fed Card with Border - CONNECTED TO STREAM
                if (currentBabyId != null)
                  StreamBuilder(
                    // Fetch LAST activity of type 'feed'.
                    // Use a query that orders by timestamp desc limit 1.
                    stream: DatabaseService().getLatestActivityStream(
                      user.uid,
                      currentBabyId,
                      'feed',
                    ),
                    builder: (context, snapshot) {
                      DateTime? lastFedTime;

                      if (snapshot.hasData && snapshot.data != null) {
                        lastFedTime = snapshot.data!.timestamp;
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF7F9F8,
                          ), // Very light green/grey
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Last Fed",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1E2623),
                                  ),
                                ),
                                Icon(
                                  Icons.baby_changing_station,
                                  color: Colors.blue.shade300,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Use TimeAgoWidget for live updates
                            if (lastFedTime != null)
                              TimeAgoWidget(timestamp: lastFedTime)
                            else if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              Text(
                                "Loading...",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade400,
                                ),
                              )
                            else
                              Text(
                                "No data",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                if (currentBabyId == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: const Text("Select a baby to see data"),
                  ),

                const SizedBox(height: 16),

                // 3. Quick Actions Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildActionCard(
                      title: "Log Feed",
                      iconPath: "assets/icons/feed.png",
                      color: AppColors.primary,
                      iconBgColor: AppColors.primary,
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const LogFeedScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    _buildActionCard(
                      title: "Log Sleep",
                      iconPath: "assets/icons/moon.png",
                      color: const Color(0xFF5C6BC0),
                      iconBgColor: const Color(0xFF5C6BC0),
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const LogSleepScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    _buildActionCard(
                      title: "Log Diaper",
                      iconPath: "assets/icons/poop.png",
                      color: const Color(0xFFA1887F),
                      iconBgColor: const Color.fromARGB(255, 207, 103, 66),
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const LogDiaperScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    _buildActionCard(
                      title: "Growth",
                      iconPath: "assets/icons/growth.png",
                      color: const Color(0xFFE57373),
                      iconBgColor: const Color(0xFFE57373),
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const LogGrowthScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    _buildActionCard(
                      title: "Vaccines",
                      icon: Icons.shield_outlined,
                      color: Colors.teal,
                      iconBgColor: Colors.teal,
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const LogVaccineScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    _buildActionCard(
                      title: "Appointment",
                      icon: Icons.calendar_month_rounded,
                      color: Colors.purple,
                      iconBgColor: Colors.purple,
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const LogAppointmentScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    _buildActionCard(
                      title: "Meds",
                      icon: Icons.medication_outlined,
                      color: Colors.orangeAccent,
                      iconBgColor: Colors.orangeAccent,
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const LogMedicationScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Today's Summary - CONNECTED TO STREAM
                if (currentBabyId != null)
                  StreamBuilder(
                    stream: DatabaseService().getDailyLogsStream(
                      user.uid,
                      currentBabyId,
                      DateTime.now(),
                    ),
                    builder: (context, snapshot) {
                      double sleepHours = 0;
                      double milkOz = 0;
                      // Placeholder max values for progress bars
                      double maxSleep = 14;
                      double maxMilk = 32;

                      if (snapshot.hasData && snapshot.data != null) {
                        final logs = snapshot.data!;
                        for (var log in logs) {
                          if (log.type == 'sleep') {
                            final durationSec =
                                log.details['duration'] as int? ?? 0;
                            sleepHours += durationSec / 3600;
                          } else if (log.type == 'feed' &&
                              log.subType == 'bottle') {
                            // Assuming 'amount' is stored in oz
                            final amount = log.details['amount'];
                            if (amount is int) milkOz += amount;
                            if (amount is double) milkOz += amount;
                            // Check if amount is string and parse if needed
                            if (amount is String)
                              milkOz += double.tryParse(amount) ?? 0;
                          }
                        }
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Summary",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E2623),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Sleep Progress
                            _buildProgressBar(
                              label: "Sleep",
                              value: "${sleepHours.toStringAsFixed(1)}h",
                              progress: (sleepHours / maxSleep).clamp(0.0, 1.0),
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 12),

                            // Milk Progress
                            _buildProgressBar(
                              label: "Milk",
                              value: "${milkOz.toStringAsFixed(1)}oz",
                              progress: (milkOz / maxMilk).clamp(0.0, 1.0),
                              color: const Color(0xFFE57373),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required String title,
    String? iconPath,
    IconData? icon,
    required Color color,
    required Color iconBgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ), // Subtle white border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06), // Improved shadow
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: icon != null
                  ? Icon(icon, color: iconBgColor, size: 24)
                  : Image.asset(
                      iconPath!,
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E2623),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$label: $value",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E2623),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- TimeAgoWidget for Live Updates ---
class TimeAgoWidget extends StatefulWidget {
  final DateTime timestamp;

  const TimeAgoWidget({super.key, required this.timestamp});

  @override
  State<TimeAgoWidget> createState() => _TimeAgoWidgetState();
}

class _TimeAgoWidgetState extends State<TimeAgoWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (mounted) setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(widget.timestamp);

    String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      final minutes = diff.inMinutes % 60;
      if (minutes == 0) {
        timeAgo = "${diff.inHours} hours ago";
      } else {
        timeAgo = "${diff.inHours} h ${minutes} min ago";
      }
    } else {
      timeAgo = "${diff.inDays} days ago";
    }

    // Handle just added case (negative or zero)
    if (diff.inSeconds < 60 && diff.inMinutes == 0) {
      timeAgo = "Just now";
    }

    // User asked "if baby feed 3.30 pm ans now 3.39 so 9 minut update show"
    // The "min" calculation above handles this.

    return Text(
      timeAgo,
      style: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: -0.5,
      ),
    );
  }
}
