class StudentProgress {
  const StudentProgress({
    required this.userId,
    required this.booksCompleted,
    required this.daysStreak,
  });

  final String userId;
  final int booksCompleted;
  final int daysStreak;

  int get readingLevel => (booksCompleted ~/ 5) + 1;

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
    );
  }
}
