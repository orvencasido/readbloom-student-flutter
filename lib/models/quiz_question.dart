class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.bookId,
    required this.question,
    required this.choices,
    required this.answerIndex,
    required this.orderNumber,
  });

  final String id;
  final String bookId;
  final String question;
  final List<String> choices;
  final int answerIndex;
  final int orderNumber;

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    final rawChoices = map['choices'];
    final choices = rawChoices is List
        ? rawChoices.map((choice) => choice.toString()).toList()
        : <String>[];

    return QuizQuestion(
      id: map['id'] as String,
      bookId: map['book_id'] as String,
      question: map['question'] as String? ?? '',
      choices: choices,
      answerIndex: map['answer_index'] as int? ?? 0,
      orderNumber: map['order_number'] as int? ?? 0,
    );
  }
}
