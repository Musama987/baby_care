import 'package:baby_care/screens/auth/login/login.dart';
import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // Light cream background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              // --- Header ---
              Text(
                "Profile",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2623),
                ),
              ),
              const SizedBox(height: 20),

              // --- User Avatar ---
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/men.png'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.grey.shade100),
                ),
              ),
              const SizedBox(height: 12),

              // --- User Name ---
              Text(
                "Sarah M.",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2623),
                ),
              ),
              const SizedBox(height: 20),

              // --- Baby Details Card (Leo) ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white, // Pure White
                  borderRadius: BorderRadius.circular(24),
                  // Same Border & Shadow as requested for other cards
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Baby Image
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/family.png'),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Baby Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: "Leo, ",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E2623),
                              ),
                              children: [
                                TextSpan(
                                  text: "\n4 months",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xFF1E2623),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit Pill Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEEEA), // Muted beige/grey
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Edit",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5A5A5A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Menu Items (Now matching Leo Card Style) ---
              _buildMenuItem(
                icon: Icons.person_outline_rounded,
                text: "Care Team",
                onTap: () {},
              ),
              const SizedBox(height: 8),

              _buildMenuItem(
                icon: Icons.nightlight_outlined,
                text: "Dark Mode",
                isSwitch: true,
                switchValue: _isDarkMode,
                onSwitchChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
              ),
              const SizedBox(height: 8),

              _buildMenuItem(
                icon: Icons.notifications_none_rounded,
                text: "Notifications",
                onTap: () {},
              ),
              const SizedBox(height: 8),

              _buildMenuItem(
                icon: Icons.share_outlined,
                text: "Export Data",
                onTap: () {},
              ),
              const SizedBox(height: 8),

              _buildMenuItem(
                icon: Icons.straighten_outlined,
                text: "Units",
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // --- Log Out Button ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FB89A), // Muted Green
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Log Out",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    bool isSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // UPDATED: Pure White like Leo card
        borderRadius: BorderRadius.circular(24), // Stadium/Pill shape
        // UPDATED: Same border as Leo card
        border: Border.all(color: Colors.grey.shade100),
        // UPDATED: Same shadow as Leo card
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSwitch ? null : onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF6B8E78), // Muted green icon color
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E2623),
                    ),
                  ),
                ),
                if (isSwitch)
                  SizedBox(
                    height: 24,
                    child: Switch.adaptive(
                      value: switchValue,
                      activeColor: const Color(0xFF8FB89A),
                      activeTrackColor: const Color(
                        0xFF8FB89A,
                      ).withOpacity(0.4),
                      onChanged: onSwitchChanged,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
