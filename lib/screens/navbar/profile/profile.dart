import 'package:baby_care/screens/auth/login/login.dart';
import 'package:baby_care/services/auth_service.dart';
import 'package:baby_care/utils/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
              const SizedBox(height: 10),

              // --- User Avatar ---
              Container(
                height: 80,
                width: 80,
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
              const SizedBox(height: 8),

              // --- User Name ---
              Text(
                "Sarah M.",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2623),
                ),
              ),
              const SizedBox(height: 16),

              // --- Baby Details Card (Leo) ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
              const SizedBox(height: 16),

              _buildMenuItem(
                icon: Icons.settings_outlined,
                text: "Settings",
                onTap: () {},
              ),
              const SizedBox(height: 8),

              _buildMenuItem(
                icon: Icons.access_time_rounded,
                text: "Reminders",
                onTap: () {},
              ),
              const SizedBox(height: 8),

              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                text: "Privacy Policy",
                onTap: () {},
              ),
              const SizedBox(height: 8),

              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                text: "FAQ",
                onTap: () {},
              ),
              const SizedBox(height: 8),

              _buildMenuItem(
                icon: Icons.info_outline_rounded,
                text: "About Us",
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // --- Log Out Button ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutConfirmationDialog(context);
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
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return AlertDialog(
          title: Text(
            "Logout",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E2623),
            ),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: GoogleFonts.poppins(color: Colors.grey.shade600),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatefulBuilder(
                  builder: (context, setState) {
                    return OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);

                              await AuthService().signOut();

                              if (context.mounted) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Text(
                              "OK",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
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
        borderRadius: BorderRadius.circular(18), // Stadium/Pill shape
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
          borderRadius: BorderRadius.circular(18),
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
