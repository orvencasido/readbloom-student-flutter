import 'package:student_mobile/models/quiz_question.dart';
import 'package:student_mobile/models/reading_book.dart';
import 'package:student_mobile/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookRepository {
  BookRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _supabase {
    if (!SupabaseConfig.isConfigured) {
      throw const SupabaseNotConfiguredException();
    }

    return _client ?? Supabase.instance.client;
  }

  Future<List<ReadingBook>> fetchActiveBooks() async {
    final rows = await _supabase
        .from('books')
        .select()
        .eq('is_active', true)
        .order('book_number', ascending: true);

    return rows.map((row) => ReadingBook.fromMap(row)).toList();
  }

  Future<List<QuizQuestion>> fetchQuizQuestions(String bookId) async {
    final rows = await _supabase
        .from('quiz_questions')
        .select()
        .eq('book_id', bookId)
        .order('order_number', ascending: true);

    return rows.map((row) => QuizQuestion.fromMap(row)).toList();
  }
}

class SupabaseNotConfiguredException implements Exception {
  const SupabaseNotConfiguredException();

  @override
  String toString() {
    return 'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY with --dart-define.';
  }
}
