import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../utils/app_colors.dart';
import '../../../../services/database_service.dart';
import '../../../../models/activity_log_model.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  // 0 = Upcoming, 1 = Past

  Stream<List<ActivityLogModel>>? _appointmentStream;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await DatabaseService().getUser(user.uid);
      if (userDoc?.currentBabyId != null) {
        setState(() {
          _appointmentStream = DatabaseService().getLogsStream(
            uid: user.uid,
            babyId: userDoc!.currentBabyId!,
            type: 'appointment',
          );
        });
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    // Detect theme brightness to switch colors dynamically
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "All Appointments",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _appointmentStream == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<ActivityLogModel>>(
              stream: _appointmentStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final logs = snapshot.data ?? [];

                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No appointments found",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Sort Ascending (Past -> Future)
                logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  itemCount: logs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(logs[index], isDark);
                  },
                );
              },
            ),
    );
  }

  Widget _buildAppointmentCard(ActivityLogModel log, bool isDark) {
    final title = log.details['title'] ?? "Appointment";
    final doctor = log.details['doctor'] ?? "Doctor";
    final notes = log.details['notes'] ?? "";

    final date = DateFormat('dd').format(log.timestamp);
    final month = DateFormat('MMM').format(log.timestamp);
    final year = DateFormat('yyyy').format(log.timestamp);
    final time = DateFormat('hh:mm a').format(log.timestamp);

    // Dynamic Logic:
    // If date is in past (> 24h ago) -> Greyed out / History style?
    // User just asked for "Upcoming and Past overall show"
    // We already sorted them. Let's just make the card look good.

    final isPast = log.timestamp.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Box
          Container(
            width: 65,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isPast
                  ? Colors.grey.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isPast ? Colors.grey : AppColors.primary,
                  ),
                ),
                Text(
                  month,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPast ? Colors.grey : AppColors.primary,
                  ),
                ),
                Text(
                  year,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: isPast
                        ? Colors.grey
                        : AppColors.primary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDark,
                          decoration: isPast
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPast)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Done",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textLightGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLightGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: AppColors.textLightGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textLightGray,
                      ),
                    ),
                  ],
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    notes,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
