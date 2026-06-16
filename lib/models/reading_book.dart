class ReadingBook {
  const ReadingBook({
    required this.id,
    required this.title,
    required this.bookNumber,
    required this.level,
    required this.passage,
    required this.isActive,
  });

  final String id;
  final String title;
  final int bookNumber;
  final int level;
  final String passage;
  final bool isActive;

  int get estimatedMinutesToRead {
    final wordCount = passage
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    final minutes = (wordCount / 120).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  factory ReadingBook.fromMap(Map<String, dynamic> map) {
    return ReadingBook(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Untitled Book',
      bookNumber: map['book_number'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      passage: map['passage'] as String? ?? '',
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
