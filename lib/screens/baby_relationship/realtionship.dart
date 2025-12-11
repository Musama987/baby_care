import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_themes.dart';

class RelationshipScreen extends StatefulWidget {
  const RelationshipScreen({super.key});

  @override
  State<RelationshipScreen> createState() => _RelationshipScreenState();
}

class _RelationshipScreenState extends State<RelationshipScreen> {
  // Track the selected option. -1 means nothing is selected.
  int _selectedIndex = -1;

  final List<Map<String, dynamic>> _roles = [
    {'title': 'Mother', 'icon': Icons.face_3_outlined},
    {'title': 'Father', 'icon': Icons.face_6_outlined},
    {'title': 'Caretaker/Nanny', 'icon': Icons.child_care_outlined},
    {'title': 'Relative', 'icon': Icons.favorite_border_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // Light cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
        // Removed the "A06 Role Selection" title as requested
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Title
              Text(
                "What's your\nrelationship to\nthe little one?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2623),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),

              // Grid of Options
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio:
                        0.85, // Adjust for card height/width ratio
                  ),
                  itemCount: _roles.length,
                  itemBuilder: (context, index) {
                    final role = _roles[index];
                    final isSelected = _selectedIndex == index;

                    return _buildRoleCard(
                      index: index,
                      title: role['title'],
                      icon: role['icon'],
                      isSelected: isSelected,
                    );
                  },
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedIndex != -1
                      ? () {
                          // TODO: Handle navigation or data saving
                          print(
                            "Selected Role: ${_roles[_selectedIndex]['title']}",
                          );
                        }
                      : null, // Disable if nothing selected
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildRoleCard({
    required int index,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            if (isSelected)
              BoxShadow(
                // Shadow matching the border color (Green)
                color: AppColors.primary.withOpacity(0.39),
                blurRadius: 20,
                spreadRadius: 8, // Slight spread for "border shadow" effect
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Circle
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                // Slight tint for icon background if needed, currently transparent/white based on image
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Icon(
                icon,
                size: 32,
                // Using specific colors to mimic the image's avatar style loosely
                color: isSelected ? AppColors.primary : const Color(0xFF8B6B61),
              ),
            ),
            const SizedBox(height: 12),
            // Text
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xFF1E2623),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
