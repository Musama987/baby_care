import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AddVaccineRecord extends StatefulWidget {
  const AddVaccineRecord({super.key});

  @override
  State<AddVaccineRecord> createState() => _AddVaccineRecordState();
}

class _AddVaccineRecordState extends State<AddVaccineRecord> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _nextDueDateController = TextEditingController();

  DateTime? _selectedDate;
  DateTime? _selectedNextDueDate;

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _dateController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    _nextDueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isNextDue) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isNextDue) {
          _selectedNextDueDate = picked;
          _nextDueDateController.text = DateFormat(
            'MMM dd, yyyy',
          ).format(picked);
        } else {
          _selectedDate = picked;
          _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
        }
      });
    }
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      // Create a map or object here to pass back or save to database
      final newRecord = {
        'vaccineName': _vaccineNameController.text,
        'date': _selectedDate,
        'doctor': _doctorController.text,
        'notes': _notesController.text,
        'nextDueDate': _selectedNextDueDate,
      };

      // TODO: Call your database service here to save 'newRecord'

      Navigator.pop(context, newRecord); // Return data to previous screen

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vaccine record added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Add Vaccine Record",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Vaccine Name"),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _vaccineNameController,
                  hint: "e.g. Polio, BCG, Hepatitis B",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter vaccine name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),
                _buildLabel("Date Administered"),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _selectDate(context, false),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _dateController,
                      hint: "Select Date",
                      suffixIcon: Icons.calendar_today_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                _buildLabel("Doctor / Clinic"),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _doctorController,
                  hint: "e.g. Dr. Smith / City Hospital",
                  icon: Icons.local_hospital_rounded,
                ),

                const SizedBox(height: 14),
                _buildLabel("Next Due Date (Optional)"),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _selectDate(context, true),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _nextDueDateController,
                      hint: "Select Next Due Date",
                      suffixIcon: Icons.event_repeat_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                _buildLabel("Notes"),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _notesController,
                  hint: "Any side effects or additional info...",
                  maxLines: 4,
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      "Save Record",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    IconData? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.primary)
              : null,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: AppColors.primary)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
