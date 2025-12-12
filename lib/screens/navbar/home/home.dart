import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// HomeScreen wrapper removed. Navbar logic moved to lib/screens/navbar/navbar.dart.

// --- Main Dashboard Widget (The Home Tab) ---
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  // Dropdown state
  String _selectedChild = "Leo";
  final List<String> _children = ["Leo", "Mia", "Noah"];

  @override
  Widget build(BuildContext context) {
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
                    "Good Morning,\n Sarah",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E2623),
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    // Functional Dropdown
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
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
                          value: _selectedChild,
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
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedChild = newValue;
                              });
                            }
                          },
                          items: _children.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Notification Icon
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.notifications_outlined, size: 24),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Last Fed Card with Border
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F8), // Very light green/grey
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Softer shadow
                    blurRadius: 15, // More blur
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
                      // Bottle Icon
                      Icon(
                        Icons.baby_changing_station,
                        color: Colors.blue.shade300,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "2h 15m ago",
                    style: GoogleFonts.poppins(
                      fontSize: 36, // Larger text
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Quick Actions Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _buildActionCard(
                  title: "Log Feed",
                  icon: Icons.water_drop_rounded,
                  color: AppColors.primary,
                  iconBgColor: AppColors.primary,
                ),
                _buildActionCard(
                  title: "Log Sleep",
                  icon: Icons.nightlight_round,
                  color: const Color(0xFF5C6BC0),
                  iconBgColor: const Color(0xFF5C6BC0),
                ),
                _buildActionCard(
                  title: "Log Diaper",
                  icon: Icons.layers_outlined,
                  color: const Color(0xFFA1887F),
                  iconBgColor: const Color(0xFFA1887F),
                ),
                _buildActionCard(
                  title: "Growth",
                  icon: Icons.monitor_weight_outlined,
                  color: const Color(0xFFE57373),
                  iconBgColor: const Color(0xFFE57373),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Today's Summary
            Container(
              padding: const EdgeInsets.all(20),
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
                    value: "10h 30m",
                    progress: 0.7,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),

                  // Milk Progress
                  _buildProgressBar(
                    label: "Milk",
                    value: "24oz",
                    progress: 0.5,
                    color: const Color(0xFFE57373),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color iconBgColor,
  }) {
    return Container(
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconBgColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
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
