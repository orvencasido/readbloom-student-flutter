class StudentProgress {
  const StudentProgress({
    required this.userId,
    required this.booksCompleted,
    required this.daysStreak,
    this.readingLevel = 1,
    this.fluencyLevel = 1,
    this.comprehensionLevel = 1,
  });

  final String userId;
  final int booksCompleted;
  final int daysStreak;
  final int readingLevel;
  final int fluencyLevel;
  final int comprehensionLevel;

  String get achievementTitle {
    if (booksCompleted >= 20) return 'MASTER';
    if (booksCompleted >= 10) return 'ACHIEVER';
    if (booksCompleted >= 5) return 'EXPLORER';
    return 'STARTER';
  }

  factory StudentProgress.fromMap(Map<String, dynamic> map) {
    return StudentProgress(
      userId: map['user_id'] as String,
      booksCompleted: map['books_completed'] as int? ?? 0,
      daysStreak: map['days_streak'] as int? ?? 0,
      readingLevel: map['reading_level'] as int? ?? 1,
      fluencyLevel: map['fluency_level'] as int? ?? 1,
      comprehensionLevel: map['comprehension_level'] as int? ?? 1,
    );
  }
}
