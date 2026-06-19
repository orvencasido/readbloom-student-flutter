import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_mobile/pages/journey_page.dart';
import 'package:student_mobile/pages/messages_page.dart';
import 'package:student_mobile/pages/profile_page.dart';
import 'package:student_mobile/pages/reading_page.dart';
import 'package:student_mobile/models/reading_book.dart';
import 'package:student_mobile/models/student_profile.dart';
import 'package:student_mobile/models/student_progress.dart';
import 'package:student_mobile/services/book_repository.dart';
import 'package:student_mobile/services/student_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final BookRepository _bookRepository = BookRepository();
  final StudentRepository _studentRepository = StudentRepository();
  late Future<List<ReadingBook>> _booksFuture;
  late Future<StudentProfile> _profileFuture;
  late Future<StudentProgress> _progressFuture;
  late Future<Set<String>> _completedBookIdsFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _bookRepository.fetchActiveBooks();
    _profileFuture = _studentRepository.fetchCurrentProfile();
    _progressFuture = _studentRepository.fetchCurrentProgress();
    _completedBookIdsFuture = _studentRepository.fetchCompletedBookIds();
  }

  void _refreshBooks() {
    setState(() {
      _booksFuture = _bookRepository.fetchActiveBooks();
      _profileFuture = _studentRepository.fetchCurrentProfile();
      _progressFuture = _studentRepository.fetchCurrentProgress();
      _completedBookIdsFuture = _studentRepository.fetchCompletedBookIds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
          bottom: false,
          child: Column(
            children: [
              // Custom Header Panel (Dynamic Title)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.08),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _currentIndex == 3
                        ? 'My Profile'
                        : _currentIndex == 2
                        ? 'My Messages'
                        : _currentIndex == 1
                        ? 'My Journey'
                        : 'My Home',
                    style: GoogleFonts.quicksand(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              // Swap body based on bottom navigation index
              Expanded(
                child: _currentIndex == 3
                    ? const ProfilePage()
                    : _currentIndex == 2
                    ? const MessagesPage()
                    : _currentIndex == 1
                    ? const JourneyPage()
                    : _buildHomeContent(),
              ),

              // Bottom Navigation Bar
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, 'HOME'),
                    _buildNavItem(1, Icons.menu_book_rounded, 'JOURNEY'),
                    _buildNavItem(2, Icons.mail_rounded, 'MESSAGE'),
                    _buildNavItem(3, Icons.person_rounded, 'PROFILE'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Scrollable dashboard for index 0
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          FutureBuilder<List<Object>>(
            future: Future.wait([_profileFuture, _progressFuture]),
            builder: (context, snapshot) {
              final profile = snapshot.data?[0] as StudentProfile?;
              final progress = snapshot.data?[1] as StudentProgress?;

              return _buildWelcomeBanner(
                profileName: profile?.fullName ?? 'Reader',
                progress: progress,
              );
            },
          ),
          const SizedBox(height: 20),

          // Book Quest Card List
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<Object>>(
              future: Future.wait([_booksFuture, _completedBookIdsFuture]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF48FE1),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildBookStateMessage(
                    icon: Icons.cloud_off_rounded,
                    title: 'Supabase books unavailable',
                    message:
                        'Check your Supabase keys, table names, and select policies.',
                    actionLabel: 'Retry',
                    onPressed: _refreshBooks,
                  );
                }

                final books = snapshot.data?[0] as List<ReadingBook>? ?? [];
                final completedIds = snapshot.data?[1] as Set<String>? ?? {};
                if (books.isEmpty) {
                  return _buildBookStateMessage(
                    icon: Icons.menu_book_outlined,
                    title: 'No reading passages yet',
                    message: 'Add active books in Supabase to show them here.',
                    actionLabel: 'Refresh',
                    onPressed: _refreshBooks,
                  );
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    // ~76 px per item (card height) + 12 px gap, × 5 items
                    maxHeight: 440,
                  ),
                  child: Scrollbar(
                    thumbVisibility: books.length > 5,
                    child: ListView.separated(
                      physics: books.length > 5
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: books.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final unlocked =
                            index == 0 ||
                            completedIds.contains(books[index - 1].id) ||
                            completedIds.contains(books[index].id);
                        return _buildBookItem(
                          book: books[index],
                          unlocked: unlocked,
                          color: unlocked
                              ? (index == 0
                                    ? const Color(0xFFA5D6A7)
                                    : const Color(0xFFE0F2F1))
                              : Colors.grey.shade300,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          FutureBuilder<StudentProgress>(
            future: _progressFuture,
            builder: (context, snapshot) {
              return _buildProgressSummary(snapshot.data);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBookItem({
    required ReadingBook book,
    required Color color,
    required bool unlocked,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'BOOK ${book.bookNumber}',
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: unlocked
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReadingPage(book: book),
                      ),
                    );
                  }
                : null,
            icon: Icon(
              unlocked ? Icons.eco_rounded : Icons.lock_rounded,
              size: 14,
              color: Colors.white,
            ),
            label: Text(
              unlocked ? 'Start Quest' : 'Locked',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C6BC0), // Indigo button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner({
    required String profileName,
    required StudentProgress? progress,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB9F6CA), Color(0xFF90CAF9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black87, width: 2.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset('assets/icons/kai.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $profileName!',
                  style: GoogleFonts.quicksand(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'LEVEL ${progress?.readingLevel ?? 1} READING ${progress?.achievementTitle ?? 'STARTER'}',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(StudentProgress? progress) {
    final currentProgress =
        progress ??
        const StudentProgress(userId: '', booksCompleted: 0, daysStreak: 0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills Focus',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildBadgeCard(
                  color: const Color(0xFFEF9A9A),
                  text: 'Reading\nLevel ${currentProgress.readingLevel}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBadgeCard(
                  color: const Color(0xFF80CBC4),
                  text: 'Fluency\nLevel ${currentProgress.fluencyLevel}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBadgeCard(
            color: const Color(0xFFFFCC80),
            text: 'Comprehension\nLevel ${currentProgress.comprehensionLevel}',
          ),
          const SizedBox(height: 16),
          Text(
            'Achievements',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildBadgeCard(
                  color: const Color(0xFF90CAF9),
                  text: 'Reader\n${currentProgress.achievementTitle}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBadgeCard(
                  color: const Color(0xFFFFF59D),
                  text: 'Streak\n${currentProgress.daysStreak} days',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookStateMessage({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.black54),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onPressed,
            child: Text(
              actionLabel,
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard({required Color color, required String text}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        style: GoogleFonts.quicksand(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? Colors.black : Colors.black45,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.black : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
