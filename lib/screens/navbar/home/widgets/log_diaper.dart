import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../../utils/app_colors.dart';
import '../../../../services/database_service.dart';
import '../../../../models/activity_log_model.dart';
import '../../../../models/user_model.dart';

class LogDiaperScreen extends StatefulWidget {
  const LogDiaperScreen({super.key});

  @override
  State<LogDiaperScreen> createState() => _LogDiaperScreenState();
}

class _LogDiaperScreenState extends State<LogDiaperScreen> {
  // 0: Wet, 1: Dirty, 2: Mixed
  // Defaulting to 1 (Dirty) to match previous flow
  int _selectedType = 1;

  // Stool Color Selection (Null if none selected)
  int? _selectedColorIndex;

  // Image Picker State
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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

  bool _isSaving = false;

  Future<void> _saveLog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
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
        type: 'diaper',
        subType: _selectedType == 0
            ? 'wet'
            : (_selectedType == 1 ? 'dirty' : 'mixed'),
        timestamp: timestamp,
        createdAt: DateTime.now(),
        details: {
          'stoolColorIndex': _selectedColorIndex,
          'imagePath': _selectedImage?.path, // Saving local path for now
        },
      );

      await DatabaseService().addActivityLog(user.uid, babyId, log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Diaper change logged successfully!",
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
        Navigator.pop(context); // Pop back to home after saving
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

  // Color Definitions for Stool
  final List<Color> _stoolColors = [
    const Color(0xFFFDD835), // Mustard/Yellow
    const Color(0xFFA5D6A7), // Greenish
    const Color(0xFF795548), // Brown
    const Color(0xFF212121), // Black/Dark
    const Color(0xFFE57373), // Red
    const Color(0xFFF5F5F5), // White/Chalky
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: Text(
          "Log Diaper",
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
            // --- Date Picker ---
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
            const SizedBox(height: 20),
            const SizedBox(height: 5),

            // --- 1. Type Selector (Wet, Dirty, Mixed) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTypeCard(
                  0,
                  "Wet",
                  Icons.water_drop,
                  const Color(0xFFFFD54F),
                ),
                const SizedBox(width: 12),
                _buildTypeCard(
                  1,
                  "Dirty",
                  Icons.grass,
                  const Color(0xFF8D6E63),
                ),
                const SizedBox(width: 12),
                _buildTypeCard(
                  2,
                  "Mixed",
                  Icons.layers,
                  const Color(0xFFEF9A9A),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- 2. Stool Color (Always Visible & Selectable) ---
            Column(
              children: [
                Text(
                  "Stool Color",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E2623),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: List.generate(_stoolColors.length, (index) {
                    return _buildColorCircle(index);
                  }),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // --- 3. Add Photo ---
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: const Color(0xFF1E2623),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Add Photo",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E2623),
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 60),

            // --- 4. Save Button ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 5,
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper: Top Type Cards
  Widget _buildTypeCard(
    int index,
    String label,
    IconData icon,
    Color activeColor,
  ) {
    final bool isSelected = _selectedType == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: activeColor.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              index == 2
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 24,
                          color: const Color(0xFFFFD54F),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.grass,
                          size: 24,
                          color: const Color(0xFF8D6E63),
                        ),
                      ],
                    )
                  : Icon(icon, size: 32, color: activeColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFF1E2623),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Circular Color Selector
  Widget _buildColorCircle(int index) {
    final bool isSelected = _selectedColorIndex == index;
    final Color color = _stoolColors[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColorIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: isSelected
            ? Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              )
            : null,
      ),
    );
  }
}
