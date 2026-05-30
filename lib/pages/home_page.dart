import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_mobile/pages/journey_page.dart';
import 'package:student_mobile/pages/messages_page.dart';
import 'package:student_mobile/pages/profile_page.dart';
import 'package:student_mobile/pages/quest_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          // Welcome Profile Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB9F6CA), // light mint green
                  Color(0xFF90CAF9), // light pastel blue
                ],
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
                // Avatar border
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black87,
                      width: 2.0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/icons/kai.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Text block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Welcome, Kai!',
                            style: GoogleFonts.quicksand(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '☀️',
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'LEVEL 1 READING EXPLORER',
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
            child: Column(
              children: [
                // Active Book 1 Row
                _buildBookItem(
                  title: 'The Two Best Friends',
                  sub: 'BOOK 1',
                  isActive: true,
                  color: const Color(0xFFA5D6A7),
                ),
                const SizedBox(height: 12),
                // Locked Book 2 Row
                _buildBookItem(
                  title: 'The Little Red Riding Hood',
                  sub: 'BOOK 2',
                  isActive: false,
                  color: const Color(0xFFE0F2F1),
                ),
                const SizedBox(height: 12),
                // Locked Book 3 Row
                _buildBookItem(
                  title: 'The Three Little Pigs',
                  sub: 'BOOK 3',
                  isActive: false,
                  color: const Color(0xFFE0F2F1),
                ),
                const SizedBox(height: 12),
                // Locked Book 4 Row
                _buildBookItem(
                  title: 'The Turtle and the Rabbit',
                  sub: 'BOOK 4',
                  isActive: false,
                  color: const Color(0xFFE0F2F1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Skills Focus & Achievements Card
          Container(
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
                        text: 'Reading\nLevel 1',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBadgeCard(
                        color: const Color(0xFF80CBC4),
                        text: 'Vocabulary\nLevel 2',
                      ),
                    ),
                  ],
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
                        text: 'Word Master\nLevel 2',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBadgeCard(
                        color: const Color(0xFFFFF59D),
                        text: 'Comprehension\nLevel 2',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBookItem({
    required String title,
    required String sub,
    required bool isActive,
    required Color color,
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
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestPage(),
                  ),
                );
              },
              icon: const Icon(Icons.eco_rounded, size: 14, color: Colors.white),
              label: Text(
                'Start Quest',
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
            )
          else
            const Icon(
              Icons.lock_rounded,
              color: Colors.black45,
              size: 20,
            )
        ],
      ),
    );
  }

  Widget _buildBadgeCard({
    required Color color,
    required String text,
  }) {
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
          )
        ],
      ),
    );
  }
}
