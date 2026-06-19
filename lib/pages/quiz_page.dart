import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_mobile/models/quiz_question.dart';
import 'package:student_mobile/models/reading_book.dart';
import 'package:student_mobile/models/reading_session.dart';
import 'package:student_mobile/pages/home_page.dart';
import 'package:student_mobile/pages/reading_page.dart';
import 'package:student_mobile/services/book_repository.dart';
import 'package:student_mobile/services/student_repository.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.book, required this.session});

  final ReadingBook book;
  final ReadingSession session;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final BookRepository _bookRepository = BookRepository();
  final StudentRepository _studentRepository = StudentRepository();
  late Future<List<QuizQuestion>> _questionsFuture;

  int _currentStep = 0;
  int? _selectedOption;
  int _correctAnswers = 0;
  final List<int> _answers = [];
  bool _isTurningIn = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _bookRepository.fetchQuizQuestions(widget.book.id);
  }

  void _recordCurrentAnswer(QuizQuestion question) {
    final answer = _selectedOption!;
    _answers.add(answer);
    if (answer == question.answerIndex) {
      _correctAnswers += 1;
    }
  }

  void _showCongratulationsDialog(int totalQuestions) {
    final percentage = ((_correctAnswers / totalQuestions) * 100).round();
    final passed = _correctAnswers == totalQuestions;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.black, width: 2.0),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Image.asset(
                'assets/icons/logo.png',
                width: 110,
                height: 110,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                passed ? 'Congratulations Bloomer' : 'Try That Reading Again',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FFD2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00C853), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Score',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_correctAnswers / $totalQuestions',
                      style: GoogleFonts.quicksand(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF00A843),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'CURIOSITY IS THE KEY TO DISCOVERING NEW THINGS.',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDialogButton(
                    label: 'Start Over',
                    color: const Color(0xFF3B82F6),
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      await widget.session.discard();
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReadingPage(book: widget.book),
                        ),
                      );
                    },
                  ),
                  if (passed) ...[
                    const SizedBox(width: 12),
                    _buildDialogButton(
                      label: 'Turn it In',
                      color: const Color(0xFF00C853),
                      onPressed: () async {
                        setState(() => _isTurningIn = true);

                        try {
                          await _studentRepository.submitReading(
                            bookId: widget.book.id,
                            session: widget.session,
                            answers: _answers,
                          );
                          await widget.session.discard();
                          if (!mounted || !dialogContext.mounted) return;

                          Navigator.pop(dialogContext);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomePage()),
                            (route) => false,
                          );
                        } catch (error) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Could not upload submission: $error',
                                ),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isTurningIn = false);
                        }
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: _isTurningIn && label == 'Turn it In'
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
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
            colors: [Color(0xFFFFF6A3), Color(0xFFF48FE1)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<QuizQuestion>>(
            future: _questionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF48FE1)),
                );
              }

              if (snapshot.hasError) {
                return _buildStateMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'Quiz unavailable',
                  message:
                      'Check the quiz_questions rows and Supabase select policy.',
                );
              }

              final questions = snapshot.data ?? [];
              if (questions.isEmpty) {
                return _buildStateMessage(
                  icon: Icons.quiz_outlined,
                  title: 'No quiz questions yet',
                  message: 'Add quiz questions for this book in Supabase.',
                );
              }

              return _buildCurrentStepView(questions);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepView(List<QuizQuestion> questions) {
    final currentQuestion = questions[_currentStep];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(questions.length, (index) {
              final isActive = index == _currentStep;
              return Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 40),
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF4A70FF)
                        : const Color.fromRGBO(255, 255, 255, 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'EXERCISE ${_currentStep + 1}',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const Spacer(flex: 2),
          Text(
            currentQuestion.question,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.3,
            ),
          ),
          const Spacer(flex: 2),
          _buildChoices(currentQuestion),
          const Spacer(flex: 3),
          SizedBox(
            width: 180,
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedOption == null
                  ? null
                  : () {
                      _recordCurrentAnswer(currentQuestion);
                      if (_currentStep < questions.length - 1) {
                        setState(() {
                          _currentStep += 1;
                          _selectedOption = null;
                        });
                      } else {
                        _showCongratulationsDialog(questions.length);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                disabledBackgroundColor: const Color.fromRGBO(
                  59,
                  130,
                  246,
                  0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentStep == questions.length - 1 ? 'Finish' : 'Next',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChoices(QuizQuestion question) {
    if (question.choices.length <= 3) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < question.choices.length; index++) ...[
              _buildChoiceCard(question.choices[index], index),
              if (index != question.choices.length - 1)
                const SizedBox(width: 10),
            ],
          ],
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var index = 0; index < question.choices.length; index++)
          _buildChoiceCard(question.choices[index], index),
      ],
    );
  }

  Widget _buildChoiceCard(String label, int optionIndex) {
    final isSelected = _selectedOption == optionIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = optionIndex;
        });
      },
      child: Container(
        width: 110,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E88E5) : Colors.black,
            width: isSelected ? 2.5 : 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isSelected ? const Color(0xFF1E88E5) : Colors.black87,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildStateMessage({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: Colors.black54),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
