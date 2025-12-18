import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../../utils/app_colors.dart';
import '../../../../services/database_service.dart';
import '../../../../models/activity_log_model.dart';
import '../../../../models/user_model.dart';

class LogSleepScreen extends StatefulWidget {
  const LogSleepScreen({super.key});

  @override
  State<LogSleepScreen> createState() => _LogSleepScreenState();
}

class _LogSleepScreenState extends State<LogSleepScreen> {
  // Timer Logic
  Timer? _timer;
  Duration _duration = const Duration(seconds: 0);
  bool _isSleeping = false; // Add state tracker

  // Sound Logic
  String? _activeSound; // 'white_noise', 'rain', 'shushing' or null
  // final AudioPlayer _audioPlayer = AudioPlayer(); // Uncomment if you add audioplayers package

  // --- Date State ---
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Save State
  bool _isSaving = false;

  Future<void> _saveLog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
      // Ensure timer is stopped if saving
      if (_isSleeping) {
        _isSleeping = false;
        _timer?.cancel();
      }
    });

    try {
      final userDoc = await DatabaseService().getUser(user.uid);
      if (userDoc?.currentBabyId == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("No baby selected!")));
        }
        setState(() => _isSaving = false);
        return;
      }
      final babyId = userDoc!.currentBabyId!;

      final String logId = const Uuid().v4();
      final now = DateTime.now();
      // Combine selected date with current time for the timestamp
      final timestamp = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );

      final log = ActivityLogModel(
        id: logId,
        type: 'sleep',
        timestamp: timestamp,
        details: {'duration': _duration.inSeconds, 'soundUsed': _activeSound},
      );

      await DatabaseService().addActivityLog(babyId, log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Sleep logged successfully!",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Do NOT pop here as requested
        // Reset timer/sleep state if desired, or keep as is?
        // User said "stop and save", usually implies session end.
        // Let's reset the "isSleeping" state purely (already done in stopAndSave)
        // We might want to reset the duration or keep it visible as "Last saved session".
        // For now, minimal change: just don't pop.
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving log: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _duration = Duration(seconds: _duration.inSeconds + 1);
      });
    });
  }

  void _toggleSleep() {
    setState(() {
      if (_isSleeping) {
        _isSleeping = false;
        _timer?.cancel();
      } else {
        _isSleeping = true;
        _startTimer();
      }
    });
  }

  void _stopAndSave() {
    // 1. Stop timer UI first
    if (_isSleeping) {
      _toggleSleep();
    }
    // 2. Trigger save (which handles loading UI)
    _saveLog();
  }

  // Toggle Sound Logic
  void _toggleSound(String soundName, String assetPath) {
    setState(() {
      if (_activeSound == soundName) {
        // Stop if already playing
        _activeSound = null;
        // await _audioPlayer.stop();
      } else {
        // Play new sound
        _activeSound = soundName;
        // await _audioPlayer.play(AssetSource(assetPath));
        // Note: Ensure you add 'audioplayers' to pubspec.yaml to use actual audio
      }
    });
  }

  // Format Duration to HH:MM:SS
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String hours = twoDigits(d.inHours);
    final String minutes = twoDigits(d.inMinutes.remainder(60));
    final String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
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
        title: const Text("Log Sleep"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // --- Date Picker ---
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E2623),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // --- Gradient Timer Circle ---
            Container(
              width: 220, // Reduced size further
              height: 220, // Reduced size further
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF8FB89A), // AppColors.primary (Green)
                    Color(0xFFFFCCBC), // Soft Peach/Orange (Matches Image)
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: 5,
                  ),
                  // Inner highlight effect simulation
                  const BoxShadow(
                    color: Colors.white24,
                    blurRadius: 20,
                    offset: Offset(-10, -10),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(20), // Rim thickness
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15), // Glassmorphism effect
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _formatDuration(_duration),
                    style: GoogleFonts.poppins(
                      fontSize: 32, // Reduced font size further
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E2623), // Dark text for contrast
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // --- Start/Stop Sleep Button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  if (_isSleeping) {
                    _stopAndSave();
                  } else {
                    _toggleSleep();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSleeping
                      ? const Color(0xFFE57373) // Red for Stop
                      : AppColors.primary, // Green for Start
                  foregroundColor: Colors.white,
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ), // Reduced height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  shadowColor:
                      (_isSleeping
                              ? const Color(0xFFE57373)
                              : AppColors.primary)
                          .withOpacity(0.4),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isSleeping ? "Stop & Save" : "Start Sleep",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24), // Reduced from 30
            // --- Sound Controls ---
            Text(
              "Sleep Sounds",
              style: GoogleFonts.poppins(
                fontSize: 14, // Reduced from 16
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E2623),
              ),
            ),
            const SizedBox(height: 12), // Reduced from 16
            // Sound Buttons Row (Wrap to avoid cutting, centered)
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildSoundButton("White Noise", "white_noise"),
                  _buildSoundButton("Rain", "rain"),
                  _buildSoundButton("Shushing", "shushing"),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundButton(String label, String id) {
    bool isActive = _activeSound == id;

    return GestureDetector(
      onTap: () => _toggleSound(id, "sounds/$id.mp3"),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : const Color(0xFF1E2623),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF1E2623),
            ),
          ],
        ),
      ),
    );
  }
}
