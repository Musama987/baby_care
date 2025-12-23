import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'add_vaccines_record.dart';

class VaccinesScreen extends StatefulWidget {
  const VaccinesScreen({super.key});

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  // Mock Data mimicking a vaccination schedule
  final List<Map<String, dynamic>> _vaccineSchedule = [
    {
      "age": "Birth",
      "vaccines": "Hep B",
      "status": "completed", // completed, due, upcoming
      "date": "Given: Jan 12",
    },
    {
      "age": "2 Months",
      "vaccines": "DTaP, IPV, Hib, Hep B, PCV13, Rotavirus",
      "status": "completed",
      "date": "Given: Mar 15",
    },
    {
      "age": "4 Months",
      "vaccines": "DTaP, IPV, Hib, PCV13, Rotavirus",
      "status": "due",
      "date": "Due: May 15",
    },
    {
      "age": "6 Months",
      "vaccines": "DTaP, IPV, Hib, Hep B, PCV13, Rotavirus, Influenza",
      "status": "upcoming",
      "date": "Due: July 15",
    },
    {
      "age": "12 Months",
      "vaccines": "MMR, Varicella, Hep A, PCV13",
      "status": "upcoming",
      "date": "Due: Jan 12, 2025",
    },
    {
      "age": "15 Months",
      "vaccines": "DTaP, Hib, IPV",
      "status": "upcoming",
      "date": "Due: Apr 12, 2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: const Color(0xFF1E2623),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Title Section (Removed "BabyCare 360") ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Vaccination Schedule",
                style: GoogleFonts.poppins(
                  fontSize: 24, // Slightly smaller for compactness
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2623),
                ),
              ),
            ),
            const SizedBox(height: 20), // Reduced spacing
            // --- Timeline List ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _vaccineSchedule.length,
                itemBuilder: (context, index) {
                  final item = _vaccineSchedule[index];
                  return _buildTimelineItem(item, index);
                },
              ),
            ),

            // --- Bottom Button ---
            Container(
              padding: const EdgeInsets.all(20), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50, // Reduced height
                child: ElevatedButton(
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const AddVaccineRecord(),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Add Record",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item, int index) {
    bool isCompleted = item['status'] == 'completed';
    bool isLast = index == _vaccineSchedule.length - 1;
    bool isFirst = index == 0;

    // Define colors based on status
    Color indicatorColor = isCompleted
        ? AppColors.primary
        : Colors.grey.shade300;
    Color lineColor = isCompleted ? AppColors.primary : Colors.grey.shade300;
    Color titleColor = isCompleted || item['status'] == 'due'
        ? const Color(0xFF1E2623)
        : Colors.grey.shade500;

    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      alignment: TimelineAlign.manual,
      lineXY: 0.0, // Aligns line to the very left edge (start) of the tile area
      beforeLineStyle: LineStyle(color: lineColor, thickness: 2),
      afterLineStyle: LineStyle(
        color:
            (isCompleted &&
                index < _vaccineSchedule.length - 1 &&
                _vaccineSchedule[index + 1]['status'] == 'completed')
            ? AppColors.primary
            : Colors.grey.shade300,
        thickness: 2,
      ),
      indicatorStyle: IndicatorStyle(
        width: 24, // Smaller indicator
        height: 24,
        padding: const EdgeInsets.only(right: 12), // Space between dot and text
        indicator: Container(
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? AppColors.primary : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
      ),
      endChild: Container(
        // Compact spacing: reduced bottom padding and removed minimum height constraint
        padding: const EdgeInsets.only(bottom: 12, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Row to align Age Title with the indicator visually
            Row(
              children: [
                Text(
                  item['age'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold, // Bold for emphasis
                    color: titleColor,
                    height: 1.0, // Tighter line height to align with dot
                  ),
                ),
                const SizedBox(width: 8),
                // Status/Date Badge next to title for compactness
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: item['status'] == 'due'
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['status'] == 'due' ? "Due Soon" : "",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Vaccines List
            Text(
              item['vaccines'],
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF5A5A5A),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 2),

            // Date Text
            Text(
              item['date'],
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
