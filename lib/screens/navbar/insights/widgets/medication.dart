import 'package:flutter/material.dart';
import 'package:baby_care/utils/app_colors.dart';
import 'package:baby_care/utils/app_themes.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../services/database_service.dart';
import '../../../../models/activity_log_model.dart';
import '../../../../models/user_model.dart';

class Medication extends StatefulWidget {
  const Medication({Key? key}) : super(key: key);

  @override
  State<Medication> createState() => _MedicationState();
}

class _MedicationState extends State<Medication> {
  Stream<List<ActivityLogModel>>? _medicationStream;

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
          _medicationStream = DatabaseService().getLogsStream(
            uid: user.uid,
            babyId: userDoc!.currentBabyId!,
            type: 'medication',
          );
        });
      }
    }
  }

  Future<void> _toggleTaken(ActivityLogModel log) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await DatabaseService().getUser(user.uid);
    if (userDoc?.currentBabyId == null) return;
    final babyId = userDoc!.currentBabyId!;

    // Toggle status
    final currentStatus = log.details['isTaken'] ?? false;
    final newStatus = !currentStatus;

    // Create updated log
    final updatedDetails = Map<String, dynamic>.from(log.details);
    updatedDetails['isTaken'] = newStatus;

    final updatedLog = ActivityLogModel(
      id: log.id,
      type: log.type,
      subType: log.subType,
      timestamp: log.timestamp,
      createdAt: log.createdAt, // Keep original creation time
      details: updatedDetails,
    );

    // Update in DB (addActivityLog overwrites if ID exists)
    await DatabaseService().addActivityLog(user.uid, babyId, updatedLog);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Medications",
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [const SizedBox(width: 10)],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: _medicationStream == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<ActivityLogModel>>(
                stream: _medicationStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allLogs = snapshot.data ?? [];

                  // Sort by time Ascending (Past -> Future)
                  allLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medication List
                      Expanded(
                        child: allLogs.isEmpty
                            ? Center(
                                child: Text(
                                  "No medications recorded",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                itemCount: allLogs.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 15),
                                itemBuilder: (context, index) {
                                  final log = allLogs[index];
                                  return _buildMedicationCard(log, theme);
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildMedicationCard(ActivityLogModel log, ThemeData theme) {
    final name = log.details['name'] ?? 'Medication';
    final dose = log.details['dosage'] ?? '';
    final type = log.details['type'] ?? 'Medicine';
    final time =
        log.details['time'] ?? DateFormat('hh:mm a').format(log.timestamp);
    final isTaken = log.details['isTaken'] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(Icons.medication, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "$dose • $type • ${DateFormat('MMM dd, yyyy').format(log.timestamp)}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _toggleTaken(log),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isTaken ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isTaken ? AppColors.primary : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isTaken
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddMedicationSheet extends StatefulWidget {
  const AddMedicationSheet({super.key});

  @override
  State<AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<AddMedicationSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _typeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select date & time',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userDoc = await DatabaseService().getUser(user.uid);
      if (userDoc == null || userDoc.currentBabyId == null) {
        throw Exception("No baby selected. Please select a baby first.");
      }
      final babyId = userDoc.currentBabyId!;

      final String logId = const Uuid().v4();

      final log = ActivityLogModel(
        id: logId,
        type: 'medication',
        timestamp: _selectedDate!,
        createdAt: DateTime.now(),
        details: {
          'name': _nameController.text.trim(),
          'dosage': _doseController.text.trim(),
          'type': _typeController.text.trim().isEmpty
              ? 'Medicine'
              : _typeController.text.trim(),
          'isTaken': false,
          'time': DateFormat('hh:mm a').format(_selectedDate!),
        },
      );

      print("Saving Medication Log: ${log.toMap()}");

      await DatabaseService().addActivityLog(user.uid, babyId, log);

      print("Medication Saved Successfully");

      if (mounted) {
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Medication added successfully',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print("Error saving medication: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving medication: $e',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickDateTime() async {
    final theme = Theme.of(context);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: AppColors.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateController.text = DateFormat(
            'yyyy-MM-dd hh:mm a',
          ).format(_selectedDate!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Add Medication", style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Medicine Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.medication_liquid),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _doseController,
              decoration: InputDecoration(
                labelText: "Dosage (e.g., 5ml, 1 pill)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.scale),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter dosage' : null,
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: "Type (e.g., Antibiotic, Vitamin)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date & Time",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveMedication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Save Medication",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
