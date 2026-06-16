import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_mobile/pages/agreement_page.dart';
import 'package:student_mobile/services/auth_repository.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Year level options (Grade 1 – Grade 6 for elementary)
  final List<String> _yearLevels = ['Grade 4', 'Grade 5', 'Grade 6'];
  String? _selectedYearLevel;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  // ---------- helpers ----------

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIconData,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.quicksand(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.black45,
      ),
      prefixIcon: Icon(prefixIconData, color: Colors.black38, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFE6FFD2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  TextStyle _inputTextStyle() => GoogleFonts.quicksand(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 12.0, bottom: 6.0),
    child: Text(
      label,
      style: GoogleFonts.quicksand(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.black,
        letterSpacing: 1.0,
      ),
    ),
  );

  Widget _shadowWrap({required Widget child}) => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: const Color.fromRGBO(0, 0, 0, 0.03),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  Future<void> _signUp() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final section = _sectionController.text.trim();
    final yearLevel = _selectedYearLevel;

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        section.isEmpty ||
        yearLevel == null) {
      _showSnackBar('Complete all signup fields.');
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final hasSession = await _authRepository.signUp(
        fullName: fullName,
        email: email,
        password: password,
        section: section,
        yearLevel: yearLevel,
      );

      if (!mounted) return;

      if (!hasSession) {
        _showSnackBar('Account created. Check your email to confirm login.');
        Navigator.pop(context);
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AgreementPage()),
        (route) => false,
      );
    } catch (error) {
      if (mounted) {
        _showSnackBar('Signup failed: ${error.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF6A3), // Pastel yellow
              Color(0xFFF48FE1), // Pastel pink/magenta
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logo
                  Image.asset(
                    'assets/icons/logo.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    'create account!',
                    style: GoogleFonts.quicksand(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'JOIN THE READING ADVENTURE',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  // ── Full Name ──────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('FULL NAME'),
                      _shadowWrap(
                        child: TextField(
                          controller: _fullNameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          style: _inputTextStyle(),
                          decoration: _inputDecoration(
                            hint: 'Enter your full name',
                            prefixIconData: Icons.person_outline_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Email ──────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('EMAIL'),
                      _shadowWrap(
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: _inputTextStyle(),
                          decoration: _inputDecoration(
                            hint: 'Enter your email',
                            prefixIconData: Icons.mail_outline_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Password ───────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('PASSWORD'),
                      _shadowWrap(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: _inputTextStyle(),
                          decoration: _inputDecoration(
                            hint: 'Create a password',
                            prefixIconData: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.black38,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Confirm Password ───────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('CONFIRM PASSWORD'),
                      _shadowWrap(
                        child: TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          style: _inputTextStyle(),
                          decoration: _inputDecoration(
                            hint: 'Re-enter your password',
                            prefixIconData: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.black38,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Year Level ─────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('YEAR LEVEL'),
                      _shadowWrap(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6FFD2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedYearLevel,
                              hint: Row(
                                children: [
                                  const Icon(
                                    Icons.school_outlined,
                                    color: Colors.black38,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Select your grade level',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.black38,
                              ),
                              dropdownColor: const Color(0xFFF0FFDE),
                              borderRadius: BorderRadius.circular(16),
                              style: _inputTextStyle(),
                              items: _yearLevels
                                  .map(
                                    (level) => DropdownMenuItem(
                                      value: level,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Text(
                                          level,
                                          style: _inputTextStyle(),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedYearLevel = value),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Section ────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('SECTION'),
                      _shadowWrap(
                        child: TextField(
                          controller: _sectionController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          style: _inputTextStyle(),
                          decoration: _inputDecoration(
                            hint: 'Enter your section',
                            prefixIconData: Icons.group_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // ── Sign Up Button ─────────────────────────
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFE68D), // Light gold
                          Color(0xFFFED165), // Amber gold
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFE5B53B),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              'SIGN UP',
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Footer ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Log in',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF3B56FF),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
