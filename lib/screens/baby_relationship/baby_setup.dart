import 'dart:io'; // Import for File handling
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import '../../utils/app_colors.dart';

class BabySetupScreen extends StatefulWidget {
  const BabySetupScreen({super.key});

  @override
  State<BabySetupScreen> createState() => _BabySetupScreenState();
}

class _BabySetupScreenState extends State<BabySetupScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Gender selection state: 'Boy', 'Girl', 'Optional', or null
  String? _selectedGender;

  // Image Picker state
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Function to Pick Image from Gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Function to show Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Simple date formatting
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
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
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
        // Removed the title as requested
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Main Title ---
                Text(
                  "Baby Setup",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: const Color(0xFF1E2623),
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 30),

                // --- Photo Upload Circle ---
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF5F5F0), // Light beige/cream
                        border: Border.all(
                          color: AppColors.primary, // Green border
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        // Show selected image if available
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      // Hide the icon/text if an image is selected
                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 32,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Upload Photo",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF1E2623),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // --- Baby Name Field ---
                _buildLabel("Baby Name"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(hint: "Baby Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter baby\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- Date of Birth Field ---
                _buildLabel("Date of Birth"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dobController,
                  readOnly: true, // Prevent manual typing
                  onTap: () => _selectDate(context),
                  decoration: _inputDecoration(
                    hint: "Date of Birth",
                    suffixIcon: Icons.calendar_today_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- Gender Selection ---
                _buildLabel("Gender"),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F0), // Background for the toggle
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildGenderButton("Boy")),
                      Expanded(child: _buildGenderButton("Girl")),
                      Expanded(child: _buildGenderButton("Optional")),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // --- Submit Button ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Save Data (In a real app, save to backend/storage here)

                        // Navigate to Home Screen using the named route or direct push
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) =>
                              false, // Removes all previous routes from stack (cant go back to setup)
                        );
                      }
                    },
                    child: const Text("All Set!"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for input labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1E2623),
      ),
    );
  }

  // Helper for Gender Buttons
  Widget _buildGenderButton(String gender) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          gender,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14, // Slightly smaller to fit 3 items
            fontWeight: FontWeight.w500,
            color: isSelected
                ? const Color(0xFF1E2623)
                : AppColors.textLightGray,
          ),
        ),
      ),
    );
  }

  // Custom Input Decoration
  InputDecoration _inputDecoration({
    required String hint,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F0), // Matches the light background
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: AppColors.primary)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30), // Pill shape
        borderSide: BorderSide(
          color: AppColors.primary.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: AppColors.primary.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
    );
  }
}
