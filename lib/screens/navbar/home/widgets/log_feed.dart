import 'dart:async';
import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../../services/database_service.dart';
import '../../../../models/activity_log_model.dart';
import '../../../../models/user_model.dart';

class LogFeedScreen extends StatefulWidget {
  const LogFeedScreen({super.key});

  @override
  State<LogFeedScreen> createState() => _LogFeedScreenState();
}

class _LogFeedScreenState extends State<LogFeedScreen> {
  int _selectedTab = 1; // 0: Nursing, 1: Bottle (Default), 2: Solids

  // --- Bottle State ---
  double _bottleAmount = 4.5;
  String _selectedMood = 'Happy';

  // --- Nursing State ---
  final Stopwatch _leftStopwatch = Stopwatch();
  final Stopwatch _rightStopwatch = Stopwatch();
  Timer? _timer;

  // --- Solids State ---
  final TextEditingController _foodController = TextEditingController();
  int _solidsAmount = 50; // grams

  // --- Date State ---
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

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

  bool _isSaving = false;

  Future<void> _saveLog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
      // Stop timers if running
      _timer?.cancel();
      if (_leftStopwatch.isRunning) _leftStopwatch.stop();
      if (_rightStopwatch.isRunning) _rightStopwatch.stop();
    });

    try {
      // Get current baby ID from User Profile
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

      // Construct common data
      final String logId = const Uuid().v4();
      final now = DateTime.now();
      final timestamp = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );

      ActivityLogModel? log;

      if (_selectedTab == 0) {
        // Nursing
        log = ActivityLogModel(
          id: logId,
          type: 'feed',
          subType: 'nursing',
          timestamp: timestamp,
          details: {
            'leftDuration': _leftStopwatch.elapsed.inSeconds,
            'rightDuration': _rightStopwatch.elapsed.inSeconds,
            'totalDuration':
                _leftStopwatch.elapsed.inSeconds +
                _rightStopwatch.elapsed.inSeconds,
            'side': _leftStopwatch.elapsed > _rightStopwatch.elapsed
                ? 'Left'
                : 'Right', // Dominant side
          },
        );
      } else if (_selectedTab == 1) {
        // Bottle
        log = ActivityLogModel(
          id: logId,
          type: 'feed',
          subType: 'bottle',
          timestamp: timestamp,
          details: {
            'amount': _bottleAmount,
            'unit': 'oz',
            'mood': _selectedMood,
          },
        );
      } else {
        // Solids
        log = ActivityLogModel(
          id: logId,
          type: 'feed',
          subType: 'solids',
          timestamp: timestamp,
          details: {
            'food': _foodController.text,
            'amount': _solidsAmount,
            'unit': 'g',
          },
        );
      }

      await DatabaseService().addActivityLog(babyId, log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Feed logged successfully!",
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
        // Do NOT pop here
      }
    } catch (e) {
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
  void dispose() {
    _timer?.cancel();
    _foodController.dispose();
    super.dispose();
  }

  // --- Timer Logic for Nursing ---
  void _startTimer() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) setState(() {});
      });
    }
  }

  void _toggleNursingTimer(bool isLeft) {
    _startTimer();
    setState(() {
      if (isLeft) {
        if (_leftStopwatch.isRunning) {
          _leftStopwatch.stop();
        } else {
          _leftStopwatch.start();
          // Automatically stop the other side if one starts?
          // Usually breastfeeding tracking allows one side active at a time.
          if (_rightStopwatch.isRunning) _rightStopwatch.stop();
        }
      } else {
        if (_rightStopwatch.isRunning) {
          _rightStopwatch.stop();
        } else {
          _rightStopwatch.start();
          if (_leftStopwatch.isRunning) _leftStopwatch.stop();
        }
      }
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: Text(
          "Log Feed",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20), // Added space from top
            // --- Custom Segmented Control ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F2), // Light background
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _buildTabItem(0, "Nursing"),
                  _buildTabItem(1, "Bottle"),
                  _buildTabItem(2, "Solids"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Date Picker ---
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E2623),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 40),

            // --- Content Views ---
            _buildCurrentView(),

            const SizedBox(height: 40),

            // --- Save Button ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
                        "Save Log",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(
              height: 40,
            ), // Added space from bottom for easier viewing
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedTab) {
      case 0:
        return _buildNursingView();
      case 2:
        return _buildSolidsView();
      case 1:
      default:
        return _buildBottleView();
    }
  }

  // ---------------------------------------------------------------------------
  // NURSING VIEW
  // ---------------------------------------------------------------------------
  Widget _buildNursingView() {
    return Column(
      key: const ValueKey("Nursing"),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimerButton(
              label: "Left",
              stopwatch: _leftStopwatch,
              onTap: () => _toggleNursingTimer(true),
            ),
            _buildTimerButton(
              label: "Right",
              stopwatch: _rightStopwatch,
              onTap: () => _toggleNursingTimer(false),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          "Total Time",
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 5),
        Text(
          _formatDuration(_leftStopwatch.elapsed + _rightStopwatch.elapsed),
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerButton({
    required String label,
    required Stopwatch stopwatch,
    required VoidCallback onTap,
  }) {
    bool isRunning = stopwatch.isRunning;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 2),
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: isRunning ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isRunning ? AppColors.primary : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isRunning
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 40,
                  color: isRunning ? Colors.white : AppColors.primary,
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isRunning ? Colors.white : const Color(0xFF1E2623),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          _formatDuration(stopwatch.elapsed),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E2623),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTLE VIEW
  // ---------------------------------------------------------------------------
  Widget _buildBottleView() {
    return Column(
      key: const ValueKey("Bottle"),
      children: [
        // Quantity Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQtyBtn(
              icon: Icons.remove,
              onTap: () {
                setState(() {
                  if (_bottleAmount > 0.5) _bottleAmount -= 0.5;
                });
              },
            ),
            Container(
              width: 150,
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _bottleAmount.toString().replaceAll(
                        RegExp(r"([.]*0)(?!.*\d)"),
                        "",
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E2623),
                      ),
                    ),
                    TextSpan(
                      text: " oz",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildQtyBtn(
              icon: Icons.add,
              onTap: () {
                setState(() {
                  _bottleAmount += 0.5;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Baby Mood Selector
        Text(
          "Baby Mood",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E2623),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMoodItem("Happy", Icons.wb_sunny_rounded),
            const SizedBox(width: 20),
            _buildMoodItem(
              "Fussy",
              Icons.cloud_off_rounded,
            ), // Using cloud as fussy placeholder
            const SizedBox(width: 20),
            _buildMoodItem("Sleepy", Icons.nightlight_round),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SOLIDS VIEW
  // ---------------------------------------------------------------------------
  Widget _buildSolidsView() {
    return Column(
      key: const ValueKey("Solids"),
      children: [
        // Food Type Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _foodController,
            style: GoogleFonts.poppins(fontSize: 16),
            decoration: InputDecoration(
              hintText: "Food Type (e.g. Cereal, Peas)",
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              prefixIcon: Icon(
                Icons.restaurant_rounded,
                color: AppColors.primary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Quantity Selector (Grams)
        Text(
          "Quantity",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E2623),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQtyBtn(
              icon: Icons.remove,
              onTap: () {
                setState(() {
                  if (_solidsAmount > 10) _solidsAmount -= 10;
                });
              },
            ),
            Container(
              width: 150,
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$_solidsAmount",
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E2623),
                      ),
                    ),
                    TextSpan(
                      text: " g",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildQtyBtn(
              icon: Icons.add,
              onTap: () {
                setState(() {
                  _solidsAmount += 10;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  // --- Helpers ---

  Widget _buildTabItem(int index, String label) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 2),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQtyBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildMoodItem(String label, IconData icon) {
    bool isSelected = _selectedMood == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = label;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 2),
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : const Color(0xFFF1F5F2),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.accentYellow : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              size: 32,
              // Color logic: if selected, use 'original' color look, else grey
              color: isSelected
                  ? (label == "Happy"
                        ? Colors.orange
                        : (label == "Fussy" ? Colors.grey : Colors.blue))
                  : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF1E2623)
                  : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
