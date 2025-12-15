import 'dart:io';
import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedCategory;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    "Tips & Tricks",
    "Gear Talk",
    "Health Q&A",
    "Milestones",
    "General Chat",
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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // Light cream background
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Title ---
              Text(
                "Create Post",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2623),
                ),
              ),
              const SizedBox(height: 24),

              // --- Text Input Area ---
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F7), // Very subtle off-white
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 6,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF1E2623),
                  ),
                  decoration: InputDecoration(
                    hintText: "Share your thoughts...",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Add Photo Section ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _selectedImage == null
                        ? AppColors.primary.withOpacity(
                            0.8,
                          ) // Green from your design
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      if (_selectedImage == null)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Add Photo",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : Container(
                          // Edit icon overlay if image is selected
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.all(10),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: Icon(
                              Icons.edit,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Select Category Dropdown ---
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFF9F9F7),
              //     borderRadius: BorderRadius.circular(16),
              //     border: Border.all(color: const Color(0xFFE0E0E0)),
              //   ),
              //   child: DropdownButtonHideUnderline(
              //     child: DropdownButton<String>(
              //       value: _selectedCategory,
              //       hint: Text(
              //         "Select Category",
              //         style: GoogleFonts.poppins(
              //           color: const Color(0xFF1E2623),
              //           fontSize: 16,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //       icon: const Icon(
              //         Icons.keyboard_arrow_down_rounded,
              //         color: Color(0xFF1E2623),
              //       ),
              //       isExpanded: true,
              //       borderRadius: BorderRadius.circular(16),
              //       items: _categories.map((String category) {
              //         return DropdownMenuItem<String>(
              //           value: category,
              //           child: Text(
              //             category,
              //             style: GoogleFonts.poppins(
              //               color: const Color(0xFF1E2623),
              //               fontSize: 15,
              //             ),
              //           ),
              //         );
              //       }).toList(),
              //       onChanged: (newValue) {
              //         setState(() {
              //           _selectedCategory = newValue;
              //         });
              //       },
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 60),
              const SizedBox(height: 10),

              // --- Post Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Post Logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Green
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Post",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
