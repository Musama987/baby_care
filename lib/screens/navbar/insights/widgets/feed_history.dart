import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../utils/app_colors.dart';
import 'unified_history_list.dart';

class FeedHistoryScreen extends StatefulWidget {
  const FeedHistoryScreen({super.key});

  @override
  State<FeedHistoryScreen> createState() => _FeedHistoryScreenState();
}

class _FeedHistoryScreenState extends State<FeedHistoryScreen> {
  DateTimeRange? _historyDateRange;
  String _historyFilter = 'All'; // 'All', 'Nursing', 'Bottle', 'Solids'

  void _pickHistoryDateRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: _historyDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _historyDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: Text(
          "Feed History",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: const Color(0xFF1E2623),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: const Color(0xFF1E2623),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // --- Filters Header ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Date Range Picker
                GestureDetector(
                  onTap: _pickHistoryDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: AppColors.textLightGray,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _historyDateRange == null
                                  ? "All History"
                                  : "${DateFormat('MMM dd').format(_historyDateRange!.start)} - ${DateFormat('MMM dd').format(_historyDateRange!.end)}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textLightGray,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Type Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Nursing'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Bottle'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Solids'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Standardized History List ---
          Expanded(
            child: UnifiedActivityHistoryList(
              activityType: 'feed',
              subtypeFilter: _historyFilter == 'All'
                  ? null
                  : _historyFilter.toLowerCase(),
              startDate: _historyDateRange?.start,
              endDate: _historyDateRange?.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _historyFilter == label;
    // Map 'Solids' -> 'solid' if needed by backend, but 'UnifiedActivityList' logic might handle it.
    // In Unified, I used "if (log.subType == 'nursing') ..."
    // Let's pass the label as is to filtered, and Unified list expects lowercase matches usually?
    // In log_feed.dart, I passed `_historyFilter.toLowerCase()`.

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _historyFilter = label;
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? Colors.white : AppColors.textLightGray,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppColors.stroke,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
