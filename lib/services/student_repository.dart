import 'package:student_mobile/models/student_profile.dart';
import 'package:student_mobile/models/student_progress.dart';
import 'package:student_mobile/services/book_repository.dart';
import 'package:student_mobile/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRepository {
  StudentRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _supabase {
    if (!SupabaseConfig.isConfigured) {
      throw const SupabaseNotConfiguredException();
    }

    return _client ?? Supabase.instance.client;
  }

  String get _currentUserId {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('No authenticated user.');
    }

    return userId;
  }

  Future<StudentProfile> fetchCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user.');
    }

    final row = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (row != null) {
      return StudentProfile.fromMap(row);
    }

    final metadata = user.userMetadata ?? {};
    final profileRow = {
      'id': user.id,
      'full_name': metadata['full_name']?.toString() ?? '',
      'email': user.email ?? '',
      'section': metadata['section']?.toString() ?? '',
      'year_level': metadata['year_level']?.toString() ?? '',
    };

    await _supabase.from('profiles').insert(profileRow);

    return StudentProfile.fromMap(profileRow);
  }

  Future<StudentProgress> fetchCurrentProgress() async {
    final userId = _currentUserId;
    final row = await _supabase
        .from('student_progress')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (row != null) {
      return StudentProgress.fromMap(row);
    }

    await _supabase.from('student_progress').insert({
      'user_id': userId,
      'books_completed': 0,
      'days_streak': 0,
    });

    return StudentProgress(userId: userId, booksCompleted: 0, daysStreak: 0);
  }

  Future<void> acceptPrivacyAgreement() async {
    await _supabase
        .from('profiles')
        .update({'privacy_agreed_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', _currentUserId);
  }

  Future<void> completeBook(String bookId) async {
    await _supabase.rpc('complete_book', params: {'p_book_id': bookId});
  }
}
