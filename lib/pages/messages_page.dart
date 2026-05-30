import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Message Container
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top Report Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 2.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.08),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sender details
                      Text(
                        'From: Ma\'am Ana',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Name: Kai Adamson',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Document Title
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Reading Review',
                              style: GoogleFonts.quicksand(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'The Two Best Friends',
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF4A68FF), // Blue book title
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Text analysis block
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black54, width: 1.5),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.quicksand(
                              fontSize: 13.5,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              letterSpacing: 0.5,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Once there were two friends a ',
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'squirrel ',
                                style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'and a puppy. They ',
                              ),
                              TextSpan(
                                text: 'used ',
                                style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'to ',
                              ),
                              TextSpan(
                                text: 'live ',
                                style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'and play together. The squirrel was very sporty and always won the game. The puppy used to feel bad and ',
                              ),
                              TextSpan(
                                text: 'thought ',
                                style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'that it was of no use.\n\nOne day, it started raining ',
                              ),
                              TextSpan(
                                text: 'heavily. ',
                                style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'The squirrel was in ',
                              ),
                              TextSpan(
                                text: 'high ',
                                style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'spirits. He started doing ',
                              ),
                              TextSpan(
                                text: 'antics ',
                                style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'but ',
                              ),
                              TextSpan(
                                text: 'suddenly, ',
                                style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'lost ',
                                style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'his balance and fell in the rain water.\n\n',
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'He ',
                              ),
                              TextSpan(
                                text: 'called ',
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'his friend, the puppy for help. The puppy ',
                              ),
                              TextSpan(
                                text: 'came ',
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'to his rescue. The squirrel climbed on its back and ',
                              ),
                              TextSpan(
                                text: 'reached ',
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'a safe place. He thanked his friend for saving his life.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Teacher Report Section
                      Text(
                        'Teacher Report',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Metrics Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricBox(
                              title: 'JUMPED\nWORDS',
                              value: '2',
                              color: const Color(0xFF00C853),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricBox(
                              title: 'REPETITION',
                              value: '3',
                              color: const Color(0xFFFF6D00),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricBox(
                              title: 'SELF\nCORRECTION',
                              value: '4',
                              color: const Color(0xFF00BFA5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricBox(
                              title: 'MIS-\nPRONUNCIATION',
                              value: '5',
                              color: const Color(0xFFFFD600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Teacher Feedback Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 2.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.08),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Teacher Feedback',
                          style: GoogleFonts.quicksand(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Great job Kai, You read with expression and understand the story well. Try to slow down a little and pronounce "squirrel" and "together" more clearly. Practice more words that you are not familiar.',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '- Keep reading and keep blooming!',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
