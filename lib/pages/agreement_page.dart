import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_mobile/pages/home_page.dart';
import 'package:student_mobile/pages/login_page.dart';
import 'package:student_mobile/services/auth_repository.dart';
import 'package:student_mobile/services/student_repository.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  final AuthRepository _authRepository = AuthRepository();
  final StudentRepository _studentRepository = StudentRepository();
  bool _isSaving = false;

  Future<void> _acceptAgreement() async {
    setState(() => _isSaving = true);

    try {
      await _studentRepository.acceptPrivacyAgreement();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save agreement: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Shield Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shield,
                        size: 110,
                        color: Color(0xFF67B56B), // Custom green shield color
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 32,
                          color: Color(0xFF3276B8), // Custom blue check color
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'Safety & Privacy\nAgreement',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.3,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Intro Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'To help our teachers monitor progress and pronunciation, ReadBloom uses the camera and microphone during learning sessions.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromRGBO(0, 0, 0, 0.75),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Feature Info Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.55),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Item 1: Engagement Monitoring
                        _buildFeatureRow(
                          icon: Icons.videocam_rounded,
                          iconColor: const Color(0xFF4270F7),
                          title: 'Engagement Monitoring: ',
                          description:
                              'The camera helps teachers see if students are focused during reading activities.',
                        ),
                        const SizedBox(height: 24),
                        // Item 2: Oral Reading
                        _buildFeatureRow(
                          icon: Icons.mic_rounded,
                          iconColor: const Color(0xFFE91E2D),
                          title: 'Oral Reading: ',
                          description:
                              'The microphone is used to assess pronunciation and reading speed during assessments.',
                        ),
                        const SizedBox(height: 24),
                        // Item 3: Secure Storage
                        _buildFeatureRow(
                          icon: Icons.lock_rounded,
                          iconColor: const Color(0xFF00C853),
                          title: 'Secure Storage: ',
                          description:
                              'Recordings are processed privately and are only viewable by assigned teachers for academic support.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Action Buttons
                  Row(
                    children: [
                      // Agree Button
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(0, 0, 0, 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _acceptAgreement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF00E676,
                              ), // Bright green
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "I Agree, Let's Bloom!",
                                    style: GoogleFonts.quicksand(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Reject Button
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(0, 0, 0, 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: Text(
                                      'Are you sure?',
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      'ReadBloom needs camera and microphone permissions to assess your learning progress.',
                                      style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await _authRepository.signOut();
                                          if (!context.mounted) return;
                                          Navigator.pop(dialogContext);
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginPage(),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                        child: Text(
                                          'Yes, Go Back',
                                          style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFCFD8DC,
                              ), // Light grey
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            child: Text(
                              'No thanks, Keep off',
                              style: GoogleFonts.quicksand(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Footer Text
                  Text(
                    'PARENTAL CONSENT REQUIRED',
                    style: GoogleFonts.quicksand(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.quicksand(
                fontSize: 15,
                color: Colors.black87,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
