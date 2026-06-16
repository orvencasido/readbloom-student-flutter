import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_mobile/models/student_progress.dart';
import 'package:student_mobile/services/student_repository.dart';

class JourneyPage extends StatefulWidget {
  const JourneyPage({super.key});

  @override
  State<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  final StudentRepository _studentRepository = StudentRepository();
  late Future<StudentProgress> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = _studentRepository.fetchCurrentProgress();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentProgress>(
      future: _progressFuture,
      builder: (context, snapshot) {
        final progress =
            snapshot.data ??
            const StudentProgress(userId: '', booksCompleted: 0, daysStreak: 0);

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          width: 24,
                          height: 520,
                          margin: const EdgeInsets.only(top: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8D6E63),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFF5D4037),
                              width: 2.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.15),
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Column(
                            children: [
                              _buildWoodenBoard(
                                iconWidget: _buildClipboardIcon(),
                                title: 'Books Completed',
                                value: '${progress.booksCompleted}',
                              ),
                              const SizedBox(height: 24),
                              _buildWoodenBoard(
                                iconWidget: const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFD54F),
                                  size: 54,
                                ),
                                title: 'Days Streak',
                                value: '${progress.daysStreak} days',
                              ),
                              const SizedBox(height: 24),
                              _buildWoodenBoard(
                                iconWidget: _buildMedalIcon(),
                                title: 'Achievement',
                                value: progress.achievementTitle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Beautiful custom wooden board card
  Widget _buildWoodenBoard({
    required Widget iconWidget,
    required String title,
    required String value,
  }) {
    return Container(
      width: 300,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFA17F4C), // Wooden color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5A442E), // Dark outline
          width: 3.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.16),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon Container Left
          Container(width: 70, alignment: Alignment.center, child: iconWidget),
          const SizedBox(width: 12),
          // Text block Right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 2.0,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.quicksand(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFEB3B), // Yellow statistics color
                    shadows: const [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 3.0,
                        offset: Offset(1.5, 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Beautiful custom built clipboard icon
  Widget _buildClipboardIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Clipboard base
        Container(
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFD7CCC8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black87, width: 2.0),
          ),
          padding: const EdgeInsets.only(top: 14, left: 6, right: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 12, height: 2, color: Colors.black54),
              const SizedBox(height: 4),
              Container(width: 24, height: 2, color: Colors.black54),
              const SizedBox(height: 4),
              Container(width: 18, height: 2, color: Colors.black54),
            ],
          ),
        ),
        // Paper clip holder
        Positioned(
          top: 0,
          child: Container(
            width: 22,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043), // Orange metallic clip
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black87, width: 2.0),
            ),
          ),
        ),
        // Checkmark label
        Positioned(
          top: 14,
          right: 4,
          child: const Icon(
            Icons.check_rounded,
            color: Colors.redAccent,
            size: 14,
          ),
        ),
      ],
    );
  }

  // Beautiful custom built achievement medal icon
  Widget _buildMedalIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ribbons
        Positioned(
          bottom: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: -0.2,
                child: Container(
                  width: 14,
                  height: 28,
                  color: const Color(0xFF00BFA5), // Teal ribbon
                ),
              ),
              const SizedBox(width: 6),
              Transform.rotate(
                angle: 0.2,
                child: Container(
                  width: 14,
                  height: 28,
                  color: const Color(0xFF00BFA5), // Teal ribbon
                ),
              ),
            ],
          ),
        ),
        // Medal base
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFD54F), // Golden medal
            border: Border.all(color: Colors.black87, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.star_rounded, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }
}
