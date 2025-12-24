import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../services/database_service.dart';
import '../../../../models/activity_log_model.dart';

class VaccinesScreen extends StatefulWidget {
  const VaccinesScreen({super.key});

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  // Base Schedule

  Stream<List<ActivityLogModel>>? _vaccineStream;

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
          _vaccineStream = DatabaseService().getLogsStream(
            uid: user.uid,
            babyId: userDoc!.currentBabyId!,
            type: 'vaccine',
          );
        });
      }
    }
  }

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Vaccination Schedule",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2623),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _vaccineStream == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<List<ActivityLogModel>>(
                      stream: _vaccineStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No vaccination schedule found",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Add a record to start the timeline",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final logs = snapshot.data!;

                        // Sort logs Ascending (Oldest -> Newest)
                        final sortedLogs = List<ActivityLogModel>.from(logs);
                        sortedLogs.sort((a, b) {
                          final aDateStr = a.details['date'] as String?;
                          final bDateStr = b.details['date'] as String?;
                          DateTime aDate = a.timestamp;
                          DateTime bDate = b.timestamp;

                          if (aDateStr != null) {
                            try {
                              final p = aDateStr.split('/');
                              if (p.length == 3)
                                aDate = DateTime(
                                  int.parse(p[2]),
                                  int.parse(p[1]),
                                  int.parse(p[0]),
                                );
                            } catch (_) {}
                          }
                          if (bDateStr != null) {
                            try {
                              final p = bDateStr.split('/');
                              if (p.length == 3)
                                bDate = DateTime(
                                  int.parse(p[2]),
                                  int.parse(p[1]),
                                  int.parse(p[0]),
                                );
                            } catch (_) {}
                          }
                          return aDate.compareTo(bDate); // Ascending
                        });

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          itemCount: sortedLogs.length,
                          itemBuilder: (context, index) {
                            final log = sortedLogs[index];
                            final isLast = index == sortedLogs.length - 1;
                            final isFirst = index == 0;

                            // Extract data
                            final name = log.details['name'] ?? "Vaccine";
                            final dateStr = log.details['date'] as String?;
                            DateTime vaccineDate = log.timestamp;

                            if (dateStr != null) {
                              try {
                                final parts = dateStr.split('/');
                                if (parts.length == 3) {
                                  vaccineDate = DateTime(
                                    int.parse(parts[2]),
                                    int.parse(parts[1]),
                                    int.parse(parts[0]),
                                  );
                                }
                              } catch (_) {}
                            }

                            // 24-hour rule logic
                            // "if daye is gone 24 hous then they green mode hole and if not then timline white"
                            // Interpreted as:
                            // Age of record > 24 hours -> Green (Completed/History)
                            // Age of record <= 24 hours -> White (Fresh/Recent)
                            final timeDiff = DateTime.now().difference(
                              vaccineDate,
                            );
                            final isOld = timeDiff.inHours > 24;

                            return TimelineTile(
                              isFirst: isFirst,
                              isLast: isLast,
                              alignment: TimelineAlign.manual,
                              lineXY: 0.05,
                              beforeLineStyle: LineStyle(
                                color: AppColors.primary.withOpacity(0.5),
                                thickness: 3,
                              ),
                              afterLineStyle: LineStyle(
                                color: AppColors.primary.withOpacity(0.5),
                                thickness: 3,
                              ),
                              indicatorStyle: IndicatorStyle(
                                width: 22,
                                height: 22,
                                indicator: Container(
                                  decoration: BoxDecoration(
                                    color: isOld
                                        ? AppColors.primary
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.2,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              endChild: Container(
                                margin: const EdgeInsets.only(
                                  left: 20,
                                  bottom: 24,
                                ),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF1E2623,
                                      ).withOpacity(0.06),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1E2623),
                                          ),
                                        ),
                                        if (!isOld)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "New",
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.inputFill,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.calendar_month_rounded,
                                            size: 14,
                                            color: AppColors.textLightGray,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          DateFormat(
                                            'MMMM d, yyyy',
                                          ).format(vaccineDate),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textLightGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (log.details.containsKey('notes') &&
                                        log.details['notes']
                                            .toString()
                                            .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 12.0,
                                        ),
                                        child: Text(
                                          log.details['notes'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: const Color(0xFF5A5A5A),
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
