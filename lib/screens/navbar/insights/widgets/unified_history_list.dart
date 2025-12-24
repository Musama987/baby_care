import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/database_service.dart';
import '../../../../models/activity_log_model.dart';
import '../../../../models/user_model.dart';
import '../../../../utils/app_colors.dart';

class UnifiedActivityHistoryList extends StatelessWidget {
  final String activityType; // 'feed', 'sleep', 'diaper', 'vaccine', etc.
  final String? subtypeFilter; // 'nursing', 'bottle', 'solids', etc. (Optional)
  final DateTime? startDate;
  final DateTime? endDate;

  const UnifiedActivityHistoryList({
    super.key,
    required this.activityType,
    this.subtypeFilter,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return FutureBuilder<UserModel?>(
      future: DatabaseService().getUser(user.uid),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final babyId = userSnapshot.data?.currentBabyId;
        if (babyId == null) {
          return Center(child: Text("No baby selected"));
        }

        return StreamBuilder<List<ActivityLogModel>>(
          stream: DatabaseService().getLogsStream(
            uid: user.uid,
            babyId: babyId,
            type: activityType,
            subtype: subtypeFilter,
            startDate: startDate,
            endDate: endDate,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Error loading logs: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: AppColors.error),
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      "No records found",
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            final logs = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = logs[index];
                return _buildLogCard(log);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLogCard(ActivityLogModel log) {
    switch (activityType) {
      case 'feed':
        return _buildFeedCard(log);
      case 'sleep':
        return _buildSleepCard(log);
      case 'diaper':
        return _buildDiaperCard(log);
      default:
        return _buildGenericCard(log);
    }
  }

  Widget _buildFeedCard(ActivityLogModel log) {
    IconData icon;
    Color color;
    String title;
    String subtitle;

    if (log.subType == 'nursing') {
      icon = Icons.baby_changing_station; // Placeholder, maybe use better icon
      color = Colors.pinkAccent;
      title = "Nursing";
      final left = log.details['leftDuration'] ?? 0;
      final right = log.details['rightDuration'] ?? 0;
      final total = log.details['totalDuration'] ?? 0;
      subtitle =
          "${(total / 60).toStringAsFixed(1)} min (L: ${(left / 60).toStringAsFixed(0)}m, R: ${(right / 60).toStringAsFixed(0)}m)";
    } else if (log.subType == 'bottle') {
      icon = Icons.local_drink_rounded;
      color = Colors.blueAccent;
      title = "Bottle";
      subtitle = "${log.details['amount']} oz";
    } else {
      icon = Icons.restaurant_rounded;
      color = Colors.orangeAccent;
      title = "Solids";
      subtitle = "${log.details['food']} (${log.details['amount']}g)";
    }

    return _buildBaseCard(
      icon: icon,
      iconColor: color,
      title: title,
      subtitle: subtitle,
      timestamp: log.timestamp,
    );
  }

  Widget _buildSleepCard(ActivityLogModel log) {
    // duration is in seconds
    final durationSeconds = log.details['duration'] ?? 0;
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;

    String durationStr = "";
    if (hours > 0) durationStr += "${hours}h ";
    durationStr += "${minutes}m";

    return _buildBaseCard(
      icon: Icons.nightlight_round,
      iconColor: Colors.indigoAccent,
      title: "Sleep",
      subtitle: durationStr,
      timestamp: log.timestamp,
    );
  }

  Widget _buildDiaperCard(ActivityLogModel log) {
    IconData icon = Icons.layers;
    Color color = Colors.grey;
    String title = "Diaper";
    String status = log.subType ?? 'Unknown'; // Wet, Dirty, Mixed

    if (status.toLowerCase().contains('wet')) {
      color = Colors.blue;
    } else if (status.toLowerCase().contains('dirty')) {
      color = Colors.brown;
    } else {
      color = Colors.purple; // Mixed
    }

    return _buildBaseCard(
      icon: icon,
      iconColor: color,
      title: title,
      subtitle: status, // e.g. "Wet", "Dirty"
      timestamp: log.timestamp,
    );
  }

  Widget _buildGenericCard(ActivityLogModel log) {
    return _buildBaseCard(
      icon: Icons.notes,
      iconColor: Colors.grey,
      title: log.type.toUpperCase(),
      subtitle: log.subType ?? '',
      timestamp: log.timestamp,
    );
  }

  Widget _buildBaseCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required DateTime timestamp,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF1E2623),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLightGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('hh:mm a').format(timestamp),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
