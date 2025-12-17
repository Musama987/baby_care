import 'package:baby_care/services/auth_service.dart';
import 'package:baby_care/services/database_service.dart';
import 'package:baby_care/screens/auth/login/forgetpassword.dart';
import 'package:baby_care/screens/auth/signup/signup.dart';
import 'package:baby_care/screens/baby_relationship/realtionship.dart';
import 'package:baby_care/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      // resizeToAvoidBottomInset ensures the screen moves up when keyboard opens
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Physics ensures it only scrolls if content is larger than screen (e.g., keyboard open)
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Spacer pushes content to center
                          const Spacer(),

                          // --- Logo ---
                          Icon(
                            Icons.eco_rounded,
                            size: 64,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),

                          // --- Title ---
                          Text(
                            "Welcome Back",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E2623),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please login to continue",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // --- Inputs ---
                          _buildTextField(
                            controller: _emailController,
                            hint: 'Email',
                            icon: Icons.email_outlined,
                            inputType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            isPasswordVisible: _isPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // --- Forgot Password (Aligned Right) ---
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Forgot Password?",
                                style: GoogleFonts.dmSans(
                                  color: const Color(0xFFBCAAA4),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --- Login Button ---
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        // Call AuthService
                                        final user = await AuthService().signIn(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text
                                              .trim(),
                                          context: context,
                                        );

                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });

                                          if (user != null) {
                                            // Check User Setup Status
                                            final dbService = DatabaseService();
                                            final userDoc = await dbService
                                                .getUser(user.user!.uid);

                                            if (mounted) {
                                              if (userDoc != null &&
                                                  userDoc.role != null &&
                                                  userDoc.role!.isNotEmpty &&
                                                  userDoc.currentBabyId !=
                                                      null &&
                                                  userDoc
                                                      .currentBabyId!
                                                      .isNotEmpty) {
                                                // User has completed setup -> Go to Home
                                                Navigator.pushNamedAndRemoveUntil(
                                                  context,
                                                  '/home',
                                                  (route) => false,
                                                );
                                              } else {
                                                // Setup not complete -> Go to Relationship
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const RelationshipScreen(),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Log In",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- Social Buttons ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialButton(
                                icon: Icons.g_mobiledata,
                                onTap: () async {
                                  setState(() => _isLoading = true);
                                  // Call AuthService for Google Sign In
                                  final user = await AuthService()
                                      .signInWithGoogle(context);
                                  setState(() => _isLoading = false);

                                  if (user != null && mounted) {
                                    // Check User Setup Status
                                    final dbService = DatabaseService();
                                    final userDoc = await dbService.getUser(
                                      user.user!.uid,
                                    );

                                    if (mounted) {
                                      if (userDoc != null &&
                                          userDoc.role != null &&
                                          userDoc.role!.isNotEmpty &&
                                          userDoc.currentBabyId != null &&
                                          userDoc.currentBabyId!.isNotEmpty) {
                                        // User has completed setup -> Go to Home
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/home',
                                          (route) => false,
                                        );
                                      } else {
                                        // Setup not complete -> Go to Relationship
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RelationshipScreen(),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                              const SizedBox(width: 20),
                              _buildSocialButton(
                                icon: Icons.apple,
                                onTap: () {},
                              ),
                            ],
                          ),

                          // Spacer pushes bottom text to the very bottom
                          const Spacer(),

                          // --- Navigation to Sign Up ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: GoogleFonts.dmSans(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Sign Up",
                                    style: GoogleFonts.dmSans(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper widget for nicer TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: inputType,
      validator: validator,
      style: GoogleFonts.dmSans(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
        filled: true,
        fillColor: const Color(0xFFF5F5F5), // Light grey fill
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  // FIX: Matched color with other text field elements
                  color: Colors.grey.shade400,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 70,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 28),
      ),
    );
  }
}
