import 'package:flutter/material.dart';
import 'package:baby_care/utils/app_colors.dart';
import 'package:baby_care/utils/app_themes.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class Medication extends StatefulWidget {
  const Medication({Key? key}) : super(key: key);

  @override
  State<Medication> createState() => _MedicationState();
}

class _MedicationState extends State<Medication> {
  // Dummy data for visualization - replace with your database data later
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Vitamin D',
      'dose': '2 Drops',
      'time': '09:00 AM',
      'type': 'Supplement',
      'isTaken': true,
    },
    {
      'name': 'Amoxicillin',
      'dose': '5ml',
      'time': '02:00 PM',
      'type': 'Antibiotic',
      'isTaken': false,
    },
    {
      'name': 'Paracetamol',
      'dose': '2.5ml',
      'time': '08:00 PM',
      'type': 'Fever',
      'isTaken': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Access current theme data
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
        actions: [
          IconButton(
            onPressed: () {
              _showAddMedicationDialog(context);
            },
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Icon(Icons.add, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Schedule",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "3 doses remaining",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Upcoming Doses",
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Medication List
            Expanded(
              child: ListView.separated(
                itemCount: _medications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final med = _medications[index];
                  return _buildMedicationCard(med, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> med, ThemeData theme) {
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
          // Icon Box
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/feed.png', // Ensure this asset exists
                height: 24,
                color: AppColors.primary,
                errorBuilder: (c, o, s) =>
                    Icon(Icons.medication, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med['name'],
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "${med['dose']} • ${med['type']}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Time & Checkbox
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
                  med['time'],
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Custom Checkbox
              InkWell(
                onTap: () {
                  setState(() {
                    med['isTaken'] = !med['isTaken'];
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: med['isTaken']
                        ? AppColors.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: med['isTaken']
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: med['isTaken']
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

  void _showAddMedicationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final TextEditingController dateController = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height:
                MediaQuery.of(context).size.height *
                0.85, // Increased height for better view
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            padding: const EdgeInsets.all(20),
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
                TextField(
                  decoration: InputDecoration(
                    labelText: "Medicine Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.medication_liquid),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Dosage (e.g., 5ml)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.scale),
                  ),
                ),
                const SizedBox(height: 15),
                // Date & Time Picker Field
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Date & Time",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
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

                    if (pickedDate != null) {
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
                          selectedDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          dateController.text = DateFormat(
                            'yyyy-MM-dd hh:mm a',
                          ).format(selectedDate!);
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Save logic here using dateController.text and other fields
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save Medication",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
